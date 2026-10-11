import 'package:flutter/material.dart';

import 'icon_badge.dart';

/// Bandeau d'information coloré : icône + titre en gras + texte.
/// Le ton reprend [BadgeTone] (info, succès, avertissement, danger).
class InfoNote extends StatelessWidget {
  const InfoNote({
    super.key,
    required this.icon,
    required this.message,
    this.title,
    this.tone = BadgeTone.info,
  });

  final IconData icon;
  final String? title;
  final String message;
  final BadgeTone tone;

  /// Couleur du texte : version foncée de la couleur du ton (lisibilité).
  Color get _textColor => switch (tone) {
        BadgeTone.info => const Color(0xFF0F3B17),
        BadgeTone.brand => const Color(0xFF9A3A00),
        BadgeTone.success => const Color(0xFF0A5C39),
        BadgeTone.warning => const Color(0xFF8A4A05),
        BadgeTone.danger => const Color(0xFF8E211D),
        BadgeTone.neutral => const Color(0xFF3A4434),
      };

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(fontSize: 11, height: 1.5, color: _textColor);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _textColor),
          const SizedBox(width: 9),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                if (title != null)
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                TextSpan(text: message),
              ]),
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}