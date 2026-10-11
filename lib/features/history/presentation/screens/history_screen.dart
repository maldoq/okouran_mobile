import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../domain/recharge.dart';
import '../providers/consumption_providers.dart';
import '../providers/recharge_providers.dart';
import '../widgets/daily_consumption_list.dart';
import '../widgets/month_consumption_chart.dart';
import '../widgets/recharge_card.dart';

/// Écran 8 : Historique (onglet « Conso »).
///
/// Deux vues :
///   - Consommation : 30 derniers jours, graphique + liste jour par jour,
///     avec les recharges effectuées marquées sur chaque jour ;
///   - Recharges : toutes les recharges, filtrables par compteur.
///
/// Utilisé deux fois : comme onglet (sans retour) et comme page
/// `/history` ouverte depuis une alerte (avec retour, vue Recharges).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({
    super.key,
    this.initialTab = 0,
    this.showBack = false,
  });

  /// 0 = Consommation, 1 = Recharges.
  final int initialTab;
  final bool showBack;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: widget.showBack
          ? const AppTopBar(title: 'Historique')
          : null,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          top: !widget.showBack,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              if (!widget.showBack) ...[
                Text('Historique', style: text.headlineSmall),
                const SizedBox(height: 12),
              ],
              SegmentedTabs(
                labels: const ['Consommation', 'Recharges'],
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _tab == 0
                    ? const _ConsumptionView(key: ValueKey('conso'))
                    : const _RechargesView(key: ValueKey('recharges')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= Vue Consommation =======================

class _ConsumptionView extends ConsumerWidget {
  const _ConsumptionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final meter = ref.watch(selectedMeterProvider);
    final days = ref.watch(dailyConsumptionProvider); // ancien → récent
    final stats = ref.watch(consumptionStatsProvider);
    final rechargeByDay = ref.watch(rechargesByDayProvider(meter.id));

    final total = days.fold<double>(0, (s, d) => s + d.kwh);
    final recharged = rechargeByDay.values.fold<double>(0, (s, v) => s + v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Résumé sur 30 jours.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${meter.name.toUpperCase()} · 30 DERNIERS JOURS',
                    style: text.labelSmall),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: Fmt.kwh(total)),
                    TextSpan(
                      text: ' kWh consommés',
                      style: text.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ]),
                  style: text.headlineMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '≈ ${Fmt.fcfa(total * meter.tariffPerKwh)} au tarif de '
                  '${meter.tariffPerKwh.round()} F/kWh',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 14),
                MonthConsumptionChart(
                  days: days,
                  average: stats.average30Days,
                  rechargeDays: rechargeByDay.keys.toSet(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _legend(text, AppColors.secondary, 'Consommation du jour'),
                    const SizedBox(width: 14),
                    _legend(text, AppColors.accent, 'Jour de recharge'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Moyenne / j',
                value: Fmt.kwh(stats.average30Days),
                unit: 'kWh',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: 'Jour le plus haut',
                value: Fmt.kwh(
                    days.map((d) => d.kwh).reduce((a, b) => a > b ? a : b)),
                unit: 'kWh',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: 'Rechargé',
                value: Fmt.kwh(recharged),
                unit: 'kWh',
                color: AppColors.success,
              ),
            ),
          ],
        ),

        const SectionHeader(title: 'Jour par jour'),
        DailyConsumptionList(
          days: days.reversed.toList(),
          rechargeByDay: rechargeByDay,
          average: stats.average30Days,
        ),
        const SizedBox(height: 12),
        const InfoNote(
          icon: Icons.info_outline_rounded,
          message: 'Une valeur en orange dépasse de plus de 10 % votre '
              'moyenne sur 30 jours. Les journées complètes seulement : '
              'aujourd\'hui est affiché sur l\'accueil.',
        ),
      ],
    );
  }

  Widget _legend(TextTheme text, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: text.bodySmall
                  ?.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      );
}

// ======================= Vue Recharges =======================

class _RechargesView extends ConsumerWidget {
  const _RechargesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final meters = ref.watch(liveMetersProvider);
    final filter = ref.watch(rechargeMeterFilterProvider);
    final recharges = ref.watch(filteredRechargesProvider);

    final successful =
        recharges.where((r) => r.status == RechargeStatus.success);
    final paid = successful.fold<int>(0, (s, r) => s + r.amountFcfa);
    final kwh = successful.fold<double>(0, (s, r) => s + (r.kwh ?? 0));

    void setFilter(String? id) =>
        ref.read(rechargeMeterFilterProvider.notifier).state = id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filtre par compteur.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip('Tous', filter == null, () => setFilter(null)),
              for (final m in meters)
                _chip(m.name, filter == m.id, () => setFilter(m.id)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: StatTile(
                  label: 'Payé (réussi)',
                  value: Fmt.fcfa(paid).replaceAll(' FCFA', ''),
                  unit: 'F'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                  label: 'kWh crédités', value: Fmt.kwh(kwh), unit: 'kWh'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                  label: 'Opérations', value: '${recharges.length}'),
            ),
          ],
        ),
        const SizedBox(height: 4),

        if (recharges.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text('Aucune recharge pour ce compteur.',
                textAlign: TextAlign.center, style: text.bodyMedium),
          )
        else
          for (final r in recharges)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: RechargeCard(
                recharge: r,
                onAction: () => _snack(
                  context,
                  r.status == RechargeStatus.pending
                      ? 'Code simulé : 4821 0937 5512 6604 2280'
                      : 'Justificatif simulé : remboursement du 19/09.',
                ),
              ),
            ),
        const SizedBox(height: 14),
        AppButton(
          label: 'Exporter en PDF (12 derniers mois)',
          icon: Icons.picture_as_pdf_outlined,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.small,
          onPressed: () => _snack(context, 'Export PDF simulé.'),
        ),
        const SizedBox(height: 10),
        Text(
          'Chaque code de recharge reste consultable ici, même hors connexion.',
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(message), behavior: SnackBarBehavior.floating));
  }
}