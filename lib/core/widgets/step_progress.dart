import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// En-tête des parcours en plusieurs étapes :
/// bouton retour, barre segmentée, compteur « 1 / 3 ».
class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.onBack,
  });

  /// Étape en cours, à partir de 1.
  final int current;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(onPressed: onBack),
        const SizedBox(width: 12),
        // Segments.
        Expanded(
          child: Row(
            children: List.generate(total, (i) {
              final done = i < current;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 5,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: done ? AppColors.secondary : const Color(0xFFE2EAEF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$current / $total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ],
    );
  }
}

/// Bouton retour carré 36 x 36 bordé (en-têtes des écrans de saisie).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(11),
      side: BorderSide(color: scheme.outline),
    );
    return Material(
      color: scheme.surface,
      shape: shape,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape,
        child: const SizedBox.square(
          dimension: 36,
          child: Icon(Icons.arrow_back_rounded, size: 18),
        ),
      ),
    );
  }
}