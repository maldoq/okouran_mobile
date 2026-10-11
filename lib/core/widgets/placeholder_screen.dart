import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_spacing.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// Écran temporaire pour les routes pas encore réalisées.
/// À supprimer quand tous les écrans seront codés.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded,
                  size: 48, color: AppColors.secondary),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: text.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text('Écran à venir', style: text.bodyMedium),
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('Relancer le splash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
