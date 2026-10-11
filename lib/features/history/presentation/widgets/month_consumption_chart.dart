import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/daily_consumption.dart';

/// Histogramme des 30 derniers jours.
/// - barres vertes : jours où une recharge a été faite ;
/// - ligne pointillée : moyenne sur la période.
/// Toucher une barre affiche la date et la valeur.
class MonthConsumptionChart extends StatelessWidget {
  const MonthConsumptionChart({
    super.key,
    required this.days,
    required this.average,
    required this.rechargeDays,
  });

  final List<DailyConsumption> days;
  final double average;

  /// Jours (à minuit) ayant une recharge réussie.
  final Set<DateTime> rechargeDays;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final maxY = days.map((d) => d.kwh).reduce((a, b) => a > b ? a : b) * 1.18;

    bool isRecharge(DailyConsumption d) =>
        rechargeDays.contains(DateTime(d.date.year, d.date.month, d.date.day));

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceBetween,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: average,
              color: AppColors.textSecondary.withValues(alpha: .6),
              strokeWidth: 1,
              dashArray: [4, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: text.bodySmall?.copyWith(fontSize: 9.5),
                labelResolver: (_) => 'moy. ${Fmt.kwh(average)}',
              ),
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
                interval: 1,
                // Une date tous les 7 jours, en partant de la fin.
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if ((days.length - 1 - i) % 7 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(Fmt.dayShort(days[i].date),
                        style: text.bodySmall?.copyWith(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.primary,
              tooltipBorderRadius: BorderRadius.circular(4),
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${Fmt.dayMedium(days[group.x].date)}\n${Fmt.kwh(rod.toY)} kWh',
                text.bodySmall!.copyWith(
                  fontSize: 10.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: days[i].kwh,
                  width: 6,
                  color: isRecharge(days[i])
                      ? AppColors.accent
                      : AppColors.secondary.withValues(alpha: .75),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}