import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Familles de polices intégrées au projet (assets/fonts, déclarées dans
/// pubspec.yaml). Aucune connexion n'est nécessaire : l'affichage est
/// identique sur tous les appareils.
abstract final class AppFonts {
  /// Géométrique, comme le mot « KOURAN » du logo : nom de l'app, titres,
  /// grands chiffres (crédit, autonomie, heure de coupure), boutons.
  static const String brand = 'Jost';

  /// Très lisible en petite taille : textes courants, formulaires, alertes.
  static const String text = 'Inter';

  /// Chasse fixe : numéros de compteur, codes de recharge, valeurs alignées.
  static const String mono = 'JetBrainsMono';
}

/// Typographie O'KOURAN.
///   - display* : grands chiffres (Jost Bold, chiffres tabulaires) ;
///   - headline*/title* : titres (Jost SemiBold) ;
///   - body* : texte courant (Inter) ;
///   - labelLarge : boutons (Jost SemiBold, léger interlettrage) ;
///   - labelSmall : libellés en capitales (Inter Bold, espacé).
abstract final class AppTextStyles {
  static const _tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle brand(double size, FontWeight w, {double? height, double ls = 0}) =>
        TextStyle(fontFamily: AppFonts.brand, fontSize: size, fontWeight: w, height: height, letterSpacing: ls, color: primary);
    TextStyle text(double size, FontWeight w, {double? height, Color? color, double ls = 0}) =>
        TextStyle(fontFamily: AppFonts.text, fontSize: size, fontWeight: w, height: height, letterSpacing: ls, color: color ?? primary);

    return TextTheme(
      // Gros chiffres (solde kWh, autonomie)
      displayLarge: brand(44, FontWeight.w700, height: 1).copyWith(fontFeatures: _tabular),
      displayMedium: brand(36, FontWeight.w700, height: 1).copyWith(fontFeatures: _tabular),
      displaySmall: brand(28, FontWeight.w700, height: 1.05).copyWith(fontFeatures: _tabular),
      // Titres d'écran
      headlineLarge: brand(30, FontWeight.w600, height: 1.12),
      headlineMedium: brand(26, FontWeight.w600, height: 1.15),
      headlineSmall: brand(22, FontWeight.w600, height: 1.2),
      // Sous-titres (barres, cartes)
      titleLarge: brand(18, FontWeight.w600),
      titleMedium: brand(15.5, FontWeight.w600),
      titleSmall: text(13, FontWeight.w600),
      // Texte courant
      bodyLarge: text(15, FontWeight.w400),
      bodyMedium: text(13, FontWeight.w400, height: 1.55, color: secondary),
      bodySmall: text(11.5, FontWeight.w400, color: secondary),
      // Boutons, badges, libellés en capitales
      labelLarge: brand(15, FontWeight.w600, ls: .3),
      labelMedium: text(12, FontWeight.w600),
      labelSmall: text(10.5, FontWeight.w700, ls: 1.2, color: secondary),
    );
  }

  // ---------------------------------------------------------------- Styles dédiés

  /// Chiffre clé (crédit restant, autonomie, heure de coupure).
  static TextStyle figure(double size, {Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w700}) =>
      TextStyle(fontFamily: AppFonts.brand, fontSize: size, fontWeight: weight, height: 1, letterSpacing: -.2, color: color, fontFeatures: _tabular);

  /// Numéro de compteur, code de recharge.
  static TextStyle code(double size, {Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w500}) =>
      TextStyle(fontFamily: AppFonts.mono, fontSize: size, fontWeight: weight, letterSpacing: .6, color: color, fontFeatures: _tabular);

  /// Nom de l'application (« O’KOURAN »).
  static TextStyle brandName(double size, {Color color = Colors.white}) =>
      TextStyle(fontFamily: AppFonts.brand, fontSize: size, fontWeight: FontWeight.w600, letterSpacing: size * .04, color: color);

  /// Slogan (« Votre électricité sous contrôle »), espacé comme sur le logo.
  static TextStyle tagline(double size, {Color color = Colors.white}) =>
      TextStyle(fontFamily: AppFonts.brand, fontSize: size, fontWeight: FontWeight.w400, letterSpacing: size * .14, color: color);

  /// Intitulé des cartes de conseil (« CONSEIL PRIORITAIRE »).
  static TextStyle adviceKicker({Color color = AppColors.secondary}) =>
      TextStyle(fontFamily: AppFonts.brand, fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 1.4, color: color);

  /// Texte des alertes et pastilles d'état.
  static TextStyle alert({Color color = AppColors.textPrimary}) =>
      TextStyle(fontFamily: AppFonts.text, fontSize: 11.5, fontWeight: FontWeight.w700, color: color);
}
