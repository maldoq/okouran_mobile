import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/app_alert.dart';
import '../providers/alerts_provider.dart';
import '../widgets/action_alert_card.dart';
import '../widgets/alert_tile.dart';

/// Écran 10 : Mes alertes (onglet « Alertes »).
///
/// Deux sections :
///   - À traiter : alertes non réglées, avec un bouton d'action ;
///   - Historique : le reste, de la plus récente à la plus ancienne.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final toDo = ref.watch(actionAlertsProvider);
    final past = ref.watch(pastAlertsProvider);
    final unread = ref.watch(unreadAlertsCountProvider);
    final notifier = ref.read(alertsProvider.notifier);

    void open(AppAlert alert) {
      notifier.markRead(alert.id);
      context.push(routeForAlert(alert.type));
    }

    void act(AppAlert alert) {
      notifier.markRead(alert.id);
      context.push(alert.type == AlertType.anomaly
          ? AppRoutes.anomaly
          : AppRoutes.recharge);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              // Titre + compteur + « tout marquer comme lu ».
              Row(
                children: [
                  Text('Mes alertes', style: text.headlineSmall),
                  const SizedBox(width: 10),
                  if (toDo.isNotEmpty)
                    StatusPill(
                      label: '${toDo.length} à traiter',
                      tone: BadgeTone.danger,
                      showLed: false,
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Tout marquer comme lu',
                    onPressed: unread == 0 ? null : notifier.markAllRead,
                    icon: const Icon(Icons.done_all_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ---- À traiter ----
              if (toDo.isEmpty)
                const InfoNote(
                  icon: Icons.check_circle_outline_rounded,
                  tone: BadgeTone.success,
                  title: 'Rien à traiter.',
                  message: 'Tous vos compteurs ont assez de crédit.',
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text('À TRAITER',
                      style:
                          text.labelSmall?.copyWith(color: AppColors.danger)),
                ),
                for (final a in toDo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: ActionAlertCard(
                      alert: a,
                      onTap: () => open(a),
                      onAction: () => act(a),
                    ),
                  ),
              ],

              // ---- Historique ----
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
                child: Text('HISTORIQUE', style: text.labelSmall),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      for (final (i, a) in past.indexed) ...[
                        if (i > 0) const Divider(),
                        AlertTile(alert: a, onTap: () => open(a)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Régler mes seuils et mes canaux',
                icon: Icons.tune_rounded,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.small,
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}