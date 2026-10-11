import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Petite carte chiffrée : libellé, valeur et unité (ex. « Moyenne / j : 5,2 kWh »).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.color,
  });

  final String label;
  final String value;
  final String? unit;

  /// Couleur d'accent (texte + bordure + fond léger). Neutre si null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 11),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: .06) ?? scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color?.withValues(alpha: .35) ?? scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color ?? scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value),
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
            ]),
            style: text.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color ?? scheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}