import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/page_dots.dart';
import '../../data/onboarding_pages.dart';
import '../../domain/onboarding_page.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_visual.dart';

/// Écran 2 : Onboarding en 3 pages.
///
/// - « Passer » (en haut) mène directement à la connexion.
/// - Le bouton retour apparaît à partir de la page 2.
/// - Le bouton principal affiche « Suivant », puis « Commencer » en dernière page.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  static const _pageAnim = Duration(milliseconds: 420);
  static const _pageCurve = Curves.easeOutCubic;

  int get _lastIndex => onboardingPages.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Précharge les 3 photos pour un défilement sans saccade.
    for (final p in onboardingPages) {
      precacheImage(AssetImage(p.image), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    final index = ref.read(onboardingIndexProvider);
    if (index < _lastIndex) {
      _pageController.nextPage(duration: _pageAnim, curve: _pageCurve);
    } else {
      _finish();
    }
  }

  void _previous() =>
      _pageController.previousPage(duration: _pageAnim, curve: _pageCurve);

  void _finish() {
    ref.read(onboardingCompletedProvider.notifier).state = true;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(onboardingIndexProvider);
    final isLast = index == _lastIndex;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screen,
            child: Column(
              children: [
                // « Passer » (masqué en dernière page, la place est conservée).
                SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLast ? 0 : 1,
                      child: TextButton(
                        onPressed: isLast ? null : _finish,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        child: const Text('Passer'),
                      ),
                    ),
                  ),
                ),

                // Pages.
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingPages.length,
                    onPageChanged: (i) =>
                        ref.read(onboardingIndexProvider.notifier).state = i,
                    itemBuilder: (context, i) =>
                        _OnboardingPageView(page: onboardingPages[i]),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                PageDots(count: onboardingPages.length, current: index),
                const SizedBox(height: AppSpacing.xl),

                // Boutons.
                Row(
                  children: [
                    // Le bouton retour glisse depuis la gauche à partir de la page 2.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: index == 0
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: AppButton.icon(
                                icon: Icons.arrow_back_rounded,
                                onPressed: _previous,
                              ),
                            ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: isLast ? 'Commencer' : 'Suivant',
                        icon: isLast ? Icons.bolt_rounded : null,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contenu d'une page : photo, titre, description.
class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Photo : 50 % de la hauteur dispo, bornée entre 180 et 300 px
        // pour rester lisible sur petits et grands téléphones.
        final imageHeight = (constraints.maxHeight * .50).clamp(180.0, 300.0);
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: OnboardingVisualCard(page: page),
                ),
                // Espace pour la mini-carte qui dépasse sous la photo.
                const SizedBox(height: onboardingCardOverlap + 24),
                // Légende, désormais sous la photo (plus rien sur l'image).
                Text(page.caption,
                    textAlign: TextAlign.center,
                    style: text.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary)),
                const SizedBox(height: AppSpacing.sm),
                Text(page.title,
                    textAlign: TextAlign.center,
                    style: text.headlineMedium),
                const SizedBox(height: AppSpacing.md),
                Text(page.description,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(height: 1.6)),
              ],
            ),
          ),
        );
      },
    );
  }
}