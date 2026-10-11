import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/onboarding_page.dart';
import 'onboarding_cards.dart';

/// Hauteur de la mini-carte qui dépasse sous la photo.
/// L'écran ajoute cet espace sous la photo pour que rien ne se chevauche.
const double onboardingCardOverlap = 34;

/// Photo de chaque page, affichée sans voile ni texte par-dessus.
/// La mini-carte est posée à cheval sur le bord bas de la photo :
/// elle ne masque qu'une petite bande en bas à gauche.
class OnboardingVisualCard extends StatelessWidget {
  const OnboardingVisualCard({super.key, required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Photo nette, coins arrondis, ombre légère.
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              boxShadow: AppShadows.card,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                page.image,
                fit: BoxFit.cover,
                alignment: Alignment(page.imageAlignment, 0),
              ),
            ),
          ),
        ),
        // Mini-carte à cheval sur le bord bas.
        Positioned(
          left: AppSpacing.lg,
          bottom: -onboardingCardOverlap,
          child: _FloatIn(child: _cardFor(page.visual)),
        ),
      ],
    );
  }

  Widget _cardFor(OnboardingVisual visual) => switch (visual) {
        OnboardingVisual.meter => const BalanceMiniCard(),
        OnboardingVisual.alert => const LowCreditMiniCard(),
        OnboardingVisual.recharge => const ForecastMiniCard(),
      };
}

/// Fait monter la mini-carte en fondu à l'affichage de la page.
class _FloatIn extends StatelessWidget {
  const _FloatIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child),
      ),
    );
  }
}