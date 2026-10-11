import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/daily_consumption.dart';

/// Liste jour par jour : date, consommation (chiffre + barre) et recharge
/// effectuée ce jour-là s'il y en a une.
class DailyConsumptionList extends StatelessWidget {
  const DailyConsumptionList({
    super.key,
    required this.days,
    required this.rechargeByDay,
    required this.average,
  });

  /// Du plus récent au plus ancien.
  final List<DailyConsumption> days;

  /// kWh rechargés par jour (clé = jour à minuit).
  final Map<DateTime, double> rechargeByDay;

  /// Moyenne de la période : au-dessus, la valeur passe en orange.
  final double average;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final maxKwh = days.map((d) => d.kwh).reduce((a, b) => a > b ? a : b);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const Divider(indent: 14, endIndent: 14),
            _row(context, text, days[i], maxKwh),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, TextTheme text, DailyConsumption d,
      double maxKwh) {
    final recharge =
        rechargeByDay[DateTime(d.date.year, d.date.month, d.date.day)];
    // Au-dessus de 110 % de la moyenne : signalé en orange.
    final high = d.kwh > average * 1.1;
    final barColor = high ? AppColors.warning : AppColors.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(Fmt.dayMedium(d.date),
                style: text.titleSmall?.copyWith(fontSize: 12)),
          ),
          // Barre proportionnelle au jour le plus consommateur.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: d.kwh / maxKwh,
                minHeight: 6,
                backgroundColor: const Color(0xFFF0F4F6),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: Text(
              '${Fmt.kwh(d.kwh)} kWh',
              textAlign: TextAlign.right,
              style: text.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: high ? AppColors.warning : AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Recharge du jour (ou espace vide pour garder l'alignement).
          SizedBox(
            width: 64,
            child: recharge == null
                ? const SizedBox.shrink()
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 11, color: AppColors.primary),
                        Flexible(
                          child: Text(
                            '+${Fmt.kwh(recharge)}',
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}