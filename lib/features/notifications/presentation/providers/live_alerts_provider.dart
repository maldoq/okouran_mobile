import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/clock/demo_clock_provider.dart';
import '../../../appliances/domain/appliance.dart';
import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../../../meter/domain/meter.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../domain/anomaly.dart';
import '../../domain/app_alert.dart';

/// Identifiants des alertes du jour déjà lues / closes.
final liveAlertReadProvider = StateProvider<Set<String>>((ref) => <String>{});
final liveAlertResolvedProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Alertes du jour, calculées à l'heure simulée pour l'utilisateur connecté :
///   - « Consommation inhabituelle » dès que l'anomalie est détectée ;
///   - « Crédit faible » (24 – 48 h) et « Crédit critique » (< 24 h).
/// À fusionner avec l'historique (alertsProvider) dans le centre d'alertes :
///   final all = [...ref.watch(liveAlertsProvider), ...ref.watch(alertsProvider)];
final liveAlertsProvider = Provider<List<AppAlert>>((ref) {
  final now = ref.watch(demoClockProvider);
  final minute = ref.watch(demoMinuteProvider);
  final read = ref.watch(liveAlertReadProvider);
  final resolved = ref.watch(liveAlertResolvedProvider);
  final out = <AppAlert>[];

  for (final m in ref.watch(liveMetersProvider)) {
    final engine = ref.watch(consumptionEngineProvider(m.id));
    final detect = engine.anomalyDetectMinute();
    if (engine.anomaly != null && detect != null && minute >= detect) {
      final id = 'live-ano-${m.id}';
      final pct = (engine.today(minute).vsPlan * 100).round();
      out.add(AppAlert(
        id: id,
        type: AlertType.anomaly,
        title: 'Consommation inhabituelle',
        detail: '+$pct % vs prévu',
        meterName: m.name,
        date: DemoClock.day.add(Duration(minutes: detect)),
        isRead: read.contains(id),
        isResolved: resolved.contains(id) || engine.anomaly!.stopped,
      ));
    }
    final risk = m.risk;
    if (risk != RiskLevel.low) {
      final id = 'live-${risk.name}-${m.id}';
      out.add(AppAlert(
        id: id,
        type: risk == RiskLevel.high ? AlertType.criticalCredit : AlertType.lowCredit,
        title: risk.creditLabel,
        detail: '≈ ${m.autonomy.inHours} h restantes',
        meterName: m.name,
        date: now,
        isRead: read.contains(id),
      ));
    }
  }
  out.sort((a, b) => b.date.compareTo(a.date));
  return out;
});

/// Anomalie du jour (pour l'écran « Consommation anormale »), construite à
/// partir du moteur : 6 derniers jours + aujourd'hui (projection), bande
/// habituelle = prévision des appareils ± 10 %, causes classées.
/// null si aucune anomalie n'est détectée à l'heure simulée.
final liveAnomalyProvider = Provider<Anomaly?>((ref) {
  final minute = ref.watch(demoMinuteProvider);
  final selected = ref.watch(selectedMeterProvider);
  final meters = [selected, ...ref.watch(liveMetersProvider).where((m) => m.id != selected.id)];

  for (final Meter m in meters) {
    final engine = ref.watch(consumptionEngineProvider(m.id));
    final detect = engine.anomalyDetectMinute();
    if (engine.anomaly == null || detect == null || minute < detect) continue;

    final apps = ref.watch(meterAppliancesProvider(m.id));
    Appliance? culprit;
    for (final a in apps) {
      if (a.type == engine.anomaly!.applianceType) culprit = a;
    }
    final others = [...apps]..remove(culprit);
    others.sort((a, b) => b.dailyKwh.compareTo(a.dailyKwh));
    final usual = engine.expectedDailyKwh;
    final history = engine.history30(m.id);
    final today = engine.today(minute).projectedDayKwh;

    return Anomaly(
      alertId: 'live-ano-${m.id}',
      meterName: m.name,
      detectedAt: DemoClock.day.add(Duration(minutes: detect)),
      days: [for (var d = 6; d >= 0; d--) DemoClock.day.subtract(Duration(days: d))],
      dayKwh: [...history.sublist(history.length - 6), today],
      usualKwh: usual,
      bandLow: usual * 0.9,
      bandHigh: usual * 1.1,
      causes: [
        AnomalyCause(
          id: 'appliance',
          title: culprit != null ? '« ${culprit.name} » resté en marche' : 'Appareil resté en marche',
          evidence: 'Consommation continue depuis ${engine.anomaly!.fromMinute ~/ 60} h, hors de ses horaires habituels',
          likelihood: CauseLikelihood.probable,
        ),
        if (others.isNotEmpty)
          AnomalyCause(
            id: 'device',
            title: '« ${others.first.name} » plus gourmand',
            evidence: 'Possible si la hausse est régulière sur la journée',
            likelihood: CauseLikelihood.possible,
          ),
        const AnomalyCause(
          id: 'tap',
          title: 'Branchement non autorisé',
          evidence: "Hausse persistante sans changement d'usage",
          likelihood: CauseLikelihood.toCheck,
        ),
        const AnomalyCause(
          id: 'reading',
          title: 'Erreur de relevé du compteur',
          evidence: 'Aucun écart de télérelevé constaté',
          likelihood: CauseLikelihood.unlikely,
        ),
      ],
    );
  }
  return null;
});
