import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../domain/meter.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/meter_providers.dart';
import '../widgets/meter_list_card.dart';

/// Écran 14 : Mes compteurs.
///
/// Tous les compteurs avec leur état d'un coup d'œil : la couleur et
/// l'autonomie suffisent à voir lequel demande une action.
class MetersScreen extends ConsumerWidget {
  const MetersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meters = ref.watch(liveMetersProvider);
    final target = ref.watch(autonomyTargetProvider);

    // Compteurs à surveiller : risque moyen ou élevé, le plus urgent d'abord.
    final urgent = meters.where((m) => m.risk != RiskLevel.low).toList()
      ..sort((a, b) => a.autonomy.compareTo(b.autonomy));

    void select(Meter m) =>
        ref.read(selectedMeterIdProvider.notifier).state = m.id;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Mes compteurs',
        trailing: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.push(AppRoutes.addMeter),
            child: const SizedBox.square(
              dimension: 34,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 19),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          // Résumé.
          urgent.isEmpty
              ? const InfoNote(
                  icon: Icons.check_circle_outline_rounded,
                  tone: BadgeTone.success,
                  title: 'Tout va bien.',
                  message: 'Tous vos compteurs ont au moins 2 jours d\'autonomie.',
                )
              : InfoNote(
                  icon: Icons.error_outline_rounded,
                  tone: BadgeTone.danger,
                  title: urgent.length == 1
                      ? '1 compteur demande une action.'
                      : '${urgent.length} compteurs demandent une action.',
                  message: '${urgent.first.name} : ≈ '
                      '${Fmt.duration(urgent.first.autonomy)} d\'autonomie.',
                ),

          for (final m in meters)
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: MeterListCard(
                meter: m,
                target: target,
                onTap: () => context.push(AppRoutes.meterDetailOf(m.id)),
                onDetails: () => context.push(AppRoutes.meterDetailOf(m.id)),
                onRecharge: () {
                  select(m);
                  context.push(AppRoutes.recharge);
                },
                onConso: () {
                  select(m);
                  context.go(AppRoutes.conso);
                },
              ),
            ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Ajouter un compteur',
            icon: Icons.add_rounded,
            variant: AppButtonVariant.outline,
            onPressed: () => context.push(AppRoutes.addMeter),
          ),
          const SizedBox(height: 12),
          const InfoNote(
            icon: Icons.group_outlined,
            title: 'Compteur partagé.',
            message: 'Plusieurs personnes peuvent suivre le même compteur et '
                'être alertées ensemble : utile en cour commune, en colocation '
                'ou pour une résidence familiale.',
          ),
        ],
      ),
    );
  }
}