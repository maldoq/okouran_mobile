import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../meter/data/mock_meters.dart';
import '../../domain/app_alert.dart';

/// Icône et ton associés à chaque type d'alerte.
extension AlertTypeStyle on AlertType {
  IconData get icon => switch (this) {
        AlertType.lowCredit => Icons.battery_alert_rounded,
        AlertType.criticalCredit => Icons.bolt_rounded,
        AlertType.imminentCutoff => Icons.power_off_rounded,
        AlertType.anomaly => Icons.warning_amber_rounded,
        AlertType.rechargeConfirmed => Icons.check_rounded,
        AlertType.tip => Icons.lightbulb_outline_rounded,
      };

  BadgeTone get tone => switch (this) {
        AlertType.lowCredit || AlertType.anomaly => BadgeTone.warning,
        AlertType.criticalCredit || AlertType.imminentCutoff => BadgeTone.danger,
        AlertType.rechargeConfirmed => BadgeTone.success,
        AlertType.tip => BadgeTone.info,
      };
}

/// Ligne d'alerte : pastille, titre, « compteur · détail · date », chevron.
/// Réutilisée sur le tableau de bord et dans le centre de notifications.
class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, this.onTap});

  final AppAlert alert;
  final VoidCallback? onTap;

  /// « hier 21 h », « aujourd'hui 8 h 10 », sinon « 6 oct. ».
  static String relativeDate(DateTime date) {
    final today = DateTime(mockNow.year, mockNow.month, mockNow.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'aujourd\'hui ${Fmt.time(date)}';
    if (diff == 1) return 'hier ${Fmt.time(date)}';
    return Fmt.dayShort(date);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            IconBadge(icon: alert.type.icon, tone: alert.type.tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alert.title,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall?.copyWith(fontSize: 12.5),
                        ),
                      ),
                      if (!alert.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${alert.meterName} · ${alert.detail} · ${relativeDate(alert.date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}