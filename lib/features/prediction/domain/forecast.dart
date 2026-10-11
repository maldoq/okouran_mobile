/// Scénarios de consommation proposés à l'utilisateur.
/// [change] = variation de la consommation par rapport à l'habitude.
enum ConsumptionScenario {
  economy('Économique', -0.20),
  normal('Normal', 0),
  intensive('Intensif', 0.40);

  const ConsumptionScenario(this.label, this.change);
  final String label;
  final double change;
}

/// Point de la courbe du crédit : date et kWh restants.
class CreditPoint {
  const CreditPoint(this.date, this.kwh);
  final DateTime date;
  final double kwh;
}

/// Prévision de coupure pour un compteur.
///
/// Tous les calculs partent de 3 données :
///   - le solde actuel (kWh) ;
///   - l'autonomie donnée par le modèle (simulée dans la maquette) ;
///   - la moyenne de consommation des 7 derniers jours.
class Forecast {
  const Forecast({
    required this.now,
    required this.balanceKwh,
    required this.modelAutonomy,
    required this.average7DaysKwh,
    required this.marginHours,
    required this.observed,
  });

  final DateTime now;
  final double balanceKwh;

  /// Autonomie calculée par le modèle profilé (tient compte des heures
  /// de pointe du soir, du jour de la semaine…).
  final Duration modelAutonomy;

  /// Moyenne par jour sur les 7 derniers jours (kWh).
  final double average7DaysKwh;

  /// Marge d'incertitude (intervalle à 80 %), en heures, de part et d'autre.
  final int marginHours;

  /// Solde observé sur les derniers jours (pour la courbe).
  final List<CreditPoint> observed;

  /// « Division simple » = solde ÷ moyenne 7 j, convertie en heures.
  Duration get naiveAutonomy => Duration(
      minutes: (balanceKwh / average7DaysKwh * 24 * 60).round());

  /// Écart modèle − division simple (négatif : le modèle prévoit plus tôt).
  Duration get gapWithNaive => modelAutonomy - naiveAutonomy;

  /// Autonomie si la consommation varie de [change] (ex. −0,20 = −20 %).
  /// Consommer 20 % de moins fait durer le crédit 1 ÷ 0,8 = 1,25 fois plus.
  Duration autonomyFor(double change) =>
      Duration(minutes: (modelAutonomy.inMinutes / (1 + change)).round());

  DateTime cutoffFor(double change) => now.add(autonomyFor(change));

  DateTime get cutoff => cutoffFor(0);
  DateTime get cutoffEarliest => cutoff.subtract(Duration(hours: marginHours));
  DateTime get cutoffLatest => cutoff.add(Duration(hours: marginHours));
}