import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// Cadre des 4 onglets principaux avec la barre du bas de la maquette :
/// Accueil · Conso · [bouton Recharger] · Alertes · Profil.
///
/// Chaque onglet garde son propre historique de navigation
/// (StatefulShellRoute.indexedStack de GoRouter).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) => navigationShell.goBranch(
        index,
        // Re-toucher l'onglet actif ramène à sa page racine.
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        onTab: _goBranch,
        onRecharge: () => context.push(AppRoutes.recharge),
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _tabs = [
  _TabItem(Icons.home_outlined, Icons.home_rounded, 'Accueil'),
  _TabItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Conso'),
  _TabItem(Icons.notifications_none_rounded, Icons.notifications_rounded, 'Alertes'),
  _TabItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
];

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTab,
    required this.onRecharge,
  });

  final int currentIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget tab(int i) => Expanded(
          child: _TabButton(
            item: _tabs[i],
            selected: i == currentIndex,
            onTap: () => onTab(i),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              tab(0),
              tab(1),
              Expanded(child: Center(child: _RechargeFab(onTap: onRecharge))),
              tab(2),
              tab(3),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.secondary : AppColors.textSecondary;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 0,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton central surélevé « Recharger ».
class _RechargeFab extends StatelessWidget {
  const _RechargeFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Tooltip(
        message: 'Recharger',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                  color: Theme.of(context).colorScheme.surface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: .8),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded,
                size: 26, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}