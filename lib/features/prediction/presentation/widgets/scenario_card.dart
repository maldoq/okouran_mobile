import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/forecast.dart';

/// « Et si je consommais… » : curseur de −20 % à +40 % et trois scénarios
/// (économique, normal, intensif). Le résultat se met à jour en direct.
class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.forecast,
    required this.change,
    required this.onChanged,
  });

  final Forecast forecast;

  /// Variation choisie (−0,20 à +0,40).
  final double change;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final f = forecast;
    final pct = (change * 100).round();
    final color = change < 0
        ? AppColors.success
        : change > 0
            ? AppColors.danger
            : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Et si je consommais…', style: text.titleMedium),
            const SizedBox(height: 2),
            Text(
              pct == 0
                  ? 'comme d\'habitude'
                  : '${pct > 0 ? '+' : '−'}${pct.abs()} % par rapport à d\'habitude',
              style: text.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),

            // Curseur.
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: AppColors.border,
                thumbColor: Colors.white,
                overlayColor: color.withValues(alpha: .12),
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10, elevation: 3),
              ),
              child: Slider(
                min: -0.20,
                max: 0.40,
                divisions: 12, // pas de 5 %
                value: change,
                onChanged: onChanged,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('−20 %', style: text.bodySmall?.copyWith(fontSize: 10)),
                Text('+40 %', style: text.bodySmall?.copyWith(fontSize: 10)),
              ],
            ),
            const SizedBox(height: 10),

            // Résultat du curseur.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: Fmt.duration(f.autonomyFor(change)),
                    style: text.titleLarge?.copyWith(
                        color: color, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '  ·  coupure ${Fmt.dayMedium(f.cutoffFor(change))} '
                        'vers ${Fmt.time(f.cutoffFor(change))}',
                    style: text.bodySmall,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // Trois scénarios : toucher pour placer le curseur.
            Row(
              children: [
                for (final s in ConsumptionScenario.values) ...[
                  if (s != ConsumptionScenario.values.first)
                    const SizedBox(width: 8),
                  Expanded(
                    child: _ScenarioTile(
                      scenario: s,
                      autonomy: f.autonomyFor(s.change),
                      selected: (change - s.change).abs() < 0.001,
                      onTap: () => onChanged(s.change),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Calcul : autonomie habituelle ÷ (1 + variation). '
              'Ex. −20 % : ${Fmt.duration(f.modelAutonomy)} ÷ 0,8 = '
              '${Fmt.duration(f.autonomyFor(-0.2))}.',
              style: text.bodySmall?.copyWith(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.scenario,
    required this.autonomy,
    required this.selected,
    required this.onTap,
  });

  final ConsumptionScenario scenario;
  final Duration autonomy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = switch (scenario) {
      ConsumptionScenario.economy => AppColors.success,
      ConsumptionScenario.normal => AppColors.primary,
      ConsumptionScenario.intensive => AppColors.danger,
    };
    final pct = (scenario.change * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .08) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(scenario.label,
                style: text.bodySmall?.copyWith(
                    fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
            Text(
              pct == 0 ? 'habitude' : '${pct > 0 ? '+' : '−'}${pct.abs()} %',
              style: text.bodySmall?.copyWith(fontSize: 9.5),
            ),
            const SizedBox(height: 4),
            Text(
              Fmt.duration(autonomy),
              style: text.titleSmall?.copyWith(
                fontSize: 14,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}