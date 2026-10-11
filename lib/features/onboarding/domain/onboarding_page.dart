/// Type d'illustration flottante affichée sur la photo de chaque page.
enum OnboardingVisual { meter, alert, recharge }

/// Contenu d'une page d'onboarding.
class OnboardingPage {
  const OnboardingPage({
    required this.image,
    required this.imageAlignment,
    required this.visual,
    required this.caption,
    required this.title,
    required this.description,
  });

  /// Photo de fond (chemin d'asset).
  final String image;

  /// Cadrage horizontal de la photo, de -1 (gauche) à 1 (droite).
  final double imageAlignment;

  /// Mini-carte posée sur la photo.
  final OnboardingVisual visual;

  /// Courte légende en capitales affichée au-dessus du titre.
  final String caption;

  final String title;
  final String description;
}