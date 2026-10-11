import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'step_progress.dart';

/// Barre de titre des sous-pages : bouton retour, titre, action à droite.
/// Fond blanc avec un filet en bas, comme la maquette.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Widget? trailing;

  /// Par défaut : page précédente.
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bar = Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outline)),
      ),
      child: Row(
        children: [
          AppBackButton(onPressed: onBack ?? () => context.pop()),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Icônes de la barre d'état en foncé sur fond blanc.
      value: SystemUiOverlayStyle.dark,
      child: Material(
        color: scheme.surface,
        child: SafeArea(bottom: false, child: bar),
      ),
    );
  }
}