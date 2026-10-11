import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_consumption.dart';
import '../../domain/daily_consumption.dart';

/// 30 derniers jours de consommation (compteur principal, simulé).
final dailyConsumptionProvider =
    Provider<List<DailyConsumption>>((ref) => mockDailyConsumption());

/// Indicateurs calculés à partir de l'historique.
final consumptionStatsProvider = Provider<ConsumptionStats>((ref) {
  final days = ref.watch(dailyConsumptionProvider);
  final last7 = days.sublist(days.length - 7);
  double avg(List<DailyConsumption> l) =>
      l.fold<double>(0, (s, d) => s + d.kwh) / l.length;
  return ConsumptionStats(
    todayKwh: mockTodayKwh,
    last7Days: last7,
    average7Days: avg(last7),
    average30Days: avg(days),
  );
});