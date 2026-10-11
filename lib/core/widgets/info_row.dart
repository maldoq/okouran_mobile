import 'package:flutter/material.dart';

/// Ligne « libellé : valeur » des fiches d'information.
/// [trailing] permet d'ajouter une action (copier, modifier…).
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  /// Remplace le texte de la valeur (ex. une pastille d'état).
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodySmall?.copyWith(fontSize: 10.5)),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value,
                      style: text.titleSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}