import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/mock_auth_repository.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/meter/data/mock_meters.dart';
import '../../features/meter/presentation/providers/meter_providers.dart';
import '../clock/demo_clock_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Bouton flottant « horloge de démo » (affiche l'heure simulée).
/// À placer dans `floatingActionButton` du tableau de bord. À retirer en production.
class DemoClockButton extends ConsumerWidget {
  const DemoClockButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(demoClockProvider);
    final playing = ref.watch(demoClockPlayingProvider);
    return FloatingActionButton.extended(
      heroTag: 'demo-clock',
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      onPressed: () => showDemoClockPanel(context),
      icon: Icon(playing ? Icons.fast_forward_rounded : Icons.schedule_rounded,
          size: 18),
      label: Text(_hhmm(now),
          style: AppTextStyles.figure(14, color: Colors.white)),
    );
  }
}

Future<void> showDemoClockPanel(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const DemoClockPanel(),
    );

/// Panneau de démonstration : heure simulée (curseur, lecture accélérée,
/// raccourcis) et changement de compte de démo.
class DemoClockPanel extends ConsumerWidget {
  const DemoClockPanel({super.key});

  static const _presets = [
    (7, 0),
    (12, 0),
    (16, 0),
    (18, 30),
    (20, 0),
    (22, 0)
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(demoClockProvider);
    final playing = ref.watch(demoClockPlayingProvider);
    final clock = ref.read(demoClockProvider.notifier);
    final minute = ref.watch(demoMinuteProvider);
    final user = ref.watch(currentUserProvider) ?? mockUser;
    final text = Theme.of(context).textTheme;

    void switchUser(DemoAccount acc) {
      ref.read(currentUserProvider.notifier).state = acc.user;
      final first = mockMeters.where((m) => m.ownerId == acc.user.id).toList();
      if (first.isNotEmpty) {
        ref.read(selectedMeterIdProvider.notifier).state = first.first.id;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('HORLOGE DE DÉMO · VEN. 9 OCT. 2026',
              style: AppTextStyles.adviceKicker(color: AppColors.orangeDeep)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(_hhmm(now), style: AppTextStyles.figure(34)),
              const Spacer(),
              IconButton.filled(
                style: IconButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white),
                onPressed: clock.togglePlay,
                icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                tooltip:
                    playing ? 'Pause' : 'Lecture accélérée (+15 min / 0,65 s)',
              ),
              IconButton(
                  onPressed: clock.reset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  tooltip: 'Revenir à 07:00'),
            ],
          ),
          Slider(
            value: minute.clamp(0, 1439).toDouble(),
            min: 0,
            max: 1439,
            divisions: 96,
            activeColor: AppColors.accent,
            label: _hhmm(now),
            onChanged: (v) => clock.setMinute(v.round()),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (h, m) in _presets)
                ActionChip(
                  label: Text(
                      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}'),
                  onPressed: () => clock.setTime(h, m),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Compte de démonstration', style: text.titleSmall),
          const SizedBox(height: 6),
          RadioGroup<String>(
            groupValue: user.id,
            onChanged: (id) {
              for (final account in demoAccounts) {
                if (account.user.id == id) {
                  switchUser(account);
                  break;
                }
              }
            },
            child: Column(
              children: [
                for (final acc in demoAccounts)
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: acc.user.id,
                    activeColor: AppColors.accent,
                    title: Text(
                        '${acc.user.firstName} · ${acc.user.commune ?? ''}'),
                    subtitle: Text(acc.scenario,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
