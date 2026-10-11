/// Catégories d'alertes.
enum AlertType {
  lowCredit, // crédit faible
  criticalCredit, // crédit critique
  imminentCutoff, // coupure imminente
  anomaly, // consommation anormale
  rechargeConfirmed, // recharge confirmée
  tip, // conseil
}

/// Alerte reçue par l'utilisateur.
class AppAlert {
  const AppAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.meterName,
    required this.date,
    this.isRead = false,
    this.isResolved = false,
  });

  final String id;
  final AlertType type;
  final String title;

  /// Ligne d'explication courte (ex. « +35 % vs habitude »).
  final String detail;
  final String meterName;
  final DateTime date;
  final bool isRead;

  /// Vrai quand la situation est réglée (ex. crédit faible suivi d'une recharge).
  final bool isResolved;

  /// À traiter : alerte de crédit, de coupure ou de consommation non réglée.
  bool get needsAction =>
      !isResolved &&
      type != AlertType.rechargeConfirmed &&
      type != AlertType.tip;

  AppAlert copyWith({bool? isRead, bool? isResolved}) => AppAlert(
        id: id,
        type: type,
        title: title,
        detail: detail,
        meterName: meterName,
        date: date,
        isRead: isRead ?? this.isRead,
        isResolved: isResolved ?? this.isResolved,
      );
}