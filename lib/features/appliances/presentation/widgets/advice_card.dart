import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/clock/demo_clock_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../domain/advice_engine.dart';
import '../providers/appliances_provider.dart';

/// Carte « Conseil du moment » du tableau de bord (remplace PeakTipCard).
///
/// - Consommation au-dessus de la prévision → bandeau rouge + conseil précis
///   (appareil à éteindre, kWh/FCFA par jour, autonomie gagnée) et bouton
///   « Je l'ai éteint » qui stoppe l'anomalie.
/// - Sinon → conseil de la fenêtre 18 h – 22 h ou meilleur geste d'économie.
class AdviceCard extends ConsumerWidget {
  const AdviceCard({super.key, required this.meterId, required this.onSeeAll});

  final String meterId;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(adviceProvider(meterId));
    final text = Theme.of(context).textTheme;
    final over = report.overConsumption;
    final UrgentAdvice? first = report.urgent.isEmpty ? null : report.urgent.first;
    final tip = report.tips.isEmpty ? null : report.tips.first;

    final accent = over ? AppColors.danger : AppColors.orangeDeep;
    final bg = over ? AppColors.dangerBg : AppColors.brandBg;

    String title;
    String body;
    String emoji;
    if (first != null) {
      emoji = first.emoji;
      title = first.title;
      body = first.text;
    } else if (tip != null) {
      emoji = tip.appliance.type.emoji;
      title = tip.appliance.type.tipTitle;
      body = tip.detail;
    } else {
      emoji = '💡';
      title = 'Ajoutez vos appareils';
      body = 'Vos conseils sont calculés à partir des appareils enregistrés dans Paramètres.';
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            over
                ? 'CONSOMMATION +${(report.vsPlan * 100).round()} % AU-DESSUS DE LA PRÉVISION'
                : 'CONSEIL DU MOMENT',
            style: AppTextStyles.adviceKicker(color: accent),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall?.copyWith(fontSize: 13)),
                    const SizedBox(height: 3),
                    Text(body, style: text.bodySmall?.copyWith(fontSize: 11, height: 1.5)),
                    if (first != null && first.kwhPerDay > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        '≈ ${Fmt.kwh(first.kwhPerDay)} kWh/j · ${Fmt.fcfa(first.fcfaPerDay)}/j'
                        ' · +${Fmt.duration(Duration(minutes: first.autonomyGainMinutes.round()))} d\'autonomie',
                        style: AppTextStyles.figure(11.5, color: accent, weight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (first != null && first.kind == UrgentAdviceKind.stopAppliance)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      ref.read(anomaliesProvider.notifier).stop(meterId, ref.read(demoMinuteProvider).round());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Merci ! La prévision est recalculée.')),
                      );
                    },
                    child: const Text('Je l\'ai éteint'),
                  ),
                ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'Voir tous les conseils →',
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
