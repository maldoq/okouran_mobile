import 'dart:math' as math;

import 'appliance.dart';

/// Surconsommation anormale : un appareil resté en marche hors de ses horaires.
class MeterAnomaly {
  const MeterAnomaly({
    required this.applianceType,
    required this.extraKwhPerHour,
    required this.fromMinute,
    this.untilMinute,
  });

  /// Type de l'appareil en cause (sert à nommer l'appareil dans les conseils).
  final ApplianceType applianceType;

  /// kWh consommés en plus chaque heure, tant que l'anomalie dure.
  final double extraKwhPerHour;

  /// Minute de la journée où elle commence (120 = 2 h du matin).
  final int fromMinute;

  /// Minute où l'utilisateur a éteint l'appareil (null = toujours en cours).
  final int? untilMinute;

  bool get stopped => untilMinute != null;

  MeterAnomaly stopAt(int minute) => MeterAnomaly(
      applianceType: applianceType, extraKwhPerHour: extraKwhPerHour, fromMinute: fromMinute, untilMinute: minute);
}

/// Consommation d'une heure de la journée : prévue (appareils) et réelle.
class HourPoint {
  const HourPoint(this.hour, this.expectedKwh, this.actualKwh, {this.partial = false});
  final int hour;
  final double expectedKwh;

  /// null pour les heures à venir.
  final double? actualKwh;

  /// Heure en cours (valeur partielle).
  final bool partial;
}

/// Bilan de la journée à l'instant présent.
class TodaySummary {
  const TodaySummary({
    required this.consumedKwh,
    required this.expectedSoFarKwh,
    required this.expectedDayKwh,
    required this.projectedDayKwh,
  });

  final double consumedKwh;
  final double expectedSoFarKwh;
  final double expectedDayKwh;

  /// Consommation projetée en fin de journée si rien ne change.
  final double projectedDayKwh;

  /// Écart à la prévision (+0,35 = 35 % au-dessus).
  double get vsPlan => expectedSoFarKwh > 0.05 ? consumedKwh / expectedSoFarKwh - 1 : 0;
}

/// Moteur de consommation d'un compteur pour la journée simulée.
///
/// Toutes les minutes sont comptées depuis minuit (0 à 1439).
///   1. consommation prévue heure par heure = somme des appareils enregistrés,
///      répartis selon leur plage d'utilisation (pic 18 h – 22 h) ;
///   2. consommation réelle = prévue + anomalie éventuelle ;
///   3. solde = solde à minuit (+ recharges) − consommation depuis minuit ;
///   4. autonomie (« modèle profilé ») : on fait avancer le temps heure par
///      heure avec le profil prévu — et l'anomalie si elle est en cours —
///      jusqu'à épuisement du crédit.
///
/// Calculs identiques à la version HTML (fonctions consumed, simulateAutonomy,
/// anomalyDetectMin, stats).
class ConsumptionEngine {
  ConsumptionEngine({
    required List<Appliance> appliances,
    required this.balanceAtMidnightKwh,
    this.anomaly,
  }) : expectedHourly = _expected(appliances);

  /// Solde à minuit, recharges du jour comprises (kWh).
  final double balanceAtMidnightKwh;
  final MeterAnomaly? anomaly;

  /// Consommation prévue par heure (kWh), index 0 = minuit.
  final List<double> expectedHourly;

  static List<double> _expected(List<Appliance> apps) {
    final e = List<double>.filled(24, 0);
    for (final a in apps) {
      final h = a.hourlyKwh;
      for (var i = 0; i < 24; i++) {
        e[i] += h[i];
      }
    }
    return e;
  }

  double get expectedDailyKwh => expectedHourly.fold<double>(0, (s, v) => s + v);

  /// Part de la journée consommée entre 18 h et 22 h.
  double get eveningShare =>
      expectedDailyKwh <= 0 ? 0 : expectedHourly.sublist(18, 22).fold<double>(0, (s, v) => s + v) / expectedDailyKwh;

  int _hourOf(double minute) => ((minute ~/ 60) % 24 + 24) % 24;

