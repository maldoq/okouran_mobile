import '../domain/meter.dart';
import '../domain/meter_lookup.dart';
import 'mock_meters.dart';

/// Identification de compteur simulée (aucun appel au distributeur).
///
/// Règles de la démo, pour tester tous les cas :
///   - le numéro doit commencer par « 04 », sinon : compteur introuvable ;
///   - dernier chiffre pair  → compteur communicant (recharge à distance) ;
///   - dernier chiffre impair → compteur à touches (code à saisir).
class MockMeterRepository {
  const MockMeterRepository();

  /// Numéro renvoyé par le « scan » du QR code de la facture.
  static const String scannedNumber = '045144723306';

  Future<String> scanQrCode() async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    return scannedNumber;
  }

  /// [digits] : 12 chiffres sans espaces.
  Future<MeterLookup> lookup(String digits) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!digits.startsWith('04')) {
      throw const MeterLookupFailure(
          'Compteur introuvable. Vérifiez le numéro sur votre facture.');
    }
    final remote = int.parse(digits[digits.length - 1]).isEven;
    return MeterLookup(
      number: groupBy4(digits),
      holder: 'KOUASSI A.',
      location: 'Riviera Palmeraie, Abidjan',
      tariffLabel: 'tarif domestique prépayé',
      type: 'Prépayé monophasé',
      remoteRecharge: remote,
    );
  }

  /// Crée le compteur suivi. Solde et autonomie sont simulés :
  /// en réalité ils viendraient du premier relevé.
  Meter create(MeterLookup lookup, NewMeterInput input, String id) {
    const autonomy = Duration(days: 2, hours: 4);
    return Meter(
      id: id,
      name: input.name,
      number: lookup.number,
      location: lookup.location,
      type: lookup.type,
      kind: input.kind,
      status: MeterStatus.active,
      balanceKwh: 12.4,
      tariffPerKwh: 73,
      usualRechargeKwh: 40,
      autonomy: autonomy,
      estimatedCutoff: mockNow.add(autonomy),
      remoteRecharge: lookup.remoteRecharge,
    );
  }

  /// « 045144723306 » → « 0451 4472 3306 »
  static String groupBy4(String digits) {
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(digits[i]);
    }
    return b.toString();
  }
}

class MeterLookupFailure implements Exception {
  const MeterLookupFailure(this.message);
  final String message;

  @override
  String toString() => message;
}