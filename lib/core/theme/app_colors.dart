import 'package:flutter/material.dart';

/// Palette O'KOURAN, tirée du logo :
///   - l'anneau orange → jaune de l'éclair porte l'ACTION ;
///   - le vert du nom « KOURAN » porte l'INFORMATION et les CONSEILS.
/// Toute couleur de l'app doit venir d'ici.
///
/// Les noms historiques (primary, secondary, accent…) sont conservés pour
/// que le code existant compile sans modification : seules les valeurs changent.
abstract final class AppColors {
  // ---------------------------------------------------------------- Marque
  /// Vert profond (wordmark) : en-têtes sombres, cartes de synthèse, titres.
  static const Color primary = Color(0xFF0F3B17);

  /// Vert O'kouran : séries de données, liens secondaires, conseils.
  static const Color secondary = Color(0xFF1E8C2E);

  /// Orange énergie : action principale (bouton Recharger, onglet actif, jauge).
  static const Color accent = Color(0xFFFF6B00);

  // Couleurs complémentaires du logo
  static const Color orange = Color(0xFFFF6B00);
  static const Color orangeLight = Color(0xFFFF8A1F);
  static const Color orangeDeep = Color(0xFFE85400);
  static const Color orangeSplash = Color(0xFFFF5A00); // fond de l'icône d'application
  static const Color sun = Color(0xFFFFC000); // jaune de l'anneau
  static const Color sunLight = Color(0xFFFFC470); // jaune clair sur fond sombre
  static const Color greenDeep2 = Color(0xFF17561F);
  static const Color greenLight = Color(0xFF2FA83E);

  // ---------------------------------------------------------------- Neutres (clair)
  static const Color background = Color(0xFFF6F7F3); // blanc cassé chaud
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF18220F);
  static const Color textSecondary = Color(0xFF55604E);
  static const Color textTertiary = Color(0xFF8C9587);
  static const Color border = Color(0xFFE6E9E2);

  // ---------------------------------------------------------------- États
  // Réservés à la signalisation, jamais décoratifs. L'ambre « crédit faible »
  // est volontairement distinct de l'orange de marque.
  static const Color success = Color(0xFF13914F);
  static const Color warning = Color(0xFFC98400);
  static const Color danger = Color(0xFFD93A34);

  static const Color successBg = Color(0xFFE3F4EA);
  static const Color warningBg = Color(0xFFFFF3D6);
  static const Color dangerBg = Color(0xFFFCE9E7);
  static const Color infoBg = Color(0xFFE9F5EA);
  static const Color brandBg = Color(0xFFFFF0E5); // fond orangé des conseils

  // ---------------------------------------------------------------- Neutres (sombre, préparé)
  static const Color darkBackground = Color(0xFF0B140C);
  static const Color darkSurface = Color(0xFF142017);
  static const Color darkTextPrimary = Color(0xFFE8EFE6);
  static const Color darkTextSecondary = Color(0xFFA3B09E);
  static const Color darkBorder = Color(0xFF223326);

  // ---------------------------------------------------------------- Dégradés
  /// Dégradé vert (cartes de synthèse : prévision, crédit, compteur).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF1C6326)],
  );

  /// Dégradé orange (écran d'ouverture, connexion, en-tête de l'accueil,
  /// bouton principal).
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orangeLight, orange, orangeDeep],
    stops: [0, .55, 1],
  );

  /// Dégradé de l'anneau du logo (jauge de crédit sur fond sombre).
  static const SweepGradient logoRingGradient = SweepGradient(
    colors: [orange, Color(0xFFFFA000), sun, orange],
    stops: [0, .45, .75, 1],
  );
}
