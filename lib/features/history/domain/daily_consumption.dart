/// Consommation d'une journée complète.
class DailyConsumption {
  const DailyConsumption({required this.date, required this.kwh});

  final DateTime date;
  final double kwh;
}

/// Indicateurs affichés sur le tableau de bord.
class ConsumptionStats {
  const ConsumptionStats({
    required this.todayKwh,
    required this.last7Days,
    required this.average7Days,
    required this.average30Days,
  });

  /// Consommé aujourd'hui depuis minuit.
  final double todayKwh;

  /// Les 7 dernières journées complètes (de la plus ancienne à hier).
  final List<DailyConsumption> last7Days;

  /// Moyenne par jour sur les 7 derniers jours.
  final double average7Days;

  /// Moyenne par jour sur les 30 derniers jours : « votre habitude ».
  final double average30Days;

  /// Total des 7 derniers jours.
  double get weekTotal => last7Days.fold(0, (s, d) => s + d.kwh);

  /// Écart à l'habitude = moyenne 7 j ÷ moyenne 30 j − 1.
  /// Négatif : vous consommez moins que d'habitude.
  double get vsUsual => average7Days / average30Days - 1;
}