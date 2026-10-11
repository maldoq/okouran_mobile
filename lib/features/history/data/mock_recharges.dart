import '../domain/recharge.dart';

/// Recharges des 4 compteurs de démonstration (kWh = montant ÷ tarif :
/// 73 F/kWh pour les maisons, 80 F/kWh pour les ateliers).
final List<Recharge> mockRecharges = [
  Recharge(id: 'r1', meterId: 'm1', meterName: 'Maison Cocody', date: DateTime(2026, 10, 6, 18, 42),
      amountFcfa: 2190, kwh: 30, status: RechargeStatus.success, method: 'Wave'),
  Recharge(id: 'r2', meterId: 'm1', meterName: 'Maison Cocody', date: DateTime(2026, 9, 25, 20, 15),
      amountFcfa: 5000, kwh: 68.5, status: RechargeStatus.success, method: 'Orange Money'),
  Recharge(id: 'r3', meterId: 'm1', meterName: 'Maison Cocody', date: DateTime(2026, 9, 18, 9, 40),
      amountFcfa: 2000, kwh: null, status: RechargeStatus.refunded, method: 'Wave',
      note: 'Remboursé le 19/09 · réclamation A-2291 clôturée'),
  Recharge(id: 'r4', meterId: 'm2', meterName: 'Atelier couture', date: DateTime(2026, 10, 5, 8, 10),
      amountFcfa: 3200, kwh: 40, status: RechargeStatus.success, method: 'Orange Money'),
  Recharge(id: 'r5', meterId: 'm2', meterName: 'Atelier couture', date: DateTime(2026, 9, 27, 17, 30),
      amountFcfa: 4000, kwh: 50, status: RechargeStatus.success, method: 'MTN MoMo'),
  Recharge(id: 'r6', meterId: 'm3', meterName: 'Maison Yopougon', date: DateTime(2026, 10, 7, 19, 5),
      amountFcfa: 5000, kwh: 68.5, status: RechargeStatus.success, method: 'Wave'),
  Recharge(id: 'r7', meterId: 'm3', meterName: 'Maison Yopougon', date: DateTime(2026, 9, 29, 12, 20),
      amountFcfa: 3000, kwh: 41.1, status: RechargeStatus.success, method: 'Orange Money'),
  Recharge(id: 'r8', meterId: 'm4', meterName: 'Atelier soudure', date: DateTime(2026, 10, 8, 16, 2),
      amountFcfa: 2000, kwh: 25, status: RechargeStatus.pending, method: 'Moov Money',
      note: "En attente de l'accusé du compteur"),
  Recharge(id: 'r9', meterId: 'm4', meterName: 'Atelier soudure', date: DateTime(2026, 10, 3, 10, 45),
      amountFcfa: 4000, kwh: 50, status: RechargeStatus.success, method: 'Orange Money'),
];
