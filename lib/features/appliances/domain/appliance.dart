/// Plage horaire d'utilisation d'un appareil.
///
/// Chaque plage répartit la consommation journalière sur 24 heures
/// (poids relatifs, normalisés à l'usage). Les plages « soir » concentrent la
/// consommation entre 18 h et 22 h : c'est le pic observé dans les foyers.
enum UsageWindow {
  permanent('Permanent (24 h / 24)'),
  evening('Le soir (18 h – 23 h)'),
  eveningNight('Soir et nuit (18 h – 2 h)'),
  daytime('En journée (8 h – 18 h)'),
  workshop('Atelier (9 h – 22 h, pic le soir)'),
  morningEvening('Matin et soir'),
  meals('Aux heures des repas');

  const UsageWindow(this.label);
  final String label;

  /// Poids bruts par heure (index 0 = minuit).
  List<double> get rawWeights => List<double>.generate(24, _weight);

  double _weight(int h) {
    switch (this) {
      case UsageWindow.permanent:
        return (h >= 12 && h <= 22) ? 1.15 : 0.9;
      case UsageWindow.evening:
        return const {18: 2.0, 19: 3.0, 20: 3.0, 21: 3.0, 22: 2.0, 23: 1.0, 6: 0.4, 7: 0.3}[h] ?? 0;
      case UsageWindow.eveningNight:
        return const {18: 1.6, 19: 2.6, 20: 3.0, 21: 3.0, 22: 2.6, 23: 1.6, 0: 1.0, 1: 0.7, 13: 0.5, 14: 0.5}[h] ?? 0;
      case UsageWindow.daytime:
        if (h >= 8 && h < 18) return 1;
        return (h >= 18 && h < 21) ? 0.6 : 0;
      case UsageWindow.workshop:
        if (h >= 9 && h < 18) return 1;
        return const {18: 1.7, 19: 2.0, 20: 2.0, 21: 1.6}[h] ?? 0;
      case UsageWindow.morningEvening:
        return const {6: 1.2, 7: 1.0, 18: 1.0, 19: 1.4, 20: 1.2}[h] ?? 0;
      case UsageWindow.meals:
        return const {11: 1.0, 12: 1.4, 13: 0.6, 18: 1.0, 19: 1.6, 20: 0.8}[h] ?? 0;
    }
  }

  /// Poids normalisés (somme = 1) : part de la journée consommée à chaque heure.
  List<double> get normalized {
    final w = rawWeights;
    final total = w.fold<double>(0, (s, v) => s + v);
    return [for (final v in w) v / total];
  }
}

