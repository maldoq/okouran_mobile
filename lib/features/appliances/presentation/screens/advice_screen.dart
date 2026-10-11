import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/clock/demo_clock_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../domain/advice_engine.dart';
import '../providers/appliances_provider.dart';

/// Écran « Conseils » (remplace TipsScreen sur la route /tips).
///
/// 1. Bilan du jour : consommé vs prévu à cette heure, projection fin de journée.
/// 2. Conseils urgents si la consommation dépasse la prévision (appareil à
///    éteindre, gain en kWh, FCFA et autonomie) ou pendant la pointe 18 h – 22 h.
/// 3. Gestes d'économie calculés à partir des appareils enregistrés.
class AdviceScreen extends ConsumerWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(selectedMeterProvider);
    final report = ref.watch(adviceProvider(meter.id));
    final day = ref.watch(todaySummaryProvider(meter.id));
    final text = Theme.of(context).textTheme;
    final over = report.overConsumption;
    final statusColor = over ? AppColors.danger : AppColors.success;

    return Scaffold(
      appBar: const AppTopBar(title: 'Conseils'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Image.asset(AppAssets.tipsHero, height: 120, fit: BoxFit.cover),
          ),
          const SizedBox(height: 14),
          // ── Bilan du jour ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: over ? AppColors.dangerBg : AppColors.successBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meter.name.toUpperCase(), style: AppTextStyles.adviceKicker(color: statusColor)),
                const SizedBox(height: 6),
                Text(
                  over
                      ? 'Vous consommez ${(report.vsPlan * 100).round()} % de plus que prévu'
                      : report.pastOverConsumption
                          ? 'Retour à la normale, merci !'
                          : 'Consommation conforme à la prévision',
                  style: AppTextStyles.alert(color: statusColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Figure(label: 'Consommé', value: '${Fmt.kwh(day.consumedKwh)} kWh'),
                    _Figure(label: 'Prévu à cette heure', value: '${Fmt.kwh(day.expectedSoFarKwh)} kWh'),
                    _Figure(label: 'Projection jour', value: '${Fmt.kwh(day.projectedDayKwh)} kWh'),
                  ],
                ),
              ],
            ),
          ),
          // ── Conseils urgents ─────────────────────────────────────────
          if (report.urgent.isNotEmpty) ...[
            const SectionHeader(title: 'À faire maintenant'),
            for (final u in report.urgent) _UrgentTile(advice: u, meterId: meter.id),
          ],
          // ── Gestes d'économie ────────────────────────────────────────
          SectionHeader(
            title: 'Vos gestes d\'économie',
            actionLabel: 'Mes appareils',
            onAction: () => context.push(AppRoutes.appliances),
          ),
          if (report.tips.isEmpty)
            Text('Ajoutez vos appareils pour obtenir des conseils chiffrés.', style: text.bodySmall),
          for (final t in report.tips)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.appliance.type.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.appliance.type.tipTitle, style: text.titleSmall?.copyWith(fontSize: 12.5)),
                        const SizedBox(height: 2),
                        Text(t.detail, style: text.bodySmall?.copyWith(fontSize: 10.5, height: 1.45)),
                        const SizedBox(height: 5),
                        Text(
                          '−${Fmt.kwh(t.kwhPerWeek)} kWh/sem · ${Fmt.fcfa(t.kwhPerWeek * meter.tariffPerKwh)}'
                          ' · +${Fmt.duration(Duration(minutes: t.autonomyGainMinutes.round()))}',
                          style: AppTextStyles.figure(11, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Part du soir (18 h – 22 h) dans votre consommation prévue : '
            '${(report.eveningShare * 100).round()} %.',
            style: text.bodySmall?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.figure(15)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9.5)),
          ],
        ),
      );
}

class _UrgentTile extends ConsumerWidget {
  const _UrgentTile({required this.advice, required this.meterId});
  final UrgentAdvice advice;
  final String meterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final stop = advice.kind == UrgentAdviceKind.stopAppliance;
    final color = stop ? AppColors.danger : AppColors.orangeDeep;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: stop ? AppColors.dangerBg : AppColors.brandBg,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(advice.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(advice.title, style: text.titleSmall?.copyWith(fontSize: 13))),
            ],
          ),
          const SizedBox(height: 6),
          Text(advice.text, style: text.bodySmall?.copyWith(fontSize: 11, height: 1.5)),
          if (advice.kwhPerDay > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Gain ≈ ${Fmt.kwh(advice.kwhPerDay)} kWh/j · ${Fmt.fcfa(advice.fcfaPerDay)}/j · '
              '+${Fmt.duration(Duration(minutes: advice.autonomyGainMinutes.round()))} d\'autonomie',
              style: AppTextStyles.figure(11.5, color: color),
            ),
          ],
          if (stop) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => ref.read(anomaliesProvider.notifier).stop(meterId, ref.read(demoMinuteProvider).round()),
              icon: const Icon(Icons.power_settings_new_rounded, size: 18),
              label: const Text('Je l\'ai éteint'),
            ),
          ],
        ],
      ),
    );
  }
}
