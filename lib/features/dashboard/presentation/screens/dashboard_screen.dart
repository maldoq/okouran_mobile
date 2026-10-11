import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/clock/demo_clock_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/demo_clock_panel.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../appliances/presentation/widgets/advice_card.dart';
import '../../../auth/data/mock_auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../history/presentation/providers/consumption_providers.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../../notifications/presentation/providers/alerts_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../notifications/presentation/widgets/alert_tile.dart';
import '../widgets/cutoff_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/weekly_consumption_card.dart';

/// Écran 6 : Tableau de bord (onglet Accueil).
///
/// Répond à 4 questions sur une seule vue : combien il reste, combien de
/// temps, est-ce que je consomme plus que d'habitude, faut-il recharger.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(selectedMeterProvider);
    final user = ref.watch(currentUserProvider) ?? mockUser;
    final stats = ref.watch(consumptionStatsProvider);
    final day = ref.watch(todaySummaryProvider(meter.id));
    final now = ref.watch(demoClockProvider);
    final alerts = ref.watch(alertsProvider);
    final unread = ref.watch(unreadAlertsCountProvider);

    // « vs prévu » : consommation du jour comparée à la prévision des appareils.
    final vsUsualColor = day.vsPlan <= 0.05
        ? AppColors.success
        : (day.vsPlan > 0.15 ? AppColors.danger : AppColors.warning);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Horloge de démonstration (à retirer en production).
        floatingActionButton: const DemoClockButton(),
        body: RefreshIndicator(
          // Simulation : aucune donnée n'est rechargée.
          onRefresh: () =>
              Future<void>.delayed(const Duration(milliseconds: 800)),
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DashboardHeader(
                date: now,
                firstName: user.firstName.split(' ').first,
                meters: ref.watch(liveMetersProvider),
                meter: meter,
                target: ref.watch(autonomyTargetProvider),
                unreadCount: unread,
                onBellTap: () => context.go(AppRoutes.notifications),
                onSelectMeter: (id) =>
                    ref.read(selectedMeterIdProvider.notifier).state = id,
                onOpenMeter: () =>
                    context.push(AppRoutes.meterDetailOf(meter.id)),
                onAddMeter: () => context.push(AppRoutes.addMeter),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: 'RECHARGER MON COMPTEUR',
                      icon: Icons.bolt_rounded,
                      onPressed: () => context.push(AppRoutes.recharge),
                    ),
                    const SizedBox(height: 14),

                    CutoffCard(
                      meter: meter,
                      onTap: () => context.push(AppRoutes.forecast),
                    ),
                    const SizedBox(height: 12),

                    // Trois indicateurs (calculés dans consumption_providers.dart).
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            label: 'Aujourd\'hui',
                            value: Fmt.kwh(day.consumedKwh),
                            unit: 'kWh',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatTile(
                            label: 'Moyenne / j',
                            value: Fmt.kwh(stats.average7Days),
                            unit: 'kWh',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatTile(
                            label: 'vs prévu',
                            value: Fmt.percentDelta(day.vsPlan),
                            color: vsUsualColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    WeeklyConsumptionCard(
                      days: stats.last7Days,
                      weekTotal: stats.weekTotal,
                      onDetails: () => context.go(AppRoutes.conso),
                    ),
                    const SizedBox(height: 12),

                    AdviceCard(
                      meterId: meter.id,
                      onSeeAll: () => context.push(AppRoutes.tips),
                    ),

                    SectionHeader(
                      title: 'Dernières alertes',
                      actionLabel: 'Tout voir',
                      onAction: () => context.go(AppRoutes.notifications),
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          children: [
                            for (final (i, alert) in alerts.take(3).indexed) ...[
                              if (i > 0) const Divider(),
                              AlertTile(
                                alert: alert,
                                onTap: () {
                                  ref
                                      .read(alertsProvider.notifier)
                                      .markRead(alert.id);
                                  context.push(routeForAlert(alert.type));
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}