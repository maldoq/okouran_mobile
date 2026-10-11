import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/mock_meters.dart';
import '../../data/mock_recharge_offers.dart';
import '../../domain/recharge_quote.dart';
import 'meter_providers.dart';

/// Montant choisi sur l'écran Recharger.
final rechargeAmountProvider =
    StateProvider.autoDispose<int>((ref) => defaultRechargeAmount);

/// Devis d'une recharge pour le compteur sélectionné et un montant donné.
final rechargeQuoteProvider =
    Provider.autoDispose.family<RechargeQuote, int>((ref, amount) {
  return RechargeQuote(
    meter: ref.watch(selectedMeterProvider),
    amountFcfa: amount,
    now: mockNow,
  );
});