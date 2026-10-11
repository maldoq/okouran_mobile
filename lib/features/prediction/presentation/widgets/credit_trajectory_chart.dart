import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/forecast.dart';

/// Courbe du crédit : observé (trait plein), projeté jusqu'à 0 (pointillés)
/// et bande d'incertitude (zone orange claire entre l'hypothèse la plus
/// rapide et la plus lente).
///
/// Axe horizontal en jours par rapport à maintenant (0 = maintenant).
class CreditTrajectoryChart extends StatelessWidget {
  const CreditTrajectoryChart({super.key, required this.forecast});

  final Forecast forecast;

  double _x(DateTime d) =>
      d.difference(forecast.now).inMinutes / (60 * 24);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = forecast;

    final observed = [
      for (final p in f.observed) FlSpot(_x(p.date), p.kwh),
    ];
    final projected = [FlSpot(0, f.balanceKwh), FlSpot(_x(f.cutoff), 0)];
    final early = [FlSpot(0, f.balanceKwh), FlSpot(_x(f.cutoffEarliest), 0)];
    final late = [FlSpot(0, f.balanceKwh), FlSpot(_x(f.cutoffLatest), 0)];

    final minX = observed.first.x.floorToDouble();
    final maxX = _x(f.cutoffLatest).ceilToDouble();
    final maxY = f.observed.map((p) => p.kwh).reduce((a, b) => a > b ? a : b) * 1.12;

    LineChartBarData line(List<FlSpot> spots,
            {Color color = Colors.transparent,
            double width = 0,
            List<int>? dash}) =>
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: color,
          barWidth: width,
          dashArray: dash,
          dotData: const FlDotData(show: false),
        );

    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: maxY,
          lineTouchData: const LineTouchData(enabled: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          lineBarsData: [
            line(early), // 0 : borne basse (invisible)
            line(late), // 1 : borne haute (invisible)
            line(observed, color: AppColors.secondary, width: 2.5), // 2
            line(projected,
                color: AppColors.warning, width: 2.5, dash: [6, 4]), // 3
          ],
          // Zone d'incertitude entre les deux bornes.
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 0,
              toIndex: 1,
              color: AppColors.warning.withValues(alpha: .18),
            ),
          ],
          extraLinesData: ExtraLinesData(verticalLines: [
            VerticalLine(
              x: 0,
              color: AppColors.textSecondary.withValues(alpha: .5),
              strokeWidth: 1,
              dashArray: [3, 3],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: text.bodySmall?.copyWith(fontSize: 9.5),
                labelResolver: (_) => 'maintenant',
              ),
            ),
          ]),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 10,
                getTitlesWidget: (v, meta) => Text(
                  v.toInt().toString(),
                  style: text.bodySmall?.copyWith(fontSize: 9.5),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v != v.roundToDouble()) return const SizedBox.shrink();
                  final date = f.now.add(Duration(days: v.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(Fmt.dayShort(date),
                        style: text.bodySmall?.copyWith(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}