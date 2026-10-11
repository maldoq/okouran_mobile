import '../../meter/domain/meter.dart';
import '../domain/appliance.dart';
import '../domain/consumption_engine.dart';

/// Appareils enregistrés pour les 4 compteurs de démonstration
/// (identiques à la version HTML, voir assets/data/demo_data.json).
///
/// Consommation prévue par jour : m1 7,78 kWh · m2 6,72 kWh · m3 10,80 kWh · m4 6,32 kWh.
final Map<String, List<Appliance>> mockAppliances = {
  // Aya — Maison Cocody
  'm1': [
    Appliance.fromType('a101', ApplianceType.airConditioner, name: 'Climatiseur chambre', hours: 3),
    Appliance.fromType('a102', ApplianceType.fan, name: 'Ventilateurs', quantity: 2),
    Appliance.fromType('a103', ApplianceType.fridge, name: 'Réfrigérateur'),
    Appliance.fromType('a104', ApplianceType.tv, name: 'Téléviseur salon'),
    Appliance.fromType('a105', ApplianceType.lighting, name: 'Éclairage LED', quantity: 8),
    Appliance.fromType('a106', ApplianceType.box, name: 'Box internet'),
    Appliance.fromType('a107', ApplianceType.iron, name: 'Fer à repasser'),
    Appliance.fromType('a108', ApplianceType.charger, name: 'Chargeurs', quantity: 3),
  ],
  // Aya — Atelier couture
  'm2': [
    Appliance.fromType('a109', ApplianceType.sewingMachine, name: 'Machines à coudre', quantity: 3),
    Appliance.fromType('a110', ApplianceType.iron, name: 'Fer à repasser pro', watts: 1200, hours: 2, usage: UsageWindow.workshop),
    Appliance.fromType('a111', ApplianceType.fan, name: 'Ventilateurs', quantity: 2, hours: 9, usage: UsageWindow.workshop),
    Appliance.fromType('a112', ApplianceType.lighting, name: 'Éclairage atelier', quantity: 6, watts: 15),
    Appliance.fromType('a113', ApplianceType.computer, name: 'Ordinateur caisse'),
  ],
  // Koffi — Maison Yopougon
  'm3': [
    Appliance.fromType('a114', ApplianceType.airConditioner, name: 'Climatiseur salon', watts: 1200, hours: 4),
    Appliance.fromType('a115', ApplianceType.freezer, name: 'Congélateur'),
    Appliance.fromType('a116', ApplianceType.fridge, name: 'Réfrigérateur', watts: 120),
    Appliance.fromType('a117', ApplianceType.tv, name: 'Téléviseur', watts: 120, hours: 6),
    Appliance.fromType('a118', ApplianceType.lighting, name: 'Éclairage', quantity: 6),
    Appliance.fromType('a119', ApplianceType.fan, name: 'Ventilateurs', quantity: 2),
    Appliance.fromType('a120', ApplianceType.box, name: 'Décodeur TV'),
  ],
  // Koffi — Atelier soudure
  'm4': [
    Appliance.fromType('a121', ApplianceType.welder, name: 'Poste à souder'),
    Appliance.fromType('a122', ApplianceType.powerTool, name: 'Meuleuse / perceuse'),
    Appliance.fromType('a123', ApplianceType.lighting, name: 'Éclairage atelier', quantity: 4, watts: 20),
    Appliance.fromType('a124', ApplianceType.fan, name: 'Ventilateur', hours: 9, usage: UsageWindow.workshop),
  ],
};

/// Anomalies de démonstration : le climatiseur du salon de Koffi est resté
/// allumé depuis 2 h du matin (+0,6 kWh par heure). Détectée à 3 h 30.
const Map<String, MeterAnomaly> demoAnomalies = {
  'm3': MeterAnomaly(applianceType: ApplianceType.airConditioner, extraKwhPerHour: 0.6, fromMinute: 120),
};

/// Appareils proposés par défaut pour un nouveau compteur.
List<Appliance> defaultAppliancesFor(MeterKind kind, String idPrefix) => kind == MeterKind.workshop
    ? [
        Appliance.fromType('${idPrefix}_1', ApplianceType.sewingMachine, name: 'Machines', quantity: 2),
        Appliance.fromType('${idPrefix}_2', ApplianceType.powerTool, name: 'Outillage'),
        Appliance.fromType('${idPrefix}_3', ApplianceType.lighting, name: 'Éclairage', quantity: 4, watts: 15),
        Appliance.fromType('${idPrefix}_4', ApplianceType.fan, name: 'Ventilateur', usage: UsageWindow.workshop),
      ]
    : [
        Appliance.fromType('${idPrefix}_1', ApplianceType.fridge),
        Appliance.fromType('${idPrefix}_2', ApplianceType.tv),
        Appliance.fromType('${idPrefix}_3', ApplianceType.lighting, name: 'Éclairage', quantity: 6),
        Appliance.fromType('${idPrefix}_4', ApplianceType.fan, name: 'Ventilateurs', quantity: 2),
        Appliance.fromType('${idPrefix}_5', ApplianceType.box),
      ];
