import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../data/mock_tips.dart';
import '../../domain/energy_tip.dart';
import '../providers/tips_provider.dart';

/// Écran 19 : Conseils & économies.
///
/// Chaque conseil est chiffré en kWh par semaine, puis traduit en heures
/// d'autonomie gagnées et en FCFA économisés pour le compteur sélectionné.
/// L'utilisateur coche les conseils qu'il applique : le total se met à jour.
class TipsScreen extends ConsumerWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(selectedMeterProvider);
    final applied = ref.watch(appliedTipsProvider);
    final text = Theme.of(context).textTheme;

    /// Heures gagnées = kWh économisés ÷ rythme (kWh par heure).
    Duration hoursFor(double kwh) =>
        Duration(minutes: (kwh / (meter.kwhPerDay / 24) * 60).round());

    // Total affiché : conseils cochés, ou tous si aucun n'est coché.
    final chosen = applied.isEmpty
        ? mockTips
        : mockTips.where((t) => applied.contains(t.id)).toList();
    final kwh = chosen.fold<double>(0, (s, t) => s + t.kwhPerWeek);

    void toggle(EnergyTip t) {
      final next = {...applied};
      next.contains(t.id) ? next.remove(t.id) : next.add(t.id);
      ref.read(appliedTipsProvider.notifier).state = next;
    }

    return Scaffold(
      appBar: AppTopBar(
        title: 'Conseils & économies',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.warningBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('ESTIMÉ',
              style: text.labelSmall
                  ?.copyWith(fontSize: 9, color: const Color(0xFF8A5A00))),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          // ---- Potentiel ----
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.tipsHero,
                    fit: BoxFit.cover,
                    // Cadrage vers le haut : la photo reste visible à droite.
                    alignment: const Alignment(1, -.4),
                  ),
                ),
                // Dégradé seulement à gauche, sous le texte.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: .97),
                          AppColors.primary.withValues(alpha: .85),
                          AppColors.primary.withValues(alpha: .15),
                        ],
                        stops: const [0, .5, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applied.isEmpty
                            ? 'POTENTIEL ESTIMÉ · ${meter.name.toUpperCase()}'
                            : 'VOTRE PLAN · ${applied.length} CONSEIL${applied.length > 1 ? 'S' : ''}',
                        style: text.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: .72)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${Fmt.kwh(kwh)} kWh',
                                  style: text.displayMedium?.copyWith(
                                      fontSize: 30, color: Colors.white)),
                              Text('par semaine',
                                  style: text.bodySmall?.copyWith(
                                      fontSize: 10.5,
                                      color:
                                          Colors.white.withValues(alpha: .7))),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('+${Fmt.duration(hoursFor(kwh))}',
                                  style: text.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent)),
                              Text('d\'autonomie',
                                  style: text.bodySmall?.copyWith(
                                      fontSize: 10.5,
                                      color:
                                          Colors.white.withValues(alpha: .7))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '≈ ${Fmt.fcfa(kwh * meter.tariffPerKwh)} économisés par '
                        'semaine (${meter.tariffPerKwh.round()} F/kWh)',
                        style: text.bodySmall?.copyWith(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: .65)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          InfoNote(
            icon: Icons.schedule_rounded,
            title: 'Votre fenêtre sensible : $peakWindow.',
            message: 'C\'est là que ${(peakShare * 100).round()} % de votre '
                'consommation se joue. Les premiers conseils ciblent cette '
                'fenêtre. Cochez ceux que vous appliquez.',
          ),

          for (final t in mockTips)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _TipCard(
                tip: t,
                hours: hoursFor(t.kwhPerWeek),
                applied: applied.contains(t.id),
                onToggle: () => toggle(t),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Les gains sont des estimations : kWh économisés convertis en '
            'autonomie au rythme actuel du compteur '
            '(${Fmt.kwh(meter.kwhPerDay)} kWh/j). Ils ne constituent pas '
            'un engagement.',
            style: text.bodySmall?.copyWith(fontSize: 10.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.hours,
    required this.applied,
    required this.onToggle,
  });

  final EnergyTip tip;
  final Duration hours;
  final bool applied;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget pill(String label, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              style: text.bodySmall?.copyWith(
                  fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: applied ? AppColors.success : AppColors.border,
          width: applied ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tip.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tip.icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip.title,
                        style: text.titleSmall
                            ?.copyWith(fontSize: 13, height: 1.35)),
                    const SizedBox(height: 3),
                    Text(tip.detail,
                        style: text.bodySmall?.copyWith(fontSize: 10.5)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        pill('−${Fmt.kwh(tip.kwhPerWeek)} kWh / sem.',
                            AppColors.successBg, const Color(0xFF0A5C39)),
                        pill('+ ${Fmt.duration(hours)} d\'autonomie',
                            const Color(0xFFE0F4FC), AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Case « je l'applique ».
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: applied ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: applied ? AppColors.success : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: applied
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}