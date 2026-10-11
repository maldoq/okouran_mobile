import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Niveau de solidité d'un mot de passe.
enum PasswordStrength {
  empty('', Color(0xFFE2EAEF)),
  weak('Faible', AppColors.danger),
  medium('Moyen', AppColors.warning),
  strong('Solide', AppColors.success),
  veryStrong('Très solide', AppColors.success);

  const PasswordStrength(this.label, this.color);
  final String label;
  final Color color;

  /// Nombre de segments allumés sur 4.
  int get bars => index;

  /// Un point par critère rempli :
  /// 8 caractères ou plus, un chiffre, majuscules et minuscules, un symbole.
  static PasswordStrength of(String password) {
    if (password.isEmpty) return empty;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'\d'))) score++;
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return switch (score) {
      0 || 1 => weak,
      2 => medium,
      3 => strong,
      _ => veryStrong,
    };
  }
}

/// Jauge à 4 segments + libellé, qui se met à jour pendant la saisie.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: i < strength.bars
                    ? strength.color
                    : PasswordStrength.empty.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        SizedBox(
          width: 70,
          child: Text(
            strength.label,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: strength.color,
                ),
          ),
        ),
      ],
    );
  }
}