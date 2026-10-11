import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/clock/demo_clock_provider.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../data/mock_forecast.dart';
import '../../domain/forecast.dart';

/// Prévision du compteur affiché sur le tableau de bord.
final forecastProvider = Provider<Forecast>((ref) {
  return mockForecastFor(ref.watch(selectedMeterProvider), now: ref.watch(demoClockProvider));
});

/// Variation de consommation choisie avec le curseur (−0,20 à +0,40).
final scenarioChangeProvider = StateProvider.autoDispose<double>((ref) => 0);