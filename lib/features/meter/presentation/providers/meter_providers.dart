import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/clock/demo_clock_provider.dart';
import '../../../appliances/domain/advice_engine.dart';
import '../../../appliances/domain/consumption_engine.dart';
import '../../../appliances/presentation/providers/appliances_provider.dart';
import '../../../auth/data/mock_auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/mock_meters.dart';
import '../../domain/meter.dart';

/// Liste des compteurs de l'utilisateur (modifiable : renommer, retirer).
class MetersNotifier extends Notifier<List<Meter>> {
  @override
  List<Meter> build() => mockMeters;

  void rename(String id, String name) {
    state = [
      for (final m in state) m.id == id ? m.copyWith(name: name) : m,
    ];
  }

  /// Crédite un compteur après une recharge réussie :
  /// nouveau solde, nouvelle autonomie, nouvelle date de coupure.
  void applyRecharge(String id,
      {required double kwh,
      required Duration autonomy,
      required DateTime cutoff}) {
    state = [
      for (final m in state)
        m.id == id
            ? m.copyWith(
                balanceKwh: m.balanceKwh + kwh,
                autonomy: autonomy,
                estimatedCutoff: cutoff,
              )
            : m,
    ];
  }

  /// Ajoute un compteur en fin de liste.
  void add(Meter meter) => state = [...state, meter];

  /// Retire un compteur. On en garde toujours au moins un dans la maquette.
  void remove(String id) {
    if (state.length <= 1) return;
    state = state.where((m) => m.id != id).toList();
  }
}

final metersProvider =
    NotifierProvider<MetersNotifier, List<Meter>>(MetersNotifier.new);

// ============================================================================
// Compteurs « en direct » : solde, autonomie et heure de coupure recalculés à
// l'heure simulée, à partir des appareils enregistrés (moteur de consommation).
//
// Dans `metersProvider`, `balanceKwh` = solde à minuit + recharges du jour.
// Dans `liveMetersProvider`, `balanceKwh` = solde à l'instant présent.
// Les écrans lisent `liveMetersProvider` ; les actions (renommer, recharger,
// ajouter, retirer) passent toujours par `metersProvider.notifier`.
// ============================================================================

/// Moteur de consommation d'un compteur (appareils + anomalie éventuelle).
final consumptionEngineProvider = Provider.family<ConsumptionEngine, String>((ref, meterId) {
  final stored = ref.watch(metersProvider).firstWhere((m) => m.id == meterId,
      orElse: () => ref.watch(metersProvider).first);
  return ConsumptionEngine(
    appliances: ref.watch(meterAppliancesProvider(meterId)),
    balanceAtMidnightKwh: stored.balanceKwh,
    anomaly: ref.watch(anomaliesProvider)[meterId],
  );
});

/// Compteurs de l'utilisateur connecté, à l'heure simulée.
final liveMetersProvider = Provider<List<Meter>>((ref) {
  final now = ref.watch(demoClockProvider);
  final minute = ref.watch(demoMinuteProvider);
  final user = ref.watch(currentUserProvider) ?? mockUser;

  Meter live(Meter m) {
    final engine = ref.watch(consumptionEngineProvider(m.id));
    final autonomy = Duration(minutes: engine.autonomyMinutes(minute).round());
    return m.copyWith(
      balanceKwh: engine.balanceAt(minute),
      autonomy: autonomy,
      estimatedCutoff: now.add(autonomy),
    );
  }

  return [
    for (final m in ref.watch(metersProvider))
      if (m.ownerId == null || m.ownerId == user.id) live(m),
  ];
});

/// Conseils et analyse de la journée pour un compteur.
final adviceProvider = Provider.family<AdviceReport, String>((ref, meterId) {
  final meter = ref.watch(metersProvider).firstWhere((m) => m.id == meterId,
      orElse: () => ref.watch(metersProvider).first);
  return AdviceEngine.analyse(
    engine: ref.watch(consumptionEngineProvider(meterId)),
    appliances: ref.watch(meterAppliancesProvider(meterId)),
    nowMinute: ref.watch(demoMinuteProvider),
    tariffPerKwh: meter.tariffPerKwh,
  );
});

/// Bilan de la journée (consommé, prévu, projection) pour un compteur.
final todaySummaryProvider = Provider.family<TodaySummary, String>(
    (ref, meterId) => ref.watch(consumptionEngineProvider(meterId)).today(ref.watch(demoMinuteProvider)));

/// Identifiant du compteur affiché sur le tableau de bord.
final selectedMeterIdProvider =
    StateProvider<String>((ref) => mockMeters.first.id);

/// Compteur affiché sur le tableau de bord, à l'heure simulée
/// (le premier compteur de l'utilisateur si le compteur choisi n'est pas à lui).
final selectedMeterProvider = Provider<Meter>((ref) {
  final id = ref.watch(selectedMeterIdProvider);
  final meters = ref.watch(liveMetersProvider);
  // Nouvel utilisateur sans compteur : on évite l'erreur en montrant le premier
  // compteur connu ; l'écran d'accueil invite à ajouter le sien.
  if (meters.isEmpty) return ref.watch(metersProvider).first;
  return meters.firstWhere((m) => m.id == id, orElse: () => meters.first);
});

/// Un compteur par identifiant (écran de détail), null s'il n'existe plus.
final meterByIdProvider = Provider.family<Meter?, String>((ref, id) {
  for (final m in ref.watch(liveMetersProvider)) {
    if (m.id == id) return m;
  }
  return null;
});
