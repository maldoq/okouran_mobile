import 'package:flutter/material.dart';

import 'icon_badge.dart';

/// Pastille arrondie avec voyant lumineux (ex. « Crédit suffisant »).
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = BadgeTone.success,
    this.showLed = true,
  });

  final String label;
  final BadgeTone tone;
  final bool showLed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLed) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: tone.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: tone.color.withValues(alpha: .25), spreadRadius: 3),
                ],
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  letterSpacing: 0,
                  color: tone.color,
                ),
          ),
        ],
      ),
    );
  }
}