import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../auth/data/mock_auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../history/presentation/providers/consumption_providers.dart';
import '../../../meter/data/mock_meters.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../widgets/lock_screen_preview.dart';

/// Les deux aperçus de notification de la maquette.
enum AlertPreviewKind { lowCredit, critical }

/// Écrans 16 et 17 : ce que l'utilisateur reçoit sur son écran verrouillé.
///
/// - Crédit faible : notification avec l'autonomie en jours et heures
///   (plus parlant qu'un pourcentage), et un résumé de la semaine.
/// - Crédit critique : l'heure de coupure annoncée, doublée d'un SMS
///   (si l'option est activée dans le profil), car la notification
///   suppose une connexion de données.
class AlertPreviewScreen extends ConsumerWidget {
  const AlertPreviewScreen({super.key, required this.kind});

  final AlertPreviewKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: kind == AlertPreviewKind.lowCredit
            ? _lowCredit(context, ref)
            : _critical(context, ref),
      ),
    );
  }

  // ---------------- Crédit faible ----------------

  /// Rejoue l'alerte du 5 octobre à 19 h 15 sur Maison Cocody (alerte a4).
  /// Autonomie restante : 1 j 2 h = 26 h.
  /// kWh restants = 26 h × rythme (18,6 kWh ÷ 80 h = 0,2325 kWh/h) ≈ 6,0 kWh.
  Widget _lowCredit(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(liveMetersProvider).firstWhere((m) => m.id == 'm1',
        orElse: () => ref.watch(selectedMeterProvider));
    const remaining = Duration(days: 1, hours: 2);
    final perHour = meter.kwhPerDay / 24;
    final kwhLeft = remaining.inMinutes / 60 * perHour;

    // Résumé : 7 derniers jours comparés aux 7 jours précédents.
    final days = ref.watch(dailyConsumptionProvider);
    final week = days.sublist(days.length - 7).fold<double>(0, (s, d) => s + d.kwh);
    final previous = days
        .sublist(days.length - 14, days.length - 7)
        .fold<double>(0, (s, d) => s + d.kwh);
    final delta = week / previous - 1;

    return LockScreenPreview(
      time: DateTime(2026, 10, 5, 19, 15),
      onClose: () => context.pop(),
      notifications: [
        PushCard(
          icon: Icons.battery_alert_rounded,
          tone: BadgeTone.warning,
          title: 'Crédit faible · ${meter.name}',
          body: 'Il reste **${Fmt.kwh(kwhLeft)} kWh**, soit environ '
              '**${Fmt.duration(remaining)}** au rythme actuel. '
              'Pensez à recharger.',
          actions: [
            PushAction('Recharger', () => _recharge(context, ref, meter.id),
                color: AppColors.primary),
            PushAction('Plus tard', () => _later(context)),
          ],
        ),
        PushCard(
          icon: Icons.bar_chart_rounded,
          tone: BadgeTone.info,
          showStripe: false,
          title: 'Résumé de la semaine',
          source: 'O\'kouran · hier',
          body: 'Vous avez consommé **${Fmt.kwh(week)} kWh**, soit '
              '${Fmt.percentDelta(delta)} par rapport à la semaine précédente '
              '(${Fmt.kwh(previous)} kWh).',
        ),
      ],
    );
  }

  // ---------------- Crédit critique ----------------

  /// Résidence familiale à l'instant présent : 4,1 kWh, ≈ 21 h d'autonomie,
  /// coupure estimée demain vers 10 h 35.
  Widget _critical(BuildContext context, WidgetRef ref) {
    final meters = ref.watch(liveMetersProvider);
    final meter = meters.firstWhere((m) => m.id == 'm3',
        orElse: () => ref.watch(selectedMeterProvider));
    final smsOn = ref.watch(notificationSettingsProvider).sms;
    final user = ref.watch(currentUserProvider) ?? mockUser;

    final tomorrow = mockNow.add(const Duration(days: 1));
    final sameDayTomorrow = meter.estimatedCutoff.year == tomorrow.year &&
        meter.estimatedCutoff.month == tomorrow.month &&
        meter.estimatedCutoff.day == tomorrow.day;
    final when = sameDayTomorrow
        ? 'demain vers ${Fmt.time(meter.estimatedCutoff)}'
        : '${Fmt.dayMedium(meter.estimatedCutoff)} vers '
            '${Fmt.time(meter.estimatedCutoff)}';

    // Un éventuel compteur en crédit faible, cité en 3e notification.
    final others = meters
        .where((m) => m.id != meter.id && m.autonomy.inHours < 48)
        .toList();

    return LockScreenPreview(
      time: mockNow,
      tint: const Color(0xFF2A0D0C),
      onClose: () => context.pop(),
      notifications: [
        PushCard(
          icon: Icons.power_off_rounded,
          tone: BadgeTone.danger,
          title: 'Risque de coupure · ${meter.name}',
          body: 'Crédit à **${Fmt.kwh(meter.balanceKwh)} kWh**. Selon votre '
              'consommation, l\'électricité pourrait être coupée **$when**.',
          actions: [
            PushAction('Recharger', () => _recharge(context, ref, meter.id),
                color: AppColors.danger),
            if (meter.sharedWith != null)
              PushAction('Prévenir la famille', () {
                _snack(context,
                    'Message simulé envoyé aux personnes qui suivent ce compteur.');
              }),
          ],
        ),
        if (smsOn)
          PushCard(
            icon: Icons.sms_outlined,
            tone: BadgeTone.danger,
            showStripe: false,
            title: 'SMS envoyé au ${PhoneField.format(user.phone, withPrefix: false)}',
            body: 'Alerte critique doublée par SMS : reçue même sans '
                'connexion de données.',
          ),
        for (final o in others)
          PushCard(
            icon: Icons.battery_alert_rounded,
            tone: BadgeTone.warning,
            title: 'Crédit faible · ${o.name}',
            body: '${Fmt.kwh(o.balanceKwh)} kWh restants · environ '
                '${Fmt.duration(o.autonomy)}.',
          ),
      ],
    );
  }

  // ---------------- Actions ----------------

  void _recharge(BuildContext context, WidgetRef ref, String meterId) {
    ref.read(selectedMeterIdProvider.notifier).state = meterId;
    context.pushReplacement(AppRoutes.recharge);
  }

  void _later(BuildContext context) {
    _snack(context, 'Rappel programmé dans 3 h (simulé).');
    context.pop();
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }
}