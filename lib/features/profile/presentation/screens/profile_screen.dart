import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/menu_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/data/mock_auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../domain/notification_settings.dart';
import '../providers/profile_providers.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_header.dart';

/// Écran 12 : Profil (onglet « Profil »).
///
/// Informations utilisateur, trois chiffres clés, compte, notifications,
/// paramètres et déconnexion.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? mockUser;
    final stats = ref.watch(profileStatsProvider);
    final settings = ref.watch(notificationSettingsProvider);
    final meters = ref.watch(liveMetersProvider);
    final shared = meters.where((m) => m.sharedWith != null).length;
    final text = Theme.of(context).textTheme;

    void updateSettings(NotificationSettings next) =>
        ref.read(notificationSettingsProvider.notifier).state = next;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ProfileHeader(
              user: user,
              onSettings: () => context.push(AppRoutes.settings),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---- Trois chiffres clés ----
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _stat(text, '${stats.meters}', 'compteurs'),
                            const VerticalDivider(width: 1),
                            _stat(text, '${stats.recharges}',
                                'recharges réussies'),
                            const VerticalDivider(width: 1),
                            _stat(text, '${stats.avoidedCutoffs}',
                                'coupures évitées',
                                color: AppColors.success),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ---- Mon compte ----
                  const SectionHeader(title: 'Mon compte'),
                  MenuCard(children: [
                    MenuTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Informations personnelles',
                      subtitle: [
                        'Nom, téléphone',
                        if (user.commune != null) user.commune!,
                        if (user.email != null) user.email!,
                      ].join(' · '),
                      onTap: () => showEditProfileSheet(context),
                    ),
                    MenuTile(
                      icon: Icons.electric_meter_outlined,
                      title: 'Mes compteurs',
                      subtitle: '${meters.length} compteurs · $shared partagés',
                      onTap: () => context.push(AppRoutes.meters),
                    ),
                    MenuTile(
                      icon: Icons.kitchen_outlined,
                      title: 'Mes appareils',
                      subtitle: 'Base de la prévision et des conseils',
                      onTap: () => context.push(AppRoutes.appliances),
                    ),
                    MenuTile(
                      icon: Icons.tips_and_updates_outlined,
                      title: 'Conseils',
                      subtitle: 'Gestes chiffrés selon vos appareils',
                      onTap: () => context.push(AppRoutes.tips),
                    ),
                    MenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Historique et reçus',
                      subtitle: '${stats.recharges} recharges réussies · export PDF',
                      onTap: () => context.push(AppRoutes.history),
                    ),
                  ]),

                  // ---- Notifications ----
                  const SectionHeader(title: 'Notifications'),
                  MenuCard(children: [
                    MenuTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications sur le téléphone',
                      subtitle: 'Alertes de crédit et de coupure',
                      trailing: Switch(
                        value: settings.push,
                        onChanged: (v) =>
                            updateSettings(settings.copyWith(push: v)),
                      ),
                    ),
                    MenuTile(
                      icon: Icons.sms_outlined,
                      title: 'Copie par SMS',
                      subtitle: 'Reçue même sans internet',
                      trailing: Switch(
                        value: settings.sms,
                        onChanged: (v) =>
                            updateSettings(settings.copyWith(sms: v)),
                      ),
                    ),
                    MenuTile(
                      icon: Icons.insights_outlined,
                      title: 'Consommation inhabituelle',
                      subtitle: 'Quand un jour dépasse nettement l\'habitude',
                      trailing: Switch(
                        value: settings.anomalies,
                        onChanged: (v) =>
                            updateSettings(settings.copyWith(anomalies: v)),
                      ),
                    ),
                    // Seuil de l'alerte « crédit faible ».
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prévenir quand il reste moins de',
                              style: text.titleSmall?.copyWith(fontSize: 12.5)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final h in const [24, 48, 72])
                                ChoiceChip(
                                  label: Text('${h ~/ 24} jour${h > 24 ? 's' : ''}'),
                                  selected:
                                      settings.lowCreditThresholdHours == h,
                                  showCheckmark: false,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: settings.lowCreditThresholdHours == h
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                  onSelected: (_) => updateSettings(settings
                                      .copyWith(lowCreditThresholdHours: h)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),

                  // ---- Application ----
                  const SectionHeader(title: 'Application'),
                  MenuCard(children: [
                    MenuTile(
                      icon: Icons.flight_takeoff_rounded,
                      title: 'Mode absence',
                      subtitle: 'Désactivé',
                      onTap: () => context.push(AppRoutes.absence),
                    ),
                    MenuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Sécurité',
                      subtitle: 'Code PIN · empreinte activée',
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    MenuTile(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      subtitle: 'Langue, données, thème',
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  AppButton(
                    label: 'Se déconnecter',
                    icon: Icons.logout_rounded,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.small,
                    onPressed: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "O'kouran ${AppConstants.version} · prototype de recherche",
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(TextTheme text, String value, String label, {Color? color}) =>
      Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: text.headlineSmall?.copyWith(
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 1),
            Text(label,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(fontSize: 10.5)),
          ],
        ),
      );

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
            'Vos alertes ne seront plus reçues sur ce téléphone tant que '
            'vous ne vous reconnectez pas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(currentUserProvider.notifier).state = null;
    context.go(AppRoutes.login);
  }
}