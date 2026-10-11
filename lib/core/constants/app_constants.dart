/// Constantes globales de l'application.
abstract final class AppConstants {
  static const String appName = "O'KOURAN";
  static const String tagline = 'Votre électricité sous contrôle';
  static const String disclaimer =
      'Prototype de recherche · non affilié à la CIE / ERANOV';
  static const String version = 'v1.0.0';
  static const String build = 'build 2026.10.09';

  /// Durée totale du splash avant redirection.
  static const Duration splashDuration = Duration(milliseconds: 2800);

  /// Code SMS accepté par la démo.
  static const String demoOtp = '123456';
}

/// Chemins des ressources graphiques (tous déclarés dans pubspec.yaml).
///
/// Les logos existent en 1x / 2.0x / 3.0x : Flutter choisit
/// automatiquement la bonne résolution selon l'écran.
abstract final class AppAssets {
  // ---- Logo (fourni par O'KOURAN, fond transparent)
  /// Symbole en couleur (anneau orange-jaune + éclair) : fonds clairs ou vert profond.
  static const String logoIcon = 'assets/logo/logo_icon.png';

  /// Symbole blanc : fonds orange (splash, connexion, en-tête de l'accueil).
  static const String logoWhite = 'assets/logo/logo_white.png';

  /// Logo complet (symbole + « KOURAN » + slogan) : fonds clairs uniquement.
  static const String logoFull = 'assets/logo/logo_full.png';

  /// Nom « KOURAN » seul (avec prises) : fonds clairs.
  static const String logoWord = 'assets/logo/logo_word.png';

  /// Logo complet en haute définition (impression, partage).
  static const String logoFullHd = 'assets/logo/logo_full_hd.png';

  /// Versions vectorielles (nécessitent le paquet flutter_svg, facultatif).
  static const String logoIconSvg = 'assets/logo/svg/logo_icon.svg';
  static const String logoWhiteSvg = 'assets/logo/svg/logo_white.svg';

  // ---- Photos et illustrations
  static const String splashBackground = 'assets/images/splash_bg.webp';
  static const String onboardingMeter = 'assets/images/onboarding_meter.webp';
  static const String onboardingAlert = 'assets/images/onboarding_alert.webp';
  static const String onboardingRecharge = 'assets/images/onboarding_recharge.webp';

  /// Bandeau de la section Conseils.
  static const String tipsHero = 'assets/images/tips_hero.webp';

  /// Personne devant son compteur à touches : ajout de compteur, présentation.
  static const String heroMeter = 'assets/images/hero_meter.webp';

  // ---- Données de démonstration (référence, identiques à la version HTML)
  static const String demoData = 'assets/data/demo_data.json';
}
