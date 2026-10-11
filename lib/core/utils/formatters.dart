import 'package:intl/intl.dart';

/// Mise en forme des nombres, durées et dates à la française.
abstract final class Fmt {
  static final _decimal1 = NumberFormat('#,##0.0', 'fr_FR');
  static final _integer = NumberFormat('#,##0', 'fr_FR');

  /// 18.6 → « 18,6 »
  static String kwh(double value) => _decimal1.format(value);

  /// 1357.8 → « 1 358 FCFA »
  static String fcfa(num value) => '${_integer.format(value.round())} FCFA';

  /// -0.08 → « −8 % » ; 0.12 → « +12 % »
  static String percentDelta(double ratio) {
    final p = (ratio * 100).round();
    if (p == 0) return '0 %';
    return p > 0 ? '+$p %' : '−${p.abs()} %';
  }

  /// 80 h → « 3 j 8 h » ; 21 h → « 21 h » ; 50 min → « 50 min ».
  /// Au-delà d'une heure, arrondi à l'heure la plus proche
  /// (85 h 51 min → « 3 j 14 h »).
  static String duration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    final totalHours = (d.inMinutes / 60).round();
    final days = totalHours ~/ 24;
    final hours = totalHours % 24;
    if (days > 0) return hours > 0 ? '$days j $hours h' : '$days j';
    return '$totalHours h';
  }

  /// Écart signé en heures : −5 h 51 → « −6 h » ; 3 h → « +3 h ».
  static String signedHours(Duration d) {
    final h = (d.inMinutes / 60).round();
    if (h == 0) return '0 h';
    return h > 0 ? '+$h h' : '−${h.abs()} h';
  }

  /// « vendredi 9 octobre » → avec majuscule : « Vendredi 9 octobre »
  static String dayLong(DateTime date) =>
      _capitalize(DateFormat('EEEE d MMMM', 'fr_FR').format(date));

  /// « lundi 12 octobre 2026 à 21 h 35 »
  static String dateTimeLong(DateTime date) {
    final day = DateFormat('EEEE d MMMM y', 'fr_FR').format(date);
    return '$day à ${time(date)}';
  }

  /// « 12 oct. »
  static String dayShort(DateTime date) =>
      DateFormat('d MMM', 'fr_FR').format(date);

  /// « Ven. 9 oct. »
  static String dayMedium(DateTime date) =>
      _capitalize(DateFormat('EEE d MMM', 'fr_FR').format(date));

  /// « 09/10/2026 »
  static String dateNumeric(DateTime date) =>
      DateFormat('dd/MM/y', 'fr_FR').format(date);

  /// « 21 h 35 » ; « 21 h » si minutes nulles
  static String time(DateTime date) {
    final m = date.minute;
    return m == 0
        ? '${date.hour} h'
        : '${date.hour} h ${m.toString().padLeft(2, '0')}';
  }

  /// Initiale du jour : « Lun », « Mar »…
  static String weekdayShort(DateTime date) =>
      _capitalize(DateFormat('E', 'fr_FR').format(date).replaceAll('.', ''));

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}