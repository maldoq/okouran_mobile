import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';

/// Simulation de l'écran verrouillé du téléphone : date, heure et
/// notifications empilées. Sert à montrer ce que reçoit l'utilisateur
/// quand il n'a pas l'app ouverte.
class LockScreenPreview extends StatelessWidget {
  const LockScreenPreview({
    super.key,
    required this.time,
    required this.notifications,
    this.tint = AppColors.primary,
    this.onClose,
  });

  final DateTime time;
  final List<Widget> notifications;

  /// Couleur du haut du dégradé (rouge sombre pour une alerte critique).
  final Color tint;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tint, const Color(0xFF0B2D3D), const Color(0xFF154A5F)],
          stops: const [0, .45, 1],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Bandeau « aperçu » + fermeture.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'APERÇU · ÉCRAN VERROUILLÉ',
                      style: text.labelSmall?.copyWith(
                        fontSize: 9.5,
                        color: Colors.white.withValues(alpha: .75),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Fermer',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Date et heure.
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 24),
              child: Column(
                children: [
                  Text(
                    Fmt.dayLong(time),
                    style: text.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: .66)),
                  ),
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:'
                    '${time.minute.toString().padLeft(2, '0')}',
                    style: text.displayLarge?.copyWith(
                      fontSize: 66,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            // Notifications, apparition décalée.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  for (final (i, n) in notifications.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 450 + i * 180),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) => Opacity(
                          opacity: t,
                          child: Transform.translate(
                              offset: Offset(0, -16 * (1 - t)), child: child),
                        ),
                        child: n,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton d'action d'une notification (« Recharger », « Plus tard »…).
class PushAction {
  const PushAction(this.label, this.onTap, {this.color});
  final String label;
  final VoidCallback onTap;

  /// Fond plein ; null = bouton discret.
  final Color? color;
}

/// Carte de notification, au style des notifications système.
class PushCard extends StatelessWidget {
  const PushCard({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    this.source = 'O\'kouran · maintenant',
    this.actions = const [],
    this.showStripe = true,
  });

  final IconData icon;
  final BadgeTone tone;
  final String title;

  /// Corps du message ; les passages entre ** sont mis en gras.
  final String body;
  final String source;
  final List<PushAction> actions;
  final bool showStripe;

  /// « Il reste **7,2 kWh** » → texte avec passages en gras.
  List<TextSpan> _spans() {
    final parts = body.split('**');
    return [
      for (var i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          style: i.isOdd
              ? const TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)
              : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(19),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 30,
            offset: Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showStripe) Container(width: 4, color: tone.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 12, 13, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(icon: icon, tone: tone),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(title,
                                    style: text.titleSmall
                                        ?.copyWith(fontSize: 12.5)),
                              ),
                              const SizedBox(width: 6),
                              Text(source,
                                  style:
                                      text.bodySmall?.copyWith(fontSize: 9.5)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(children: _spans()),
                            style: text.bodySmall
                                ?.copyWith(fontSize: 11.5, height: 1.45),
                          ),
                          if (actions.isNotEmpty) ...[
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 7,
                              children: [
                                for (final a in actions)
                                  _ActionPill(action: a),
                              ],
                            ),
                          ],
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
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.action});
  final PushAction action;

  @override
  Widget build(BuildContext context) {
    final filled = action.color != null;
    return Material(
      color: action.color ?? const Color(0xFFEFF4F7),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            action.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10.5,
                  letterSpacing: 0,
                  color: filled ? Colors.white : AppColors.textPrimary,
                ),
          ),
        ),
      ),
    );
  }
}