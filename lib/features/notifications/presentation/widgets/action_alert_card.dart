import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/app_alert.dart';
import 'alert_tile.dart';

/// Carte d'une alerte « à traiter » : liseré coloré, pastille, titre,
/// détail, heure et bouton d'action directement dans la carte.
class ActionAlertCard extends StatelessWidget {
  const ActionAlertCard({
    super.key,
    required this.alert,
    required this.onAction,
    required this.onTap,
  });

  final AppAlert alert;
  final VoidCallback onAction;
  final VoidCallback onTap;

  /// Libellé du bouton selon le type d'alerte.
  String get actionLabel =>
      alert.type == AlertType.anomaly ? 'Analyser' : 'Recharger';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = alert.type.tone;
    final borderColor = tone == BadgeTone.danger
        ? const Color(0xFFF5CBC8)
        : const Color(0xFFF2D9A8);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: tone.color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 12, 13, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(icon: alert.type.icon, tone: tone),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(alert.title,
                                      style: text.titleSmall
                                          ?.copyWith(fontSize: 12.5)),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AlertTile.relativeDate(alert.date),
                                  style: text.bodySmall?.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${alert.meterName} · ${alert.detail}',
                              style: text.bodySmall
                                  ?.copyWith(fontSize: 11, height: 1.45),
                            ),
                            const SizedBox(height: 9),
                            AppButton(
                              label: actionLabel,
                              icon: alert.type == AlertType.anomaly
                                  ? Icons.search_rounded
                                  : Icons.bolt_rounded,
                              variant: AppButtonVariant.dark,
                              size: AppButtonSize.small,
                              expand: false,
                              onPressed: onAction,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}