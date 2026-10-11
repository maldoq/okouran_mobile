import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Variantes du logo fourni.
enum LogoVariant {
  /// Symbole en couleur (fonds clairs ou vert profond).
  color,

  /// Symbole blanc (fonds orange).
  white,
}

/// Symbole O'KOURAN : l'éclair dans le bouton de mise sous tension.
/// Image du logo officiel (1x / 2x / 3x), nette à toutes les tailles courantes.
///
/// `size` = largeur ; la hauteur suit les proportions du logo (≈ 1,15 × largeur).
class OkouranLogo extends StatelessWidget {
  const OkouranLogo({super.key, this.size = 52, this.variant = LogoVariant.white});

  final double size;
  final LogoVariant variant;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      variant == LogoVariant.white ? AppAssets.logoWhite : AppAssets.logoIcon,
      width: size,
      height: size * 1.15,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: "Logo O'KOURAN",
    );
  }
}

/// Logo dans une tuile arrondie orange (en-têtes, écrans d'authentification).
class OkouranLogoTile extends StatelessWidget {
  const OkouranLogoTile({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(size * .31),
        boxShadow: [
          BoxShadow(color: AppColors.orangeDeep.withValues(alpha: .35), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -6),
        ],
      ),
      child: OkouranLogo(size: size * .5),
    );
  }
}

/// Logo complet (symbole + « KOURAN » + slogan), pour fonds clairs.
class OkouranLogoFull extends StatelessWidget {
  const OkouranLogoFull({super.key, this.width = 260});

  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
        AppAssets.logoFull,
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: "O'KOURAN — Votre électricité sous contrôle",
      );
}

/// Bloc « symbole blanc + O’KOURAN + slogan » de l'écran d'ouverture
/// (fond orange, comme l'application de référence).
class OkouranSplashMark extends StatelessWidget {
  const OkouranSplashMark({super.key, this.logoSize = 104});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OkouranLogo(size: logoSize),
        const SizedBox(height: 18),
        Text('O’KOURAN', style: AppTextStyles.brandName(40)),
        const SizedBox(height: 10),
        Text(AppConstants.tagline, style: AppTextStyles.tagline(12, color: Colors.white.withValues(alpha: .9))),
      ],
    );
  }
}
