import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/okouran_logo.dart';

/// Écran 1 : Splash.
///
/// Déroulé (≈ 2,8 s, piloté par un seul AnimationController) :
///   0 % → 35 %   le logo apparaît (fondu + léger zoom)
///   20 % → 55 %  le nom et le slogan montent en fondu
///   10 % → 100 % la barre de progression se remplit
/// À la fin : redirection automatique vers l'onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.splashDuration,
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .35, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: .82, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .4, curve: Curves.easeOutBack),
    ));
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.2, .55, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, .25), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(.2, .55, curve: Curves.easeOutCubic),
    ));
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.1, 1, curve: Curves.easeInOut),
    );

    _controller
      ..addStatusListener(_onAnimationStatus)
      ..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Évite un flash blanc le temps que l'image de fond se décode.
    precacheImage(const AssetImage(AppAssets.splashBackground), context);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      // Plus tard : aller au dashboard si l'utilisateur est déjà connecté.
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Icônes de la barre d'état en blanc sur fond sombre.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Identité O'KOURAN : écran d'ouverture orange (comme le logo).
        backgroundColor: AppColors.orangeSplash,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Photo d'ampoule (même cadrage que la maquette : 21 % horizontal).
            Image.asset(
              AppAssets.splashBackground,
              fit: BoxFit.cover,
              alignment: const Alignment(-.58, 0),
            ),

            // 2. Voile dégradé bleu nuit pour la lisibilité.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.orangeSplash.withValues(alpha: .90),
                    AppColors.orange.withValues(alpha: .86),
                    AppColors.orangeDeep.withValues(alpha: .94),
                  ],
                  stops: const [0, .48, 1],
                ),
              ),
            ),

            // 3. Contenu.
            SafeArea(
              child: Column(
                children: [
                  Expanded(child: _buildCenter(text)),
                  _buildFooter(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logo, nom, slogan et barre de progression.
  Widget _buildCenter(TextTheme text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _logoFade,
          child: ScaleTransition(
            scale: _logoScale,
            child: Container(
              width: 118,
              height: 118,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: Colors.white.withValues(alpha: .16)),
              ),
              child: const OkouranLogo(size: 74),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FadeTransition(
          opacity: _textFade,
          child: SlideTransition(
            position: _textSlide,
            child: Column(
              children: [
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.brandName(40),
                ),
                const SizedBox(height: 6),
                Text(
                  AppConstants.tagline,
                  style: AppTextStyles.tagline(12.5, color: Colors.white.withValues(alpha: .9)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl + AppSpacing.sm),
        // Barre de progression : montre que l'app travaille (pas d'écran muet).
        SizedBox(
          width: 120,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => LinearProgressIndicator(
                value: _progress.value,
                backgroundColor: Colors.white.withValues(alpha: .16),
                valueColor: const AlwaysStoppedAnimation(AppColors.sun),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mention de non-affiliation et version.
  Widget _buildFooter(TextTheme text) {
    final small = text.bodySmall?.copyWith(fontSize: 10.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 0, 26, AppSpacing.lg),
      child: FadeTransition(
        opacity: _textFade,
        child: Column(
          children: [
            Text(
              AppConstants.disclaimer,
              textAlign: TextAlign.center,
              style: small?.copyWith(color: Colors.white.withValues(alpha: .75)),
            ),
            const SizedBox(height: 3),
            Text(
              '${AppConstants.version} · ${AppConstants.build}',
              style: small?.copyWith(
                color: Colors.white.withValues(alpha: .6),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
