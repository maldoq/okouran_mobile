import 'meter.dart';

/// Ce qu'un montant de recharge rapporte sur un compteur donné.
///
/// Trois étapes de calcul :
///   1. kWh achetés      = montant ÷ tarif du kWh ;
///   2. rythme actuel     = solde ÷ autonomie (kWh consommés par heure,
///                          déduit de la prévision du compteur) ;
///   3. jours gagnés      = kWh achetés ÷ rythme actuel.
class RechargeQuote {
  const RechargeQuote({
    required this.meter,
    required this.amountFcfa,
    required this.now,
    this.serviceFeeFcfa = 0,
  });

  final Meter meter;
  final int amountFcfa;
  final DateTime now;

  /// Frais de service (0 dans la maquette).
  final int serviceFeeFcfa;

  /// 1. kWh achetés. Ex. 5 000 F ÷ 73 F/kWh = 68,5 kWh.
  double get kwhBought => amountFcfa / meter.tariffPerKwh;

  /// 2. Rythme de consommation en kWh par heure.
  /// Ex. 18,6 kWh ÷ 80 h = 0,2325 kWh/h, soit ≈ 5,6 kWh par jour.
  double get kwhPerHour => meter.balanceKwh / (meter.autonomy.inMinutes / 60);

  double get kwhPerDay => kwhPerHour * 24;

  /// 3. Autonomie gagnée. Ex. 68,5 kWh ÷ 0,2325 kWh/h ≈ 295 h ≈ 12 j 7 h.
  Duration get addedAutonomy =>
      Duration(minutes: (kwhBought / kwhPerHour * 60).round());

  double get totalKwh => meter.balanceKwh + kwhBought;

  Duration get newAutonomy => meter.autonomy + addedAutonomy;

  DateTime get newCutoff => now.add(newAutonomy);

  int get totalToPay => amountFcfa + serviceFeeFcfa;

  /// Montant conseillé pour gagner [days] jours, arrondi aux 100 F supérieurs.
  /// Ex. 7 j × 5,58 kWh/j × 73 F ≈ 2 851 F → 2 900 F.
  static int amountForDays(Meter meter, int days) {
    final perHour = meter.balanceKwh / (meter.autonomy.inMinutes / 60);
    final raw = days * 24 * perHour * meter.tariffPerKwh;
    return ((raw / 100).ceil()) * 100;
  }
}