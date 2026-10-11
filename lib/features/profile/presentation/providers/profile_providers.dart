import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../history/domain/recharge.dart';
import '../../../history/presentation/providers/recharge_providers.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../../notifications/domain/app_alert.dart';
import '../../../notifications/presentation/providers/alerts_provider.dart';
import '../../domain/app_settings.dart';
import '../../domain/notification_settings.dart';

/// Réglages des alertes (en mémoire pour la maquette).
final notificationSettingsProvider = StateProvider<NotificationSettings>(
    (ref) => const NotificationSettings());

/// Réglages généraux (données, accessibilité, sécurité).
final appSettingsProvider =
    StateProvider<AppSettings>((ref) => const AppSettings());

/// Objectif d'autonomie qui vaut 100 % sur les jauges (7 jours par défaut).
final autonomyTargetProvider = Provider<Duration>((ref) =>
    Duration(days: ref.watch(appSettingsProvider).autonomyTargetDays));

/// Les trois chiffres du profil.
class ProfileStats {
  const ProfileStats({
    required this.meters,
    required this.recharges,
    required this.avoidedCutoffs,
  });

  final int meters;

  /// Recharges réussies.
  final int recharges;

  /// Coupures évitées = alertes de crédit faible, critique ou de coupure
  /// imminente qui ont été suivies d'une recharge (alerte « réglée »).
  final int avoidedCutoffs;
}

final profileStatsProvider = Provider<ProfileStats>((ref) {
  const creditAlerts = {
    AlertType.lowCredit,
    AlertType.criticalCredit,
    AlertType.imminentCutoff,
  };
  return ProfileStats(
    meters: ref.watch(liveMetersProvider).length,
    recharges: ref
        .watch(userRechargesProvider)
        .where((r) => r.status == RechargeStatus.success)
        .length,
    avoidedCutoffs: ref
        .watch(alertsProvider)
        .where((a) => creditAlerts.contains(a.type) && a.isResolved)
        .length,
  );
});