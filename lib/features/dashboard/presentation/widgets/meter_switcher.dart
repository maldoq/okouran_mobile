import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../meter/domain/meter.dart';
import '../../../meter/presentation/widgets/meter_style.dart';

/// Bande de compteurs défilante, en haut du tableau de bord.
///
/// - Toucher un compteur l'affiche immédiatement.
/// - Toucher le compteur déjà affiché ouvre son détail.
/// - Le « + » final ouvre l'ajout de compteur.
/// Le point coloré sur chaque puce donne l'état du crédit sans changer
/// de compteur.
class MeterSwitcher extends StatefulWidget {
  const MeterSwitcher({
    super.key,
    required this.meters,
    required this.selectedId,
    required this.onSelect,
    required this.onOpenSelected,
    required this.onAdd,
  });

  final List<Meter> meters;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onOpenSelected;
  final VoidCallback onAdd;

  @override
  State<MeterSwitcher> createState() => _MeterSwitcherState();
}

class _MeterSwitcherState extends State<MeterSwitcher> {
  final _keys = <String, GlobalKey>{};

  @override
  void didUpdateWidget(MeterSwitcher old) {
    super.didUpdateWidget(old);
    // Fait défiler la bande pour garder le compteur choisi visible
    // (utile quand on change de compteur par glissement sur la jauge).
    if (old.selectedId != widget.selectedId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _keys[widget.selectedId]?.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx,
              alignment: .5, duration: const Duration(milliseconds: 300));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final m in widget.meters)
            Padding(
              key: _keys.putIfAbsent(m.id, GlobalKey.new),
              padding: const EdgeInsets.only(right: 8),
              child: _MeterPill(
                meter: m,
                selected: m.id == widget.selectedId,
                onTap: () => m.id == widget.selectedId
                    ? widget.onOpenSelected()
                    : widget.onSelect(m.id),
              ),
            ),
          // Ajouter un compteur.
          Material(
            color: Colors.white.withValues(alpha: .1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: .2)),
            ),
            child: InkWell(
              onTap: widget.onAdd,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 40,
                child: Tooltip(
                  message: 'Ajouter un compteur',
                  child: Icon(Icons.add_rounded,
                      size: 20, color: Colors.white.withValues(alpha: .85)),
                ),
              ),
            ),
          ),
          // Légende discrète.
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Center(
              child: Text(
                widget.meters.length > 1 ? 'Glissez sur la jauge\npour changer' : '',
                style: text.bodySmall?.copyWith(
                    fontSize: 9.5,
                    height: 1.3,
                    color: Colors.white.withValues(alpha: .45)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeterPill extends StatelessWidget {
  const _MeterPill({
    required this.meter,
    required this.selected,
    required this.onTap,
  });

  final Meter meter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dot = meter.risk == RiskLevel.low
        ? AppColors.accent
        : riskTone(meter.risk).color;
    final fg = selected ? AppColors.primary : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: .2)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(meterKindIcon(meter.kind), size: 16, color: fg),
                const SizedBox(width: 7),
                Text(
                  meter.name,
                  style: text.titleSmall?.copyWith(fontSize: 12.5, color: fg),
                ),
                const SizedBox(width: 7),
                // Point d'état du crédit.
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected ? Colors.white : Colors.transparent),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}