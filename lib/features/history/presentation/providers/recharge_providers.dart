import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../meter/presentation/providers/meter_providers.dart';
import '../../data/mock_recharges.dart';
import '../../domain/recharge.dart';

/// Toutes les recharges, de la plus récente à la plus ancienne.
/// Une recharge payée dans l'app est ajoutée en tête de liste.
class RechargesNotifier extends Notifier<List<Recharge>> {
  @override
  List<Recharge> build() =>
      [...mockRecharges]..sort((a, b) => b.date.compareTo(a.date));

  void add(Recharge recharge) => state = [recharge, ...state];
}

final rechargesProvider =
    NotifierProvider<RechargesNotifier, List<Recharge>>(RechargesNotifier.new);

/// Recharges des compteurs de l'utilisateur connecté uniquement.
final userRechargesProvider = Provider<List<Recharge>>((ref) {
  final ids = {for (final m in ref.watch(liveMetersProvider)) m.id};
  return ref.watch(rechargesProvider).where((r) => ids.contains(r.meterId)).toList();
});

/// Filtre par compteur sur l'onglet Recharges (null = tous les compteurs).
final rechargeMeterFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

/// Recharges après filtre.
final filteredRechargesProvider = Provider.autoDispose<List<Recharge>>((ref) {
  final filter = ref.watch(rechargeMeterFilterProvider);
  final all = ref.watch(userRechargesProvider);
  return filter == null ? all : all.where((r) => r.meterId == filter).toList();
});

/// Recharges réussies d'un compteur, indexées par jour (pour marquer
/// les jours de recharge dans l'historique de consommation).
final rechargesByDayProvider =
    Provider.family<Map<DateTime, double>, String>((ref, meterId) {
  final map = <DateTime, double>{};
  for (final r in ref.watch(rechargesProvider)) {
    if (r.meterId != meterId || r.status != RechargeStatus.success) continue;
    final day = DateTime(r.date.year, r.date.month, r.date.day);
    map[day] = (map[day] ?? 0) + (r.kwh ?? 0);
  }
  return map;
});