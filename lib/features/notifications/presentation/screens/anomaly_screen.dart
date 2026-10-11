import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/mock_anomaly.dart';
import '../../domain/anomaly.dart';
import '../providers/alerts_provider.dart';
import '../providers/live_alerts_provider.dart';

/// Écran 18 : Consommation anormale.
///
/// Montre l'écart, le situe par rapport à la bande habituelle, propose des
/// causes classées, et permet de clore l'alerte en indiquant la cause.
class AnomalyScreen extends ConsumerWidget {
  const AnomalyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Anomalie calculée à l'heure simulée ; à défaut, exemple de la maquette.
    final a = ref.watch(liveAnomalyProvider) ?? mockAnomaly;
    final text = Theme.of(context).textTheme;
    final resolved = ref
        .watch(alertsProvider)
        .any((x) => x.id == a.alertId && x.isResolved);

    return Scaffold(
      appBar: const AppTopBar(title: 'Anomalie détectée'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          // ---- L'écart ----
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF2D9A8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(
                    icon: Icons.warning_amber_rounded, tone: BadgeTone.warning),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Fmt.percentDelta(a.gap)} au-dessus\nde votre habitude',
                        style: text.headlineSmall?.copyWith(fontSize: 19),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${a.meterName} · ${Fmt.kwh(a.anomalousKwh)} kWh hier '
                        'contre ${Fmt.kwh(a.usualKwh)} kWh en moyenne. '
                        'Écart détecté à ${Fmt.time(a.detectedAt)}.',
                        style: text.bodySmall?.copyWith(
                            height: 1.5, color: const Color(0xFF8A4A05)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---- Où se situe l'écart ----
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 15, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text('Où se situe l\'écart', style: text.titleMedium),
                  ),
                  const SizedBox(height: 12),
                  _AnomalyChart(anomaly: a),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      'Zone verte : bande habituelle de ce compteur, '
                      '${Fmt.kwh(a.bandLow)} à ${Fmt.kwh(a.bandHigh)} kWh/j. '
                      'La valeur d\'hier en sort pour la première fois en 6 semaines.',
                      style: text.bodySmall?.copyWith(fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Causes possibles ----
          const SectionHeader(title: 'Causes possibles'),
          Card(
            child: Column(
              children: [
                for (final (i, c) in a.causes.indexed) ...[
                  if (i > 0) const Divider(indent: 50),
                  _CauseRow(cause: c),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (resolved)
            const InfoNote(
              icon: Icons.check_circle_outline_rounded,
              tone: BadgeTone.success,
              title: 'Alerte close.',
              message: 'Merci : ce motif ne déclenchera plus d\'alerte.',
            )
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'C\'est normal',
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.small,
                    onPressed: () => _close(context, ref, a),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Réduire ma conso',
                    variant: AppButtonVariant.dark,
                    size: AppButtonSize.small,
                    onPressed: () => context.push(AppRoutes.tips),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            'En indiquant la cause, vous aidez le modèle à ne plus vous '
            'alerter pour ce motif.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(fontSize: 10.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// « C'est normal » : demande la cause, puis clôt l'alerte.
  Future<void> _close(BuildContext context, WidgetRef ref, Anomaly a) async {
    final cause = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quelle en était la cause ?',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 6),
              for (final c in a.causes.where((c) => c.id != 'reading'))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.title),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(ctx, c.title),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Usage exceptionnel (fête, invités…)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(ctx, 'Usage exceptionnel'),
              ),
            ],
          ),
        ),
      ),
    );
    if (cause == null || !context.mounted) return;
    ref.read(alertsProvider.notifier).resolve(a.alertId);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Alerte close · cause : $cause'),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

/// Une cause possible avec sa probabilité.
class _CauseRow extends StatelessWidget {
  const _CauseRow({required this.cause});
  final AnomalyCause cause;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final icon = switch (cause.id) {
      'clim' => Icons.ac_unit_rounded,
      'device' => Icons.power_rounded,
      'tap' => Icons.group_outlined,
      _ => Icons.trending_down_rounded,
    };
    final probable = cause.likelihood == CauseLikelihood.probable;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cause.title,
                    style: text.titleSmall?.copyWith(fontSize: 12.5)),
                const SizedBox(height: 2),
                Text(cause.evidence,
                    style: text.bodySmall?.copyWith(fontSize: 10.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: probable ? AppColors.warningBg : const Color(0xFFEFF4F7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              cause.likelihood.label,
              style: text.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: probable ? const Color(0xFF8A4A05) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Histogramme des 7 derniers jours avec la bande habituelle en fond.
class _AnomalyChart extends StatelessWidget {
  const _AnomalyChart({required this.anomaly});
  final Anomaly anomaly;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final a = anomaly;
    final last = a.dayKwh.length - 1;
    final maxY = a.dayKwh.reduce((x, y) => x > y ? x : y) * 1.18;

    return SizedBox(
      height: 130,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          // Bande habituelle : zone verte claire entre bandLow et bandHigh.
          rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: a.bandLow,
              y2: a.bandHigh,
              color: AppColors.success.withValues(alpha: .12),
            ),
          ]),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, meta) => Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(Fmt.weekdayShort(a.days[v.toInt()]),
                      style: text.bodySmall
                          ?.copyWith(fontSize: 9.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 4,
              getTooltipItem: (g, _, rod, __) => BarTooltipItem(
                Fmt.kwh(rod.toY),
                text.bodySmall!.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < a.dayKwh.length; i++)
              BarChartGroupData(
                x: i,
                showingTooltipIndicators: i == last ? const [0] : const [],
                barRods: [
                  BarChartRodData(
                    toY: a.dayKwh[i],
                    width: 22,
                    color: i == last
                        ? AppColors.warning
                        : AppColors.secondary.withValues(alpha: .3),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}