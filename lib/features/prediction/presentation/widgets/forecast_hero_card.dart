import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/forecast.dart';

/// Carte bleu nuit : autonomie, heure de coupure, intervalle d'incertitude
/// et comparaison « division simple / modèle ».
class ForecastHeroCard extends StatelessWidget {
  const ForecastHeroCard({super.key, required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = forecast;
    final muted = Colors.white.withValues(alpha: .55);

    Widget compare(String label, String value, {Color? color}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: text.bodySmall?.copyWith(fontSize: 10, color: muted)),
              const SizedBox(height: 2),
              Text(
                value,
                style: text.titleSmall?.copyWith(
                  fontSize: 14,
                  color: color ?? Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AUTONOMIE ESTIMÉE', style: text.labelSmall?.copyWith(color: muted)),
          const SizedBox(height: 4),
          Text(
            Fmt.duration(f.modelAutonomy),
            style: text.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'Coupure prévue le '),
              TextSpan(
                text: Fmt.dateTimeLong(f.cutoff),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ]),
            style: text.bodySmall?.copyWith(
                fontSize: 12, color: Colors.white.withValues(alpha: .75)),
          ),
          const SizedBox(height: 10),

          // Intervalle d'incertitude.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.straighten_rounded,
                    size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Marge ± ${f.marginHours} h : entre '
                    '${Fmt.dayMedium(f.cutoffEarliest)} ${Fmt.time(f.cutoffEarliest)} '
                    'et ${Fmt.dayMedium(f.cutoffLatest)} ${Fmt.time(f.cutoffLatest)}',
                    style: text.bodySmall?.copyWith(
                        fontSize: 11, color: Colors.white.withValues(alpha: .85)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: .14)),
          const SizedBox(height: 12),
          Row(
            children: [
              compare('Division simple', Fmt.duration(f.naiveAutonomy)),
              compare('Modèle profilé', Fmt.duration(f.modelAutonomy),
                  color: AppColors.accent),
              compare('Écart', Fmt.signedHours(f.gapWithNaive)),
            ],
          ),
        ],
      ),
    );
  }
}