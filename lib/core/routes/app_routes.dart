import '../../features/notifications/domain/app_alert.dart';

/// Noms et chemins de toutes les routes (un seul endroit à modifier).
///
/// La liste suit les 21 écrans de la maquette, regroupés par parcours.
abstract final class AppRoutes {
  // Découverte & accès
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const addMeter = '/add-meter';

  /// Ajout de compteur à la fin de l'inscription (étape 3 / 3).
  static const addMeterAfterSignup = '/add-meter?from=signup';

  // Suivre & comprendre (onglets principaux)
  static const dashboard = '/dashboard';
  static const conso = '/conso';
  static const notifications = '/notifications';
  static const profile = '/profile';

  // Sous-pages
  static const meterDetail = '/meter/:id';
  static String meterDetailOf(String id) => '/meter/$id';
  static const credit = '/credit';
  static const forecast = '/forecast';
  static const anomaly = '/anomaly';
  static const tips = '/tips';

  /// Mes appareils (ajout / modification / suppression).
  static const appliances = '/appliances';
  static const alertLow = '/alert/low';
  static const alertCritical = '/alert/critical';
  static const recharge = '/recharge';
  static const payment = '/recharge/payment';
  static const history = '/history';
  static const meters = '/meters';
  static const settings = '/settings';
  static const absence = '/absence';
}

/// Route de destination d'une alerte lorsqu'elle est ouverte depuis une liste.
String routeForAlert(AlertType type) => switch (type) {
      AlertType.lowCredit => AppRoutes.alertLow,
      AlertType.criticalCredit || AlertType.imminentCutoff =>
        AppRoutes.alertCritical,
      AlertType.anomaly => AppRoutes.anomaly,
      AlertType.rechargeConfirmed => AppRoutes.history,
      AlertType.tip => AppRoutes.tips,
    };