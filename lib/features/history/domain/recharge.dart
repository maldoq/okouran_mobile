/// Issue d'une recharge.
enum RechargeStatus {
  success('Réussie'),
  pending('En cours de vérification'),
  refunded('Échouée, remboursée');

  const RechargeStatus(this.label);
  final String label;
}

/// Recharge effectuée sur un compteur.
class Recharge {
  const Recharge({
    required this.id,
    required this.meterId,
    required this.meterName,
    required this.date,
    required this.amountFcfa,
    required this.kwh,
    required this.status,
    required this.method,
    this.note,
  });

  final String id;
  final String meterId;
  final String meterName;
  final DateTime date;

  /// Montant payé, en FCFA.
  final int amountFcfa;

  /// kWh crédités (null si la recharge a échoué).
  final double? kwh;
  final RechargeStatus status;

  /// Moyen de paiement (Orange Money, Wave, MTN MoMo…).
  final String method;

  /// Précision affichée sous la recharge (remboursement, attente…).
  final String? note;
}