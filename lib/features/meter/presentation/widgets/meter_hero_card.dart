import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/meter.dart';
import 'meter_style.dart';

/// Carte d'en-tête du détail compteur (fond bleu nuit) :
/// identité du compteur puis trois chiffres clés.
class MeterHeroCard extends StatelessWidget {
  const MeterHeroCard({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = riskTone(meter.risk);
    final accent = meter.risk == RiskLevel.low ? AppColors.accent : tone.color;

    Widget figure(String value, String unit, String label) => Expanded(
          child: Column(
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: value),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: .6),
                      ),
                    ),
                ]),
                style: text.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: text.bodySmall?.copyWith(
                      fontSize: 10, color: Colors.white.withValues(alpha: .55))),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(meterKindIcon(meter.kind),
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meter.name,
                        style: text.titleMedium?.copyWith(
                            color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      meter.number,
                      style: text.bodySmall?.copyWith(
                        letterSpacing: .6,
                        color: Colors.white.withValues(alpha: .6),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: meter.status.label,
                tone: statusTone(meter.status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: .12)),
          const SizedBox(height: 14),
          Row(
            children: [
              figure(Fmt.kwh(meter.balanceKwh), 'kWh', 'restants'),
              figure(Fmt.duration(meter.autonomy), '', 'd\'autonomie'),
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.shield_outlined, color: accent, size: 22),
                    const SizedBox(height: 4),
                    Text(meter.risk.riskLabel,
                        style: text.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: accent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}