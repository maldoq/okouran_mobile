import '../../meter/data/mock_meters.dart';
import '../../meter/domain/meter.dart';
import '../domain/forecast.dart';

/// Moyenne de consommation des 7 derniers jours par compteur (kWh/jour),
/// cohérente avec les appareils enregistrés (voir mock_appliances.dart).
const Map<String, double> _average7Days = {
  'm1': 7.8, // Maison Cocody (appareils : 7,78 kWh/j)
  'm2': 6.7, // Atelier couture
  'm3': 10.8, // Maison Yopougon (hors anomalie)
  'm4': 6.3, // Atelier soudure
};

/// Construit la prévision d'un compteur.
/// [now] : heure de l'horloge de démonstration (par défaut `mockNow`).
Forecast mockForecastFor(Meter meter, {DateTime? now}) {
  final at = now ?? mockNow;
  final avg = _average7Days[meter.id] ?? 5.0;

  // Solde reconstitué sur 3 jours au rythme moyen, jusqu'au solde actuel.
  final observed = [
    for (var d = 3; d >= 0; d--)
      CreditPoint(at.subtract(Duration(days: d)), meter.balanceKwh + avg * d),
  ];

  return Forecast(
    now: at,
    balanceKwh: meter.balanceKwh,
    modelAutonomy: meter.autonomy,
    average7DaysKwh: avg,
    marginHours: 6,
    observed: observed,
  );
}