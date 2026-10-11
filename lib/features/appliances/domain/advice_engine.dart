import 'dart:math' as math;

import 'appliance.dart';
import 'consumption_engine.dart';

/// Conseil urgent (consommation au-dessus de la prévision, fenêtre du soir).
class UrgentAdvice {
  const UrgentAdvice({
    required this.kind,
    required this.emoji,
    required this.title,
    required this.text,
    required this.kwhPerDay,
    required this.fcfaPerDay,
    required this.autonomyGainMinutes,
    this.applianceId,
  });

  final UrgentAdviceKind kind;
  final String emoji;
  final String title;
  final String text;
  final double kwhPerDay;
  final double fcfaPerDay;
  final double autonomyGainMinutes;

  /// Appareil concerné (pour l'action « Je l'ai éteint »).
  final String? applianceId;
}

enum UrgentAdviceKind {
  /// Éteindre l'appareil resté allumé (anomalie détectée).
  stopAppliance,

  /// Réduire l'usage de l'appareil qui pèse le plus en ce moment.
  reduceUsage,

  /// Limiter un appareil pendant la fenêtre 18 h – 22 h.
  eveningPeak,
}

/// Geste d'économie calculé pour un appareil enregistré.
class SavingTip {
  const SavingTip({required this.appliance, required this.kwhPerWeek, required this.autonomyGainMinutes});
  final Appliance appliance;
  final double kwhPerWeek;
  final double autonomyGainMinutes;

  String get title => appliance.type.tipTitle;
  String get detail => '${appliance.name} · ${appliance.dailyKwh.toStringAsFixed(1).replaceAll('.', ',')} kWh/j. ${appliance.type.tipDetail}';
}

/// Analyse de la journée et conseils classés pour un compteur.
class AdviceReport {
  const AdviceReport({
    required this.overConsumption,
    required this.pastOverConsumption,
    required this.vsPlan,
    required this.excessKwh,
    required this.urgent,
    required this.tips,
    required this.eveningShare,
  });

  /// La consommation dépasse la prévision ET l'écart se poursuit.
  final bool overConsumption;

  /// L'écart de la journée existe mais ne s'aggrave plus (cause corrigée).
  final bool pastOverConsumption;
  final double vsPlan;
  final double excessKwh;
  final List<UrgentAdvice> urgent;
  final List<SavingTip> tips;
  final double eveningShare;
}

