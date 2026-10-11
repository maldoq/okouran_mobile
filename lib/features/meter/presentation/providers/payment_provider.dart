import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/domain/recharge.dart';
import '../../../history/presentation/providers/recharge_providers.dart';
import '../../data/mock_payment_repository.dart';
import '../../domain/payment.dart';
import '../../domain/recharge_quote.dart';
import 'meter_providers.dart';

final paymentRepositoryProvider =
    Provider<MockPaymentRepository>((ref) => const MockPaymentRepository());

class PaymentState {
  const PaymentState({
    this.method = PaymentMethod.orangeMoney,
    this.isPaying = false,
    this.error,
    this.receipt,
  });

  final PaymentMethod method;
  final bool isPaying;
  final String? error;

  /// Rempli quand le paiement a réussi : l'écran affiche alors le reçu.
  final PaymentReceipt? receipt;

  PaymentState copyWith({
    PaymentMethod? method,
    bool? isPaying,
    String? error,
    PaymentReceipt? receipt,
    bool clearError = false,
  }) =>
      PaymentState(
        method: method ?? this.method,
        isPaying: isPaying ?? this.isPaying,
        error: clearError ? null : (error ?? this.error),
        receipt: receipt ?? this.receipt,
      );
}

class PaymentController extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void select(PaymentMethod m) =>
      state = state.copyWith(method: m, clearError: true);

  /// Paie la recharge. Un second appui pendant le paiement est ignoré :
  /// un double appui ne peut pas déclencher un second débit.
  Future<void> pay(RechargeQuote quote) async {
    if (state.isPaying || state.receipt != null) return;
    state = state.copyWith(isPaying: true, clearError: true);
    try {
      final receipt = await ref
          .read(paymentRepositoryProvider)
          .pay(quote: quote, method: state.method);

      // Effets d'une recharge réussie sur le reste de l'app.
      ref.read(metersProvider.notifier).applyRecharge(
            quote.meter.id,
            kwh: receipt.kwh,
            autonomy: receipt.newAutonomy,
            cutoff: receipt.newCutoff,
          );
      ref.read(rechargesProvider.notifier).add(Recharge(
            id: receipt.reference,
            meterId: quote.meter.id,
            meterName: quote.meter.name,
            date: receipt.date,
            amountFcfa: receipt.amountFcfa,
            kwh: receipt.kwh,
            status: RechargeStatus.success,
            method: receipt.method.label,
          ));

      state = state.copyWith(isPaying: false, receipt: receipt);
    } on PaymentFailure catch (e) {
      state = state.copyWith(isPaying: false, error: e.message);
    }
  }
}

final paymentControllerProvider =
    NotifierProvider.autoDispose<PaymentController, PaymentState>(
  PaymentController.new,
);