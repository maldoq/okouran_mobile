/// Probabilité d'une cause, du plus au moins probable.
enum CauseLikelihood {
  probable('Probable'),
  possible('Possible'),
  toCheck('À vérifier'),
  unlikely('Peu probable');

  const CauseLikelihood(this.label);
  final String label;
}

/// Cause possible d'une surconsommation, avec l'indice qui l'appuie.
class AnomalyCause {
  const AnomalyCause({
    required this.id,
    required this.title,
    required this.evidence,
    required this.likelihood,
  });

  final String id;
  final String title;

  /// Ce que les données montrent (ex. « pic nocturne entre 22 h et 5 h »).
  final String evidence;
  final CauseLikelihood likelihood;
}

/// Consommation anormale détectée sur un compteur.
class Anomaly {
  const Anomaly({
    required this.alertId,
    required this.meterName,
    required this.detectedAt,
    required this.days,
    required this.dayKwh,
    required this.usualKwh,
    required this.bandLow,
    required this.bandHigh,
    required this.causes,
  });

  /// Alerte d'origine (pour la clore).
  final String alertId;
  final String meterName;
  final DateTime detectedAt;

  /// Les 7 derniers jours (le dernier est le jour anormal).
  final List<DateTime> days;
  final List<double> dayKwh;

  /// Consommation habituelle = moyenne sur 30 jours (kWh/j).
  final double usualKwh;

  /// Bande habituelle : valeurs normales de ce compteur (kWh/j).
  final double bandLow;
  final double bandHigh;

  final List<AnomalyCause> causes;

  double get anomalousKwh => dayKwh.last;

  /// Écart = jour anormal ÷ habitude − 1. Ex. 10,26 ÷ 7,6 − 1 = +35 %.
  double get gap => anomalousKwh / usualKwh - 1;
}