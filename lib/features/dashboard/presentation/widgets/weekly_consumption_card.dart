import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../history/domain/daily_consumption.dart';

/// Carte « Consommation, 7 derniers jours » avec histogramme (fl_chart).
/// La dernière barre (hier) est mise en avant avec sa valeur au-dessus.
class WeeklyConsumptionCard extends StatelessWidget {
  const WeeklyConsumptionCard({
    super.key,
    required this.days,
    required this.weekTotal,
    required this.onDetails,
  });

  final List<DailyConsumption> days;
  final double weekTotal;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final maxY = days.map((d) => d.kwh).reduce((a, b) => a > b ? a : b) * 1.2;
    final last = days.length - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONSOMMATION', style: text.labelSmall),
                      const SizedBox(height: 3),
                      Text('7 derniers jours', style: text.titleMedium),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Fmt.kwh(weekTotal),
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text('kWh sur 7 jours',
                        style: text.bodySmall?.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 2,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            Fmt.weekdayShort(days[value.toInt()].date),
                            style: text.bodySmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pas d'interaction : la valeur affichée est fixe (dernière barre).
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 4,
                      getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                        Fmt.kwh(rod.toY),
                        text.bodySmall!.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < days.length; i++)
                      BarChartGroupData(
                        x: i,
                        showingTooltipIndicators: i == last ? const [0] : const [],
                        barRods: [
                          BarChartRodData(
                            toY: days[i].kwh,
                            width: 24,
                            color: i == last
                                ? AppColors.secondary
                                : AppColors.secondary.withValues(alpha: .26),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Voir le détail',
              icon: Icons.chevron_right_rounded,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.small,
              onPressed: onDetails,
            ),
          ],
        ),
      ),
    );
  }
}