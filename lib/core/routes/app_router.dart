import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/meter/data/mock_recharge_offers.dart';
import '../../features/meter/presentation/screens/add_meter_screen.dart';
import '../../features/meter/presentation/screens/meter_detail_screen.dart';
import '../../features/meter/presentation/screens/meters_screen.dart';
import '../../features/meter/presentation/screens/payment_screen.dart';
import '../../features/meter/presentation/screens/recharge_screen.dart';
import '../../features/notifications/presentation/screens/alert_preview_screen.dart';
import '../../features/notifications/presentation/screens/anomaly_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/prediction/presentation/screens/forecast_screen.dart';
import '../../features/appliances/presentation/screens/advice_screen.dart';
import '../../features/appliances/presentation/screens/appliances_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../widgets/main_shell.dart';
import '../widgets/placeholder_screen.dart';
import 'app_routes.dart';

/// Routeur global exposé par Riverpod.
///
/// Les écrans pas encore codés pointent vers [PlaceholderScreen] :
/// la navigation est donc testable de bout en bout dès maintenant.
/// Chaque nouvel écran remplacera simplement son placeholder ici.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash : apparition en fondu (pas de glissement latéral).
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            _fade(state, const SplashScreen()),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _fade(state, const OnboardingScreen()),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fade(state, const LoginScreen()),
      ),

      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Le numéro arrive par `extra` (String de 10 chiffres).
      // Sans numéro (ex. rechargement à chaud), on prend celui de la démo.
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) =>
            OtpScreen(phone: state.extra as String? ?? mockUser.phone),
      ),

      // Les 4 onglets principaux, dans le cadre avec la barre du bas.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.conso,
              name: 'conso',
              builder: (context, state) => const HistoryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.notifications,
              name: 'notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // Historique ouvert depuis une alerte : vue Recharges, avec retour.
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) =>
            const HistoryScreen(initialTab: 1, showBack: true),
      ),

      GoRoute(
        path: AppRoutes.forecast,
        name: 'forecast',
        builder: (context, state) => const ForecastScreen(),
      ),

      GoRoute(
        path: AppRoutes.recharge,
        name: 'recharge',
        builder: (context, state) => const RechargeScreen(),
      ),

      // ?from=signup : étape 3 / 3 de l'inscription.
      GoRoute(
        path: AppRoutes.addMeter,
        name: 'add-meter',
        builder: (context, state) => AddMeterScreen(
          fromSignup: state.uri.queryParameters['from'] == 'signup',
        ),
      ),

      GoRoute(
        path: AppRoutes.meters,
        name: 'meters',
        builder: (context, state) => const MetersScreen(),
      ),

      // Le montant arrive par `extra` (int, en FCFA).
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        builder: (context, state) =>
            PaymentScreen(amountFcfa: state.extra as int? ?? defaultRechargeAmount),
      ),

      // Aperçus de notification (écran verrouillé simulé).
      GoRoute(
        path: AppRoutes.alertLow,
        name: 'alert-low',
        pageBuilder: (context, state) => _fade(state,
            const AlertPreviewScreen(kind: AlertPreviewKind.lowCredit)),
      ),
      GoRoute(
        path: AppRoutes.alertCritical,
        name: 'alert-critical',
        pageBuilder: (context, state) => _fade(state,
            const AlertPreviewScreen(kind: AlertPreviewKind.critical)),
      ),

      GoRoute(
        path: AppRoutes.anomaly,
        name: 'anomaly',
        builder: (context, state) => const AnomalyScreen(),
      ),

      GoRoute(
        path: AppRoutes.tips,
        name: 'tips',
        // Nouvel écran « Conseils » basé sur les appareils enregistrés.
        builder: (context, state) => const AdviceScreen(),
      ),

      GoRoute(
        path: AppRoutes.appliances,
        name: 'appliances',
        builder: (context, state) => const AppliancesScreen(),
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Détail d'un compteur : /meter/m1, /meter/m2…
      GoRoute(
        path: AppRoutes.meterDetail,
        name: 'meter-detail',
        builder: (context, state) =>
            MeterDetailScreen(meterId: state.pathParameters['id']!),
      ),

      ..._placeholders.entries.map(
        (e) => GoRoute(
          path: e.key,
          name: e.key.substring(1).replaceAll('/', '-'),
          pageBuilder: (context, state) =>
              _fade(state, PlaceholderScreen(title: e.value)),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        PlaceholderScreen(title: 'Page introuvable : ${state.uri}'),
  );
});

/// Écrans à venir (chemin → titre affiché).
const Map<String, String> _placeholders = {
  AppRoutes.credit: 'Détail du crédit',
  AppRoutes.absence: 'Mode absence',
};

/// Transition en fondu réutilisable.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}