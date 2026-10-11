import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../providers/meter_providers.dart';
import 'meter_style.dart';

/// Feuille de choix du compteur (s'ouvre depuis le bas).
/// Le compteur choisi devient le compteur sélectionné de l'app.
Future<void> showMeterPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _MeterPicker(),
  );
}

class _MeterPicker extends ConsumerWidget {
  const _MeterPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meters = ref.watch(liveMetersProvider);
    final selectedId = ref.watch(selectedMeterIdProvider);
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choisir un compteur', style: text.titleLarge),
            const SizedBox(height: 10),
            for (final m in meters)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: IconBadge(
                    icon: meterKindIcon(m.kind), tone: riskTone(m.risk)),
                title: Text(m.name, style: text.titleSmall),
                subtitle: Text(
                  '${Fmt.kwh(m.balanceKwh)} kWh · ${Fmt.duration(m.autonomy)}',
                  style: text.bodySmall,
                ),
                trailing: m.id == selectedId
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.secondary)
                    : null,
                onTap: () {
                  ref.read(selectedMeterIdProvider.notifier).state = m.id;
                  Navigator.pop(context);
                },
              ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const IconBadge(
                  icon: Icons.add_rounded, tone: BadgeTone.info),
              title: Text('Ajouter un compteur',
                  style: text.titleSmall?.copyWith(color: AppColors.secondary)),
              onTap: () {
                // Routeur récupéré avant de fermer la feuille (son contexte disparaît).
                final router = GoRouter.of(context);
                Navigator.pop(context);
                router.push(AppRoutes.addMeter);
              },
            ),
          ],
        ),
      ),
    );
  }
}