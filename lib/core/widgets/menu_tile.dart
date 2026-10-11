import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ligne de menu : icône, titre, sous-titre et chevron (ou autre élément
/// à droite, comme un interrupteur).
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Par défaut : un chevron si [onTap] est fourni.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: const Color(0xFF334155)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleSmall?.copyWith(fontSize: 12.5)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(subtitle!,
                          style: text.bodySmall?.copyWith(fontSize: 10.5)),
                    ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.textSecondary)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

/// Carte regroupant des [MenuTile] séparées par un filet.
class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 60),
            children[i],
          ],
        ],
      ),
    );
  }
}