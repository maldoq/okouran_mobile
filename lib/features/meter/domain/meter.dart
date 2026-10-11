/// Usage du lieu équipé (sert à choisir l'icône).
/// [workshop] : atelier (couture, soudure…), ajouté pour les comptes de démonstration.
enum MeterKind { home, office, family, workshop }

/// État de la liaison avec le compteur.
enum MeterStatus {
  active('Actif'),
  offline('Hors ligne');

  const MeterStatus(this.label);
  final String label;
}

/// Niveau de risque de coupure, déduit de l'autonomie restante.
///
/// Seuils : 48 h et plus = faible ; de 24 h à 48 h = moyen ; moins de 24 h = élevé.
enum RiskLevel {
  low('Crédit suffisant', 'Risque faible'),
  medium('Crédit faible', 'Risque moyen'),
  high('Crédit critique', 'Risque élevé');

  const RiskLevel(this.creditLabel, this.riskLabel);

  /// Libellé de la pastille sous la jauge.
  final String creditLabel;

  /// Libellé du niveau de risque de coupure.
  final String riskLabel;

  static RiskLevel fromAutonomy(Duration autonomy) {
    if (autonomy.inHours >= 48) return low;
    if (autonomy.inHours >= 24) return medium;
    return high;
  }
}

/// Compteur prépayé suivi dans l'app.
class Meter {
  const Meter({
    required this.id,
    required this.name,
    required this.number,
    required this.location,
    required this.type,
    required this.kind,
    required this.status,
    required this.balanceKwh,
    required this.tariffPerKwh,
    required this.usualRechargeKwh,
    required this.autonomy,
    required this.estimatedCutoff,
    required this.remoteRecharge,
    this.sharedWith,
    this.ownerId,
  });

  final String id;
  final String name;

  /// Numéro du compteur, groupé par 4 chiffres.
  final String number;
  final String location;

  /// Ex. « Prépayé monophasé ».
  final String type;
  final MeterKind kind;
  final MeterStatus status;

  /// Crédit restant sur le compteur, en kWh.
  final double balanceKwh;

  /// Prix moyen d'un kWh pour ce compteur, en FCFA.
  final double tariffPerKwh;

  /// Quantité habituellement achetée à chaque recharge, en kWh.
  /// Sert de référence à la jauge : un compteur prépayé n'a pas de
  /// « réservoir », donc un pourcentage n'a de sens que par rapport à ça.
  final double usualRechargeKwh;

  /// Temps restant avant coupure, estimé (simulé dans la maquette).
  final Duration autonomy;

  /// Date et heure estimées de la coupure.
  final DateTime estimatedCutoff;

  /// Vrai si le compteur accepte la recharge à distance ;
  /// sinon l'utilisateur saisit le code de recharge sur le clavier du compteur.
  final bool remoteRecharge;

  /// Personnes qui suivent aussi ce compteur (null = personne).
  final String? sharedWith;

  /// Utilisateur propriétaire (comptes de démonstration : 'u1', 'u2').
  /// null = visible par tout utilisateur connecté.
  final String? ownerId;

  Meter copyWith({
    String? name,
    double? balanceKwh,
    Duration? autonomy,
    DateTime? estimatedCutoff,
    String? ownerId,
  }) =>
      Meter(
        id: id,
        name: name ?? this.name,
        number: number,
        location: location,
        type: type,
        kind: kind,
        status: status,
        balanceKwh: balanceKwh ?? this.balanceKwh,
        tariffPerKwh: tariffPerKwh,
        usualRechargeKwh: usualRechargeKwh,
        autonomy: autonomy ?? this.autonomy,
        estimatedCutoff: estimatedCutoff ?? this.estimatedCutoff,
        remoteRecharge: remoteRecharge,
        sharedWith: sharedWith,
        ownerId: ownerId ?? this.ownerId,
      );

  /// Valeur du crédit restant en FCFA = kWh restants × prix du kWh.
  double get balanceFcfa => balanceKwh * tariffPerKwh;

  /// Remplissage de la jauge (0 à 1) par rapport à un objectif d'autonomie.
  ///
  /// 100 % = le crédit permet de tenir [target] (ex. 7 jours).
  /// En dessous, la jauge baisse au même rythme que l'autonomie :
  /// 3 j 8 h ÷ 7 j = 48 %. Au-delà de l'objectif, elle reste pleine.
  ///
  /// On compare des durées et non des kWh : l'autonomie vient de la
  /// prévision, qui tient déjà compte du rythme réel du foyer.
  double gaugeRatio(Duration target) =>
      (autonomy.inMinutes / target.inMinutes).clamp(0.0, 1.0);

  /// Temps au-delà de l'objectif (zéro si l'objectif n'est pas atteint).
  Duration surplusOver(Duration target) =>
      autonomy > target ? autonomy - target : Duration.zero;

  RiskLevel get risk => RiskLevel.fromAutonomy(autonomy);

  /// Rythme de consommation déduit de la prévision :
  /// solde ÷ autonomie (en jours). Ex. 18,6 kWh ÷ 3,33 j ≈ 5,6 kWh/j.
  double get kwhPerDay => balanceKwh / (autonomy.inMinutes / 1440);
}