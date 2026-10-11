import 'package:flutter/widgets.dart';

/// Espacements (grille de 4 px).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22; // marge horizontale des écrans (maquette)
  static const double xxl = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: xl);
}

/// Rayons d'arrondi.
abstract final class AppRadius {
  static const double sm = 11; // petits boutons icône
  static const double md = 15; // boutons, champs
  static const double lg = 20; // cartes
  static const double xl = 28; // grandes cartes, logo

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
}

/// Ombres légères.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14013F64),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -6,
    ),
  ];
}
