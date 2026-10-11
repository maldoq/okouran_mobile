import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../meter/presentation/providers/meter_providers.dart';
import '../../data/mock_alerts.dart';
import '../../domain/app_alert.dart';
import 'live_alerts_provider.dart';

/// Historique modifiable (alertes passées des comptes de démonstration).
final alertHistoryProvider = StateProvider<List<AppAlert>>((ref) => [...mockAlerts]);

/// Alertes de l'utilisateur connecté, de la plus récente à la plus ancienne :
/// alertes du jour calculées à l'heure simulée (liveAlertsProvider) +
/// historique limité aux compteurs de l'utilisateur.
/// L'API (markRead, resolve, markAllRead) est inchangée pour les écrans.
class AlertsNotifier extends Notifier<List<AppAlert>> {
  @override
  List<AppAlert> build() {
    final names = {for (final m in ref.watch(liveMetersProvider)) m.name};
    final history = ref.watch(alertHistoryProvider).where((a) => names.contains(a.meterName));
    return [...ref.watch(liveAlertsProvider), ...history]..sort((a, b) => b.date.compareTo(a.date));
  }

  bool _isLive(String id) => id.startsWith('live-');

  void markRead(String id) {
    if (_isLive(id)) {
      final s = ref.read(liveAlertReadProvider.notifier);
      s.state = {...s.state, id};
      return;
    }
    final h = ref.read(alertHistoryProvider.notifier);
    h.state = [for (final a in h.state) a.id == id ? a.copyWith(isRead: true) : a];
  }

  /// Clôt une alerte (cause indiquée par l'utilisateur, recharge faite…).
  void resolve(String id) {
    if (_isLive(id)) {
      final r = ref.read(liveAlertResolvedProvider.notifier);
      r.state = {...r.state, id};
      markRead(id);
      return;
    }
    final h = ref.read(alertHistoryProvider.notifier);
    h.state = [for (final a in h.state) a.id == id ? a.copyWith(isRead: true, isResolved: true) : a];
  }

  void markAllRead() {
    final live = ref.read(liveAlertReadProvider.notifier);
    live.state = {...live.state, for (final a in state) if (_isLive(a.id)) a.id};
    final h = ref.read(alertHistoryProvider.notifier);
    h.state = [for (final a in h.state) a.copyWith(isRead: true)];
  }
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<AppAlert>>(AlertsNotifier.new);

/// Nombre d'alertes non lues (pastille de la cloche).
final unreadAlertsCountProvider =
    Provider<int>((ref) => ref.watch(alertsProvider).where((a) => !a.isRead).length);

/// Alertes à traiter (épinglées en haut du centre d'alertes).
final actionAlertsProvider =
    Provider<List<AppAlert>>((ref) => ref.watch(alertsProvider).where((a) => a.needsAction).toList());

/// Toutes les autres alertes (historique).
final pastAlertsProvider =
    Provider<List<AppAlert>>((ref) => ref.watch(alertsProvider).where((a) => !a.needsAction).toList());
