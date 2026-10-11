import 'package:flutter/painting.dart';

/// Moyens de paiement proposés (tous simulés dans la maquette).
enum PaymentMethod {
  orangeMoney('Orange Money', 'OM', Color(0xFFFF7900), '07 08 44 21 90'),
  mtnMomo('MTN MoMo', 'MTN', Color(0xFFFFCC00), '05 •• •• •• 12'),
  moovMoney('Moov Money', 'MOOV', Color(0xFF0066B3), '01 •• •• •• 47'),
  wave('Wave', 'WAVE', Color(0xFF1DC8FF), '07 08 44 21 90');

  const PaymentMethod(this.label, this.short, this.color, this.account);

  final String label;

  /// Sigle affiché dans la pastille de couleur.
  final String short;
  final Color color;

  /// Numéro du compte Mobile Money (masqué sauf le principal).
  final String account;
}

/// Reçu d'une recharge payée.
class PaymentReceipt {
  const PaymentReceipt({
    required this.reference,
    required this.amountFcfa,
    required this.kwh,
    required this.method,
    required this.date,
    required this.remote,
    required this.rechargeCode,
    required this.newBalanceKwh,
    required this.newAutonomy,
    required this.newCutoff,
  });

  /// Référence de la transaction (ex. « OK-2610-48213 »).
  final String reference;
  final int amountFcfa;
  final double kwh;
  final PaymentMethod method;
  final DateTime date;

  /// Vrai si le code a été transmis au compteur à distance.
  final bool remote;

  /// Code de recharge à 20 chiffres (à saisir sur un compteur à touches).
  final String rechargeCode;

  final double newBalanceKwh;
  final Duration newAutonomy;
  final DateTime newCutoff;
}