import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tonalité d'une pastille d'icône (couleur de l'icône + fond pastel).
enum BadgeTone {
  info(AppColors.secondary, AppColors.infoBg),
  brand(AppColors.orangeDeep, AppColors.brandBg),
  success(AppColors.success, AppColors.successBg),
  warning(AppColors.warning, AppColors.warningBg),
  danger(AppColors.danger, AppColors.dangerBg),
  neutral(AppColors.textSecondary, Color(0xFFF0F2EE));

  const BadgeTone(this.color, this.background);
  final Color color;
  final Color background;
}

/// Pastille carrée arrondie contenant une icône (alertes, listes, cartes).
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.tone = BadgeTone.neutral,
    this.size = 36,
  });

  final IconData icon;
  final BadgeTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, size: size * .5, color: tone.color),
    );
  }
}