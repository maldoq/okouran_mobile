import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../meter/domain/meter.dart';
import '../../../meter/presentation/widgets/meter_style.dart';
import 'credit_ring.dart';
import 'meter_switcher.dart';

/// En-tête bleu nuit du tableau de bord : salutation, cloche, bande de
/// compteurs, jauge d'autonomie et niveau de crédit.
///
/// Changer de compteur : toucher une puce de la bande, ou glisser
/// horizontalement sur la jauge.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.date,
    required this.firstName,
    required this.meters,
    required this.meter,
    required this.target,
    required this.unreadCount,
    required this.onBellTap,
    required this.onSelectMeter,
    required this.onOpenMeter,
    required this.onAddMeter,
  });

  final DateTime date;
  final String firstName;
  final List<Meter> meters;

  /// Compteur affiché.
  final Meter meter;

  /// Objectif d'autonomie qui vaut 100 % (réglable dans les Paramètres).
  final Duration target;
  final int unreadCount;
  final VoidCallback onBellTap;
  final ValueChanged<String> onSelectMeter;
  final VoidCallback onOpenMeter;
  final VoidCallback onAddMeter;

  /// Glissement horizontal sur la jauge : compteur suivant ou précédent.
  void _onSwipe(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v.abs() < 250 || meters.length < 2) return;
    final i = meters.indexWhere((m) => m.id == meter.id);
    final next = v < 0 ? (i + 1) % meters.length : (i - 1 + meters.length) % meters.length;
    onSelectMeter(meters[next].id);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final ratio = meter.gaugeRatio(target);
    final surplus = meter.surplusOver(target);
    // Jauge verte si risque faible, sinon couleur du risque.
    final ringColor = meter.risk == RiskLevel.low
        ? AppColors.accent
        : riskTone(meter.risk).color;
    final muted = Colors.white.withValues(alpha: .55);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF02507D), Color(0xFF02628F)],
          stops: [0, .7, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Stack(
        children: [
          // Halo lumineux en haut à droite (décor).
          Positioned(
            right: -40,
            top: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: .22),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, topInset + 8, 0, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salutation + cloche.
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Fmt.dayLong(date).toUpperCase(),
                              style: text.labelSmall?.copyWith(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: .62),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bonjour $firstName',
                              style: text.titleLarge?.copyWith(
                                  fontSize: 19, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      _BellButton(count: unreadCount, onTap: onBellTap),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Bande de compteurs (défile jusqu'au bord droit).
                MeterSwitcher(
                  meters: meters,
                  selectedId: meter.id,
                  onSelect: onSelectMeter,
                  onOpenSelected: onOpenMeter,
                  onAdd: onAddMeter,
                ),
                const SizedBox(height: 18),

                // Jauge : glisser à gauche / à droite change de compteur.
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: _onSwipe,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SwipeHint(
                                icon: Icons.chevron_left_rounded,
                                visible: meters.length > 1),
                            CreditRing(
                              value: ratio,
                              color: ringColor,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Column(
                                  key: ValueKey(meter.id),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      Fmt.duration(meter.autonomy),
                                      style: text.displayMedium?.copyWith(
                                        fontSize: 30,
                                        color: Colors.white,
                                        letterSpacing: -.5,
                                      ),
                                    ),
                                    Text(
                                      'D\'AUTONOMIE',
                                      style: text.labelSmall?.copyWith(
                                          fontSize: 10, color: muted),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.bolt_rounded,
                                            size: 14, color: ringColor),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${Fmt.kwh(meter.balanceKwh)} kWh',
                                          style: text.titleSmall?.copyWith(
                                            fontSize: 13,
                                            color: ringColor,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _SwipeHint(
                                icon: Icons.chevron_right_rounded,
                                visible: meters.length > 1),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StatusPill(
                          label: meter.risk.creditLabel,
                          tone: riskTone(meter.risk),
                        ),
                        const SizedBox(height: 9),
                        // Explication de la jauge.
                        Text(
                          surplus > Duration.zero
                              ? '100 % · objectif de ${target.inDays} jours '
                                  'dépassé de ${Fmt.duration(surplus)}'
                              : '${(ratio * 100).round()} % de votre objectif '
                                  'de ${target.inDays} jours d\'autonomie',
                          textAlign: TextAlign.center,
                          style: text.bodySmall?.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: .75)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '≈ ${Fmt.fcfa(meter.balanceFcfa)} · tarif '
                          '${meter.tariffPerKwh.round()} F/kWh',
                          textAlign: TextAlign.center,
                          style: text.bodySmall
                              ?.copyWith(fontSize: 10.5, color: muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Petite flèche de part et d'autre de la jauge (indique le glissement).
class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.icon, required this.visible});
  final IconData icon;
  final bool visible;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28,
        child: visible
            ? Icon(icon, size: 22, color: Colors.white.withValues(alpha: .35))
            : null,
      );
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.square(
          dimension: 40,
          child: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            backgroundColor: AppColors.accent,
            textColor: AppColors.primary,
            offset: const Offset(2, -2),
            alignment: Alignment.topRight,
            child: const Center(
              child: Icon(Icons.notifications_none_rounded,
                  size: 21, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}