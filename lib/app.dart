import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/presentation/providers/profile_providers.dart';

/// Racine de l'application : thème, localisation et routeur.
class OkouranApp extends ConsumerWidget {
  const OkouranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final largeText = ref.watch(appSettingsProvider).largeText;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark, // préparé, pas encore exposé dans l'UI
      themeMode: themeMode,
      routerConfig: router,
      // « Grande taille de texte » (Paramètres) : +15 % partout.
      builder: (context, child) {
        if (!largeText) return child!;
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.15)),
          child: child!,
        );
      },
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Mode de thème. Reste sur [ThemeMode.light] tant que le mode sombre
/// n'est pas validé ; l'écran Paramètres pourra le modifier plus tard.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);