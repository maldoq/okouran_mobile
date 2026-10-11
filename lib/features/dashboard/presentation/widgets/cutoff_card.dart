import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../meter/domain/meter.dart';
import '../../../meter/presentation/widgets/meter_style.dart';

/// Carte « Coupure estimée » : date et heure + niveau de risque.
class CutoffCard extends StatelessWidget {
  const CutoffCard({super.key, required this.meter, this.onTap});

  final Meter meter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = riskTone(meter.risk);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              IconBadge(icon: Icons.event_busy_rounded, tone: tone, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COUPURE ESTIMÉE', style: text.labelSmall),
                    const SizedBox(height: 3),
                    Text(
                      Fmt.dateTimeLong(meter.estimatedCutoff),
                      style: text.titleSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tone.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meter.risk.riskLabel,
                  style: text.labelSmall?.copyWith(
                    fontSize: 9.5,
                    letterSpacing: .3,
                    color: tone.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}