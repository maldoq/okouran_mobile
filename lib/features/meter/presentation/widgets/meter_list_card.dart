import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/meter.dart';
import 'meter_style.dart';

/// Carte d'un compteur dans « Mes compteurs » : état, solde, autonomie,
/// rythme, jauge, étiquettes et trois actions rapides.
class MeterListCard extends StatelessWidget {
  const MeterListCard({
    super.key,
    required this.meter,
    required this.onTap,
    required this.onRecharge,
    required this.onConso,
    required this.onDetails,
    required this.target,
  });

  /// Objectif d'autonomie qui vaut 100 % sur la jauge.
  final Duration target;

  final Meter meter;
  final VoidCallback onTap;
  final VoidCallback onRecharge;
  final VoidCallback onConso;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = riskTone(meter.risk);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(
                          icon: meterKindIcon(meter.kind), tone: tone, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(meter.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.titleMedium
                                          ?.copyWith(fontSize: 14)),
                                ),
                                StatusPill(
                                    label: meter.risk.creditLabel, tone: tone),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${meter.number} · ${meter.location}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(fontSize: 10.5),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: Fmt.kwh(meter.balanceKwh)),
                                    TextSpan(
                                      text: ' kWh',
                                      style: text.bodySmall?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ]),
                                  style: text.headlineSmall?.copyWith(
                                    color: tone.color,
                                    height: 1,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(Fmt.duration(meter.autonomy),
                                        style: text.titleSmall?.copyWith(
                                            fontSize: 12, color: tone.color)),
                                    Text('d\'autonomie',
                                        style: text.bodySmall
                                            ?.copyWith(fontSize: 10)),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  '${Fmt.kwh(meter.kwhPerDay)} kWh/j',
                                  style: text.bodySmall?.copyWith(
                                    fontSize: 10.5,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 9),
                            // Jauge : autonomie ÷ objectif (7 jours par défaut).
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: meter.gaugeRatio(target),
                                minHeight: 6,
                                backgroundColor: const Color(0xFFEEF3F6),
                                valueColor: AlwaysStoppedAnimation(tone.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Étiquettes.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _tag(text, meter.type, const Color(0xFFEFF4F7),
                            const Color(0xFF334155)),
                        meter.remoteRecharge
                            ? _tag(text, 'recharge à distance',
                                const Color(0xFFE0F4FC), AppColors.primary)
                            : _tag(text, 'code manuel', AppColors.warningBg,
                                const Color(0xFF8A4A05)),
                        if (meter.sharedWith != null)
                          _tag(text, 'partagé · ${meter.sharedWith}',
                              const Color(0xFFEDE7F6), const Color(0xFF5B3E9B)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Actions rapides.
          IntrinsicHeight(
            child: Row(
              children: [
                _action(text, Icons.bolt_rounded, 'Recharger', onRecharge,
                    color: AppColors.secondary),
                const VerticalDivider(width: 1),
                _action(text, Icons.bar_chart_rounded, 'Conso', onConso),
                const VerticalDivider(width: 1),
                _action(text, Icons.info_outline_rounded, 'Détails', onDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(TextTheme text, String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: text.bodySmall?.copyWith(
                fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
      );

  Widget _action(TextTheme text, IconData icon, String label, VoidCallback onTap,
          {Color color = AppColors.textSecondary}) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(height: 2),
                Text(label,
                    style: text.bodySmall?.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          ),
        ),
      );
}