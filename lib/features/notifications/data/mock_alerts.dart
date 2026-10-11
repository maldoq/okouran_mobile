import '../domain/app_alert.dart';

/// Historique des alertes (déjà passées) des comptes de démonstration.
/// Les alertes du jour (consommation inhabituelle, crédit faible / critique)
/// sont calculées en direct : voir liveAlertsProvider.
final List<AppAlert> mockAlerts = [
  AppAlert(id: 'p1', type: AlertType.rechargeConfirmed, title: 'Recharge confirmée', detail: '+30 kWh',
      meterName: 'Maison Cocody', date: DateTime(2026, 10, 6, 18, 42)),
  AppAlert(id: 'p2', type: AlertType.lowCredit, title: 'Crédit faible', detail: '≈ 1 j 2 h restants',
      meterName: 'Maison Cocody', date: DateTime(2026, 10, 5, 19, 15), isRead: true, isResolved: true),
  AppAlert(id: 'p3', type: AlertType.rechargeConfirmed, title: 'Recharge confirmée', detail: '+40 kWh',
      meterName: 'Atelier couture', date: DateTime(2026, 10, 5, 8, 10)),
  AppAlert(id: 'p4', type: AlertType.tip, title: 'Votre pic est entre 18 h et 22 h', detail: 'climatiseur et éclairage',
      meterName: 'Maison Cocody', date: DateTime(2026, 9, 30, 10, 0), isRead: true),
  AppAlert(id: 'p5', type: AlertType.rechargeConfirmed, title: 'Recharge confirmée', detail: '+68,5 kWh',
      meterName: 'Maison Yopougon', date: DateTime(2026, 10, 7, 19, 5)),
  AppAlert(id: 'p6', type: AlertType.imminentCutoff, title: 'Coupure imminente', detail: 'Coupure prévue dans ≈ 3 h',
      meterName: 'Atelier soudure', date: DateTime(2026, 10, 3, 7, 50), isRead: true, isResolved: true),
  AppAlert(id: 'p7', type: AlertType.rechargeConfirmed, title: 'Recharge confirmée', detail: '+50 kWh',
      meterName: 'Atelier soudure', date: DateTime(2026, 10, 3, 10, 45), isRead: true),
  AppAlert(id: 'p8', type: AlertType.tip, title: 'Congélateur : pensez à dégivrer', detail: 'givre > 5 mm',
      meterName: 'Maison Yopougon', date: DateTime(2026, 9, 28, 9, 0), isRead: true),
]..sort((a, b) => b.date.compareTo(a.date));
