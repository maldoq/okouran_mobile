import '../domain/payment.dart';
import '../domain/recharge_quote.dart';

/// Paiement simulé : aucun débit réel, aucun opérateur contacté.
///
/// Règle de la démo : Moov Money échoue (solde insuffisant), pour tester
/// l'affichage d'erreur. Les autres moyens réussissent après 2 s.
class MockPaymentRepository {
  const MockPaymentRepository();

  Future<PaymentReceipt> pay({
    required RechargeQuote quote,
    required PaymentMethod method,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (method == PaymentMethod.moovMoney) {
      throw const PaymentFailure(
          'Solde Moov Money insuffisant. Aucun montant n\'a été débité.');
    }
    final now = quote.now;
    final seed = now.millisecondsSinceEpoch + quote.amountFcfa;
    return PaymentReceipt(
      reference: 'OK-${now.day.toString().padLeft(2, '0')}'
          '${now.month.toString().padLeft(2, '0')}-${seed % 100000}',
      amountFcfa: quote.amountFcfa,
      kwh: quote.kwhBought,
      method: method,
      date: now,
      remote: quote.meter.remoteRecharge,
      rechargeCode: _fakeCode(seed),
      newBalanceKwh: quote.totalKwh,
      newAutonomy: quote.newAutonomy,
      newCutoff: quote.newCutoff,
    );
  }

  /// Code de 20 chiffres groupés par 4, fabriqué à partir d'un nombre.
  static String _fakeCode(int seed) {
    final digits = StringBuffer();
    var x = seed;
    while (digits.length < 20) {
      x = (x * 1103515245 + 12345) & 0x7fffffff; // générateur pseudo-aléatoire
      digits.write(x % 10);
    }
    final s = digits.toString();
    return [for (var i = 0; i < 20; i += 4) s.substring(i, i + 4)].join(' ');
  }
}

class PaymentFailure implements Exception {
  const PaymentFailure(this.message);
  final String message;

  @override
  String toString() => message;
}