/// Règles des conseils (identiques à la version HTML, fonction adviceFor).
abstract final class AdviceEngine {
  static AdviceReport analyse({
    required ConsumptionEngine engine,
    required List<Appliance> appliances,
    required double nowMinute,
    required double tariffPerKwh,
  }) {
    final t = nowMinute;
    final hour = math.min(23, math.max(0, t ~/ 60));
    final day = engine.today(t);
    final autonomy = engine.autonomyMinutes(t);
    final balance = engine.balanceAt(t);
    // Rythme actuel (kWh/h) = solde ÷ autonomie.
    final ratePerHour = math.max(0.05, balance / math.max(1, autonomy) * 60);

    final cumOver = day.vsPlan > 0.1 && day.consumedKwh - day.expectedSoFarKwh > 0.4;
    final recentAct = engine.consumed(math.max(0, t - 120), t);
    final recentExp = engine.consumed(math.max(0, t - 120), t, withAnomaly: false);
    final an = engine.anomaly;
    final handled = an != null && an.untilMinute != null && an.untilMinute! <= t;
    final over = cumOver && !handled && t >= 60 && recentAct > recentExp * 1.15 + 0.1;
    final anomalyActive = engine.anomalyActive(t);

    final urgent = <UrgentAdvice>[];
    if (anomalyActive && an != null) {
      Appliance? app;
      for (final a in appliances) {
        if (a.type == an.applianceType) {
          app = a;
          break;
        }
      }
      final kwhDay = an.extraKwhPerHour * 24;
      final from = '${an.fromMinute ~/ 60} h${an.fromMinute % 60 == 0 ? '' : ' ${(an.fromMinute % 60).toString().padLeft(2, '0')}'}';
      urgent.add(UrgentAdvice(
        kind: UrgentAdviceKind.stopAppliance,
        emoji: app?.type.emoji ?? '⚠️',
        title: app != null ? 'Éteignez « ${app.name} »' : 'Recherchez l’appareil resté allumé',
        text: app != null
            ? 'Il fonctionne sans interruption depuis $from, en dehors de ses horaires habituels (${app.usage.label.toLowerCase()}). C’est lui qui explique l’essentiel de l’écart.'
            : 'Un appareil non déclaré consomme en continu depuis la nuit.',
        kwhPerDay: kwhDay,
        fcfaPerDay: kwhDay * tariffPerKwh,
        autonomyGainMinutes: engine.autonomyIfAnomalyStopped(t) - autonomy,
        applianceId: app?.id,
      ));
    } else if (over && appliances.isNotEmpty) {
      final top = [...appliances]..sort((a, b) => (b.hourlyKwh[hour]).compareTo(a.hourlyKwh[hour]));
      final kwhDay = top.first.dailyKwh * 0.3;
      urgent.add(UrgentAdvice(
        kind: UrgentAdviceKind.reduceUsage,
        emoji: top.first.type.emoji,
        title: 'Réduisez l’usage de « ${top.first.name} »',
        text: 'C’est l’appareil qui pèse le plus en ce moment. Réduire son usage de 30 % ramène votre journée vers la prévision.',
        kwhPerDay: kwhDay,
        fcfaPerDay: kwhDay * tariffPerKwh,
        autonomyGainMinutes: kwhDay / ratePerHour * 60,
        applianceId: top.first.id,
      ));
    }

    // Fenêtre sensible : appareils qui pèsent le plus entre 18 h et 22 h.
    double evening(Appliance a) => a.hourlyKwh.sublist(18, 22).fold<double>(0, (s, v) => s + v);
    final byEvening = [...appliances]..sort((a, b) => evening(b).compareTo(evening(a)));
    if (hour >= 16 && hour < 22 && byEvening.isNotEmpty && evening(byEvening.first) > 0.2) {
      final top = byEvening.first;
      final totalEvening = byEvening.fold<double>(0, (s, a) => s + evening(a));
      final kwhDay = evening(top) * 0.25;
      urgent.add(UrgentAdvice(
        kind: UrgentAdviceKind.eveningPeak,
        emoji: top.type.emoji,
        title: 'Ce soir, limitez « ${top.name} »',
        text: 'Entre 18 h et 22 h il représente ${(evening(top) / math.max(0.1, totalEvening) * 100).round()} % de la consommation du soir. Une heure de moins suffit à gagner de l’autonomie.',
        kwhPerDay: kwhDay,
        fcfaPerDay: kwhDay * tariffPerKwh,
        autonomyGainMinutes: kwhDay / ratePerHour * 60,
        applianceId: top.id,
      ));
    }

    final tips = [
      for (final a in appliances)
        if (a.dailyKwh * a.type.savingRatio * 7 >= 0.1)
          SavingTip(
            appliance: a,
            kwhPerWeek: a.dailyKwh * a.type.savingRatio * 7,
            autonomyGainMinutes: a.dailyKwh * a.type.savingRatio * 7 / ratePerHour * 60,
          ),
    ]..sort((x, y) => y.kwhPerWeek.compareTo(x.kwhPerWeek));

    return AdviceReport(
      overConsumption: over || anomalyActive,
      pastOverConsumption: cumOver && !over && !anomalyActive,
      vsPlan: day.vsPlan,
      excessKwh: math.max(0, day.consumedKwh - day.expectedSoFarKwh),
      urgent: urgent,
      tips: tips,
      eveningShare: engine.eveningShare,
    );
  }
}
