import '../../meter/data/mock_meters.dart';
import '../domain/daily_consumption.dart';

/// 30 journées complètes simulées (kWh), de J-30 à hier.
/// Les 7 dernières reprennent la maquette (total 36,4 kWh).
/// Moyenne 30 j = 169,5 ÷ 30 = 5,65 kWh ; moyenne 7 j = 36,4 ÷ 7 = 5,2 kWh.
const List<double> _last30DaysKwh = [
  5.6, 6.0, 5.9, 5.4, 6.3, 5.7, 5.5, 6.1, 5.8, 5.2, //
  6.4, 5.9, 5.6, 5.3, 6.2, 6.0, 5.7, 5.4, 5.9, 6.1, //
  5.8, 5.6, 5.7, //
  5.8, 4.9, 6.1, 5.0, 6.4, 4.4, 3.8, // 7 derniers jours
];

/// Consommé aujourd'hui entre minuit et 13 h 35 (heure de [mockNow]).
const double mockTodayKwh = 2.9;

/// Historique daté : le dernier élément correspond à hier.
List<DailyConsumption> mockDailyConsumption() {
  final today = DateTime(mockNow.year, mockNow.month, mockNow.day);
  final n = _last30DaysKwh.length;
  return List.generate(
    n,
    (i) => DailyConsumption(
      date: today.subtract(Duration(days: n - i)),
      kwh: _last30DaysKwh[i],
    ),
  );
}