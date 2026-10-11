import '../domain/meter.dart';

/// Date de référence de la maquette (journée simulée : vendredi 9 octobre 2026).
/// L'heure courante vient de l'horloge de démonstration (demoClockProvider) ;
/// `mockNow` reste utilisé pour les dates relatives (« hier », « 6 oct. »).
final DateTime mockNow = DateTime(2026, 10, 9, 13, 35);

/// Compteurs de démonstration : deux par utilisateur.
///
/// IMPORTANT : ici `balanceKwh` = solde à MINUIT (recharges du jour comprises).
/// Le solde courant, l'autonomie et l'heure de coupure sont recalculés en
/// direct par `liveMetersProvider` à partir des appareils enregistrés ; les
/// valeurs `autonomy` / `estimatedCutoff` ci-dessous ne sont que des valeurs
/// de départ (à 7 h).
final List<Meter> mockMeters = [
  // ---- Aya Kouassi (u1) : consommation normale
  Meter(
    id: 'm1',
    ownerId: 'u1',
    name: 'Maison Cocody',
    number: '0451 8823 7194',
    location: 'Cocody Angré, Abidjan',
    type: 'Prépayé monophasé',
    kind: MeterKind.home,
    status: MeterStatus.active,
    balanceKwh: 27,
    tariffPerKwh: 73,
    usualRechargeKwh: 50,
    autonomy: const Duration(days: 3, hours: 13),
    estimatedCutoff: DateTime(2026, 10, 12, 19, 36),
    remoteRecharge: true,
    sharedWith: 'Conjoint',
  ),
  Meter(
    id: 'm2',
    ownerId: 'u1',
    name: 'Atelier couture',
    number: '0451 3306 4428',
    location: 'Riviera Palmeraie, Cocody',
    type: 'Prépayé monophasé',
    kind: MeterKind.workshop,
    status: MeterStatus.active,
    balanceKwh: 21,
    tariffPerKwh: 80,
    usualRechargeKwh: 40,
    autonomy: const Duration(days: 3, hours: 4),
    estimatedCutoff: DateTime(2026, 10, 12, 11, 2),
    remoteRecharge: false,
  ),
  // ---- Koffi Yao (u2) : hausse anormale (climatiseur resté allumé) + crédit critique le soir
  Meter(
    id: 'm3',
    ownerId: 'u2',
    name: 'Maison Yopougon',
    number: '0451 9930 1185',
    location: 'Yopougon Sicogi, Abidjan',
    type: 'Prépayé monophasé',
    kind: MeterKind.home,
    status: MeterStatus.active,
    balanceKwh: 34,
    tariffPerKwh: 73,
    usualRechargeKwh: 50,
    autonomy: const Duration(days: 1, hours: 6),
    estimatedCutoff: DateTime(2026, 10, 10, 12, 31),
    remoteRecharge: true,
    sharedWith: '3 personnes',
  ),
  Meter(
    id: 'm4',
    ownerId: 'u2',
    name: 'Atelier soudure',
    number: '0451 7712 0583',
    location: 'Abobo PK18, Abidjan',
    type: 'Prépayé triphasé',
    kind: MeterKind.workshop,
    status: MeterStatus.active,
    balanceKwh: 12.5,
    tariffPerKwh: 80,
    usualRechargeKwh: 40,
    autonomy: const Duration(days: 1, hours: 15),
    estimatedCutoff: DateTime(2026, 10, 10, 21, 56),
    remoteRecharge: false,
  ),
];
