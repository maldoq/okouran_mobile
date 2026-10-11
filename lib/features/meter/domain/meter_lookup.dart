import 'meter.dart';

/// Résultat de l'identification d'un compteur à partir de son numéro.
/// Annonce ce que le compteur sait faire avant de promettre quoi que ce soit.
class MeterLookup {
  const MeterLookup({
    required this.number,
    required this.holder,
    required this.location,
    required this.tariffLabel,
    required this.type,
    required this.remoteRecharge,
  });

  /// Numéro groupé par 4 : « 0451 8823 7194 ».
  final String number;

  /// Titulaire de l'abonnement, tel qu'enregistré chez le distributeur.
  final String holder;
  final String location;
  final String tariffLabel;
  final String type;

  /// Compteur communicant : le code de recharge peut être transmis à distance.
  /// Sinon (compteur à touches), il faut saisir le code sur le clavier.
  final bool remoteRecharge;
}

/// Ce que l'utilisateur a choisi pour nommer le compteur.
class NewMeterInput {
  const NewMeterInput({required this.name, required this.kind});
  final String name;
  final MeterKind kind;
}