  /// Consommation entre deux minutes de la journée (kWh).
  double consumed(double from, double to, {bool withAnomaly = true}) {
    if (to <= from) return 0;
    var t = from;
    var total = 0.0;
    final an = anomaly;
    while (t < to - 1e-9) {
      final next = math.min(to, ((t / 60).floor() + 1) * 60.0);
      total += expectedHourly[_hourOf(t)] * (next - t) / 60;
      if (withAnomaly && an != null) {
        final s = math.max(t, an.fromMinute.toDouble());
        final e = math.min(next, (an.untilMinute ?? 1 << 30).toDouble());
        if (e > s) total += an.extraKwhPerHour * (e - s) / 60;
      }
      t = next;
    }
    return total;
  }

  /// Solde à une minute donnée de la journée (kWh, jamais négatif).
  double balanceAt(double minute) => math.max(0, balanceAtMidnightKwh - consumed(0, minute));

  bool _anomalyRunningAt(double minute) {
    final an = anomaly;
    return an != null && an.fromMinute <= minute && (an.untilMinute == null || an.untilMinute! > minute);
  }

  /// Autonomie restante à l'instant [now] (minutes), selon le modèle profilé.
  double autonomyMinutes(double now, {bool ignoreAnomaly = false}) {
    var b = balanceAt(now);
    if (b <= 0) return 0;
    final anomalyOn = !ignoreAnomaly && _anomalyRunningAt(now);
    var t = now;
    for (var guard = 0; guard < 24 * 90; guard++) {
      final next = ((t / 60).floor() + 1) * 60.0;
      final rate = (expectedHourly[_hourOf(t)] + (anomalyOn ? anomaly!.extraKwhPerHour : 0)) / 60;
      if (rate <= 0) {
        t = next;
        continue;
      }
      final c = rate * (next - t);
      if (c >= b) return t + b / rate - now;
      b -= c;
      t = next;
    }
    return t - now;
  }

  /// Autonomie si l'appareil en cause est éteint maintenant.
  double autonomyIfAnomalyStopped(double now) => autonomyMinutes(now, ignoreAnomaly: true);

  /// Minute de détection de l'anomalie : écart cumulé ≥ 0,8 kWh et ≥ 15 %
  /// de la consommation prévue. null si aucune anomalie.
  int? anomalyDetectMinute() {
    final an = anomaly;
    if (an == null) return null;
    for (var t = an.fromMinute; t < 1440; t += 15) {
      final exp = consumed(0, t.toDouble(), withAnomaly: false);
      final excess = consumed(0, t.toDouble()) - exp;
      if (excess >= 0.8 && excess >= 0.15 * exp) {
        return (an.untilMinute != null && an.untilMinute! < t) ? null : t;
      }
    }
    return null;
  }

  bool anomalyDetected(double now) {
    final d = anomalyDetectMinute();
    return d != null && now >= d;
  }

  /// Anomalie détectée et toujours en cours (appareil pas encore éteint).
  bool anomalyActive(double now) => anomaly != null && !anomaly!.stopped && anomalyDetected(now);

  TodaySummary today(double now) => TodaySummary(
        consumedKwh: consumed(0, now),
        expectedSoFarKwh: consumed(0, now, withAnomaly: false),
        expectedDayKwh: expectedDailyKwh,
        projectedDayKwh: consumed(0, now) + consumed(now, 1440),
      );

  /// Réel et prévu, heure par heure (réel null pour les heures à venir).
  List<HourPoint> todayHourly(double now) => [
        for (var h = 0; h < 24; h++)
          HourPoint(
            h,
            expectedHourly[h],
            h * 60 < now ? consumed(h * 60.0, math.min(now, h * 60.0 + 60)) : null,
            partial: now < h * 60 + 60,
          ),
      ];

  /// 30 journées complètes simulées autour de la prévision (± 8 %, déterministe).
  List<double> history30(String seedKey) {
    final seed = seedKey.codeUnits.fold<int>(0, (s, c) => s + c);
    double noise(int i) {
      final x = math.sin(seed * 97.13 + i * 12.9898) * 43758.5453;
      return (x - x.floorToDouble()) * 2 - 1;
    }

    return [
      for (var i = 0; i < 30; i++)
        math.max(0.2, expectedDailyKwh * (1 + 0.08 * noise(i) + (i % 7 == 6 ? 0.06 : 0))),
    ];
  }
}
