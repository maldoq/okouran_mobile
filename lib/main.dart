import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dates en français (ex. « 12 octobre 2026 ») pour tout l'app.
  await initializeDateFormatting('fr_FR');

  // Application pensée pour le portrait uniquement.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(child: OkouranApp()));
}
