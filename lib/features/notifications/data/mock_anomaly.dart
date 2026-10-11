import '../domain/anomaly.dart';

/// Anomalie du Bureau Plateau, détectée hier (8 octobre) à 21 h
/// (alerte a2 « +35 % vs habitude »).
///
/// Habitude du Bureau = 7,6 kWh/j. Hier : 10,26 kWh, soit 10,26 ÷ 7,6 − 1 = +35 %.
/// Bande habituelle 6,8 – 8,4 kWh/j (habitude ± 10 % environ).
final Anomaly mockAnomaly = Anomaly(
  alertId: 'a2',
  meterName: 'Bureau Plateau',
  detectedAt: DateTime(2026, 10, 8, 21, 0),
  days: [for (var d = 2; d <= 8; d++) DateTime(2026, 10, d)],
  dayKwh: const [7.4, 7.8, 7.1, 7.6, 7.9, 7.3, 10.26],
  usualKwh: 7.6,
  bandLow: 6.8,
  bandHigh: 8.4,
  causes: const [
    AnomalyCause(
      id: 'clim',
      title: 'Climatisation laissée en marche',
      evidence: 'Le pic est nocturne, entre 22 h et 5 h',
      likelihood: CauseLikelihood.probable,
    ),
    AnomalyCause(
      id: 'device',
      title: 'Appareil ajouté récemment',
      evidence: 'Palier stable, pas un pic ponctuel',
      likelihood: CauseLikelihood.possible,
    ),
    AnomalyCause(
      id: 'tap',
      title: 'Branchement non autorisé',
      evidence: 'Hausse persistante sans changement d\'usage',
      likelihood: CauseLikelihood.toCheck,
    ),
    AnomalyCause(
      id: 'reading',
      title: 'Erreur de relevé du compteur',
      evidence: 'Aucun écart de télérelevé constaté',
      likelihood: CauseLikelihood.unlikely,
    ),
  ],
);