import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Lecture accélérée en cours ? (pour le bouton Lecture / Pause)
final demoClockPlayingProvider = StateProvider<bool>((ref) => false);

/// Horloge de démonstration.
///
/// La journée simulée est le vendredi 9 octobre 2026 (date de `mockNow`).
/// Faire avancer l'heure fait baisser le crédit selon les appareils
/// enregistrés et le profil horaire (pic 18 h – 22 h) ; les alertes et les
/// conseils apparaissent au bon moment. En production, remplacer simplement
/// cette horloge par `DateTime.now()`.
class DemoClock extends Notifier<DateTime> {
  static final DateTime day = DateTime(2026, 10, 9);
  static const int defaultMinute = 7 * 60; // 07:00

  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    return day.add(const Duration(minutes: defaultMinute));
  }

  /// Minute de la journée (0 = minuit, 1439 = 23 h 59).
  int get minuteOfDay => state.difference(day).inMinutes;

  bool get isPlaying => _timer != null;

  void setMinute(int minute) => state = day.add(Duration(minutes: minute.clamp(0, 1439).toInt()));

  void setTime(int hour, [int minute = 0]) => setMinute(hour * 60 + minute);

  /// Lecture accélérée : +15 min toutes les 650 ms, jusqu'à 23 h 45.
  void togglePlay() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      _setPlaying(false);
      return;
    }
    if (minuteOfDay >= 1425) setMinute(6 * 60);
    _setPlaying(true);
    _timer = Timer.periodic(const Duration(milliseconds: 650), (t) {
      final next = minuteOfDay + 15;
      if (next > 1425) {
        t.cancel();
        _timer = null;
        _setPlaying(false);
        return;
      }
      setMinute(next);
    });
  }

  void _setPlaying(bool v) => ref.read(demoClockPlayingProvider.notifier).state = v;

  void reset() {
    _timer?.cancel();
    _timer = null;
    _setPlaying(false);
    setMinute(defaultMinute);
  }
}

final demoClockProvider = NotifierProvider<DemoClock, DateTime>(DemoClock.new);

/// Minute de la journée simulée (pratique pour le moteur de consommation).
final demoMinuteProvider = Provider<double>((ref) {
  final now = ref.watch(demoClockProvider);
  return now.difference(DemoClock.day).inMinutes.toDouble();
});
