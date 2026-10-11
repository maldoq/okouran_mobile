import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../providers/forecast_provider.dart';
import '../widgets/credit_trajectory_chart.dart';
import '../widgets/forecast_hero_card.dart';
import '../widgets/scenario_card.dart';

/// Écran 9 : Prévisions.
///
/// Heure de coupure estimée, intervalle d'incertitude, courbe du crédit
/// et scénarios économique / normal / intensif.
class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecast = ref.watch(forecastProvider);
    final meter = ref.watch(selectedMeterProvider);
    final change = ref.watch(scenarioChangeProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Prévisions · ${meter.name}',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('ESTIMÉ',
              style: text.labelSmall
                  ?.copyWith(fontSize: 9, color: const Color(0xFF8A5A00))),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          ForecastHeroCard(forecast: forecast),
          const SizedBox(height: 12),

          // Courbe du crédit.
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 15, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trajectoire du crédit', style: text.titleMedium),
                        Text('kWh',
                            style: text.bodySmall?.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CreditTrajectoryChart(forecast: forecast),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      _legend(text, 'Observé',
                          Container(width: 14, height: 2.5, color: AppColors.secondary)),
                      _legend(text, 'Projeté',
                          Container(width: 14, height: 2.5, color: AppColors.warning)),
                      _legend(
                          text,
                          'Intervalle 80 %',
                          Container(
                            width: 14,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: .18),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          ScenarioCard(
            forecast: forecast,
            change: change,
            onChanged: (v) =>
                ref.read(scenarioChangeProvider.notifier).state = v,
          ),
          const SizedBox(height: 12),

          // Ce que le modèle utilise.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CE QUE LE MODÈLE UTILISE', style: text.labelSmall),
                  const SizedBox(height: 6),
                  for (final (title, sub) in const [
                    ('Moyenne pondérée des 7 derniers jours',
                        'les jours récents comptent plus'),
                    ('Profil horaire et jour de semaine',
                        'le soir et le week-end ne pèsent pas pareil'),
                    ('Saison (chaleur, harmattan)',
                        'la climatisation change tout'),
                    ('Recharges passées', 'montant et fréquence habituels'),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 10),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: text.titleSmall
                                        ?.copyWith(fontSize: 12)),
                                Text(sub,
                                    style: text.bodySmall
                                        ?.copyWith(fontSize: 10.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),
                  const InfoNote(
                    icon: Icons.info_outline_rounded,
                    message: 'Dans cette maquette, l\'autonomie du modèle est une '
                        'valeur simulée. La prévision réelle se resserrera après '
                        '7 jours d\'historique et ne sera pas affichée avant 3 jours.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Recharger maintenant',
            icon: Icons.bolt_rounded,
            onPressed: () => context.push(AppRoutes.recharge),
          ),
        ],
      ),
    );
  }

  Widget _legend(TextTheme text, String label, Widget swatch) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          swatch,
          const SizedBox(width: 5),
          Text(label,
              style: text.bodySmall
                  ?.copyWith(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      );
}