/// Catalogue des types d'appareils, avec leurs valeurs par défaut
/// (proposées dans le formulaire d'ajout).
enum ApplianceType {
  airConditioner('❄️', 'Climatiseur', 1100, 4, UsageWindow.eveningNight, 0.25,
      'Réglez la climatisation à 26 °C au lieu de 22 °C',
      'Chaque degré en moins coûte environ 6 % de consommation.'),
  fan('🌀', 'Ventilateur', 60, 8, UsageWindow.eveningNight, 0.2,
      'Arrêtez les ventilateurs dans les pièces vides',
      'Un ventilateur oublié la nuit consomme pour rien.'),
  fridge('🧊', 'Réfrigérateur', 150, 10, UsageWindow.permanent, 0.15,
      'Dégivrez le réfrigérateur et vérifiez le joint',
      'Le givre isole : le moteur tourne plus longtemps.'),
  freezer('🥶', 'Congélateur', 200, 12, UsageWindow.permanent, 0.18,
      'Dégivrez le congélateur (givre de plus de 5 mm)',
      'Gardez-le plein et loin d’une source de chaleur.'),
  tv('📺', 'Téléviseur', 100, 5, UsageWindow.evening, 0.15,
      'Éteignez la télévision au lieu de la laisser en veille',
      'La veille consomme toute la nuit.'),
  lighting('💡', 'Éclairage', 10, 6, UsageWindow.evening, 0.3,
      'Éteignez les pièces inoccupées, passez au LED',
      'L’éclairage pèse surtout entre 18 h et 22 h.'),
  iron('👔', 'Fer à repasser', 1000, 0.5, UsageWindow.morningEvening, 0.2,
      'Repassez en une seule fois, en dehors de 18 h – 22 h',
      'Le fer chauffe fort à chaque remise en route.'),
  waterHeater('♨️', 'Chauffe-eau', 1500, 1, UsageWindow.morningEvening, 0.3,
      'Coupez le chauffe-eau au disjoncteur la journée',
      'Il maintient l’eau chaude même sans usage.'),
  cooker('🍳', 'Plaque / cuiseur', 800, 1, UsageWindow.meals, 0.1,
      'Couvrez les casseroles et coupez la plaque 5 min avant',
      'La chaleur résiduelle termine la cuisson.'),
  box('📡', 'Box / décodeur', 15, 24, UsageWindow.permanent, 0.4,
      'Débranchez box et décodeur la nuit',
      'Ils consomment 24 h / 24, même sans utilisation.'),
  charger('🔌', 'Chargeurs', 10, 6, UsageWindow.eveningNight, 0.5,
      'Débranchez les chargeurs une fois la charge finie',
      'Petits mais nombreux, ils s’additionnent.'),
  computer('💻', 'Ordinateur', 60, 5, UsageWindow.daytime, 0.2,
      'Mettez l’ordinateur en veille pendant les pauses',
      'Écran éteint = moitié de consommation en moins.'),
  pump('💧', 'Pompe à eau', 750, 1, UsageWindow.morningEvening, 0.15,
      'Programmez la pompe aux heures creuses',
      'Remplir la cuve le matin évite le pic du soir.'),
  sewingMachine('🧵', 'Machine à coudre', 100, 8, UsageWindow.workshop, 0.15,
      'Coupez les machines pendant les pauses',
      'Les moteurs à vide consomment encore.'),
  welder('🔥', 'Poste à souder', 3000, 1.5, UsageWindow.workshop, 0.12,
      'Évitez de souder entre 18 h et 22 h, coupez le poste à l’arrêt',
      'Le poste reste sous tension entre deux soudures.'),
  powerTool('🛠️', 'Outillage électrique', 800, 1, UsageWindow.workshop, 0.15,
      'Débranchez l’outillage après usage',
      'Compresseur et meuleuse en attente consomment.'),
  other('🔋', 'Autre appareil', 100, 2, UsageWindow.daytime, 0.1,
      'Débranchez cet appareil quand il ne sert pas',
      'Mode veille = consommation invisible.');

  const ApplianceType(this.emoji, this.label, this.defaultWatts, this.defaultHours,
      this.defaultUsage, this.savingRatio, this.tipTitle, this.tipDetail);

  final String emoji;
  final String label;
  final int defaultWatts;
  final double defaultHours;
  final UsageWindow defaultUsage;

  /// Part de la consommation de l'appareil qu'un geste simple permet d'économiser.
  final double savingRatio;
  final String tipTitle;
  final String tipDetail;
}

/// Appareil enregistré pour un compteur.
class Appliance {
  const Appliance({
    required this.id,
    required this.type,
    required this.name,
    required this.watts,
    required this.quantity,
    required this.hoursPerDay,
    required this.usage,
  });

  /// Appareil pré-rempli avec les valeurs par défaut du type.
  factory Appliance.fromType(String id, ApplianceType type,
          {String? name, int? watts, int quantity = 1, double? hours, UsageWindow? usage}) =>
      Appliance(
        id: id,
        type: type,
        name: name ?? type.label,
        watts: watts ?? type.defaultWatts,
        quantity: quantity,
        hoursPerDay: hours ?? type.defaultHours,
        usage: usage ?? type.defaultUsage,
      );

  final String id;
  final ApplianceType type;
  final String name;

  /// Puissance d'un appareil, en watts.
  final int watts;
  final int quantity;

  /// Heures d'utilisation par jour (temps de marche du moteur pour le froid).
  final double hoursPerDay;
  final UsageWindow usage;

  /// Consommation journalière = W × quantité × heures ÷ 1000 (kWh).
  double get dailyKwh => watts * quantity * hoursPerDay / 1000;

  /// Consommation prévue heure par heure (kWh), selon la plage d'utilisation.
  List<double> get hourlyKwh {
    final d = dailyKwh;
    return [for (final w in usage.normalized) d * w];
  }

  Appliance copyWith({ApplianceType? type, String? name, int? watts, int? quantity, double? hoursPerDay, UsageWindow? usage}) =>
      Appliance(
        id: id,
        type: type ?? this.type,
        name: name ?? this.name,
        watts: watts ?? this.watts,
        quantity: quantity ?? this.quantity,
        hoursPerDay: hoursPerDay ?? this.hoursPerDay,
        usage: usage ?? this.usage,
      );
}
