import 'package:flutter/material.dart';

import '../domain/energy_tip.dart';

/// Fenêtre horaire où se concentre la consommation (simulée).
const String peakWindow = '18 h – 22 h';

/// Part de la consommation quotidienne dans cette fenêtre (simulée).
const double peakShare = 0.41;

/// Conseils simulés (valeurs de la maquette), du plus au moins rentable.
/// Total : 2,8 + 1,6 + 1,1 + 0,6 = 6,1 kWh par semaine.
const List<EnergyTip> mockTips = [
  EnergyTip(
    id: 'clim',
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF02AAE8),
    title: 'Climatisation à 24 °C au lieu de 21 °C',
    detail: 'Chaque degré en moins coûte de l\'énergie, surtout le soir.',
    kwhPerWeek: 2.8,
  ),
  EnergyTip(
    id: 'fridge',
    icon: Icons.kitchen_outlined,
    color: Color(0xFF3E9EBF),
    title: 'Dégivrer le réfrigérateur (givre de plus de 5 mm)',
    detail: 'Le givre isole : le moteur tourne plus longtemps.',
    kwhPerWeek: 1.6,
  ),
  EnergyTip(
    id: 'bulbs',
    icon: Icons.lightbulb_outline_rounded,
    color: Color(0xFF6FBFD6),
    title: 'Remplacer les 4 dernières lampes à incandescence',
    detail: 'Une lampe LED consomme environ 5 fois moins.',
    kwhPerWeek: 1.1,
  ),
  EnergyTip(
    id: 'standby',
    icon: Icons.power_outlined,
    color: Color(0xFF64748B),
    title: 'Débrancher les chargeurs et la box la nuit',
    detail: 'Les veilles consomment même quand rien ne fonctionne.',
    kwhPerWeek: 0.6,
  ),
];