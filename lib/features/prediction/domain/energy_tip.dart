import 'package:flutter/widgets.dart';

/// Conseil d'économie, chiffré en kWh économisés par semaine.
/// Les heures d'autonomie gagnées sont calculées à l'affichage,
/// avec le rythme de consommation du compteur choisi.
class EnergyTip {
  const EnergyTip({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.kwhPerWeek,
  });

  final String id;
  final IconData icon;
  final Color color;
  final String title;

  /// Pourquoi ce conseil concerne ce foyer.
  final String detail;

  /// Économie estimée, en kWh par semaine.
  final double kwhPerWeek;
}