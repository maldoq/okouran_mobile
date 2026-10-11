import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../meter/domain/meter.dart';
import '../../data/mock_appliances.dart';
import '../../domain/appliance.dart';
import '../../domain/consumption_engine.dart';

/// Appareils enregistrés, par compteur (identifiant du compteur → liste).
/// Ajouter, modifier ou supprimer un appareil recalcule immédiatement la
/// prévision, la baisse du crédit et les conseils.
class AppliancesNotifier extends Notifier<Map<String, List<Appliance>>> {
  int _seq = 500;

  @override
  Map<String, List<Appliance>> build() => {
        for (final e in mockAppliances.entries) e.key: [...e.value],
      };

  String newId() => 'a${++_seq}';

  void add(String meterId, Appliance appliance) {
    state = {
      ...state,
      meterId: [...?state[meterId], appliance],
    };
  }

  /// Remplace un appareil existant (même identifiant).
  /// (Nommé `replace` et non `update` pour ne pas masquer une méthode de Notifier.)
  void replace(String meterId, Appliance appliance) {
    state = {
      ...state,
      meterId: [
        for (final a in state[meterId] ?? const <Appliance>[]) a.id == appliance.id ? appliance : a,
      ],
    };
  }

  void remove(String meterId, String applianceId) {
    state = {
      ...state,
      meterId: [
        for (final a in state[meterId] ?? const <Appliance>[])
          if (a.id != applianceId) a,
      ],
    };
  }

  /// Appareils par défaut pour un compteur qui vient d'être ajouté.
  void ensureDefaults(String meterId, MeterKind kind) {
    if ((state[meterId] ?? const []).isNotEmpty) return;
    state = {...state, meterId: defaultAppliancesFor(kind, meterId)};
  }
}

final appliancesProvider =
    NotifierProvider<AppliancesNotifier, Map<String, List<Appliance>>>(AppliancesNotifier.new);

/// Appareils d'un compteur.
final meterAppliancesProvider = Provider.family<List<Appliance>, String>(
    (ref, meterId) => ref.watch(appliancesProvider)[meterId] ?? const []);

/// Anomalies en cours, par compteur. `stop` = « Je l'ai éteint ».
class AnomaliesNotifier extends Notifier<Map<String, MeterAnomaly>> {
  @override
  Map<String, MeterAnomaly> build() => Map.of(demoAnomalies);

  void stop(String meterId, int minute) {
    final a = state[meterId];
    if (a == null || a.stopped) return;
    state = {...state, meterId: a.stopAt(minute)};
  }
}

final anomaliesProvider =
    NotifierProvider<AnomaliesNotifier, Map<String, MeterAnomaly>>(AnomaliesNotifier.new);
