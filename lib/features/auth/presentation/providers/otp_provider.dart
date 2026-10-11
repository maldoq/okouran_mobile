import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_auth_repository.dart';
import 'auth_providers.dart';
import 'signup_provider.dart';

/// Délai avant de pouvoir redemander un code.
const int otpResendDelaySeconds = 30;

/// État de l'écran OTP.
class OtpState {
  const OtpState({
    this.isLoading = false,
    this.isResending = false,
    this.secondsLeft = otpResendDelaySeconds,
    this.error,
    this.errorCount = 0,
  });

  final bool isLoading;
  final bool isResending;

  /// Secondes restantes avant que « Renvoyer le code » soit disponible.
  final int secondsLeft;

  final String? error;

  /// Incrémenté à chaque erreur : l'écran s'en sert pour relancer
  /// l'animation de secousse même si le message est identique.
  final int errorCount;

  bool get canResend => secondsLeft == 0 && !isResending;

  OtpState copyWith({
    bool? isLoading,
    bool? isResending,
    int? secondsLeft,
    String? error,
    int? errorCount,
    bool clearError = false,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      isResending: isResending ?? this.isResending,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      error: clearError ? null : (error ?? this.error),
      errorCount: errorCount ?? this.errorCount,
    );
  }
}

/// Logique de l'écran OTP : compte à rebours, renvoi, vérification.
class OtpController extends Notifier<OtpState> {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() => _timer?.cancel());
    _startCountdown();
    return const OtpState();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.secondsLeft - 1;
      state = state.copyWith(secondsLeft: left < 0 ? 0 : left);
      if (left <= 0) t.cancel();
    });
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  Future<void> resend(String phone) async {
    if (!state.canResend) return;
    state = state.copyWith(isResending: true, clearError: true);
    await ref.read(authRepositoryProvider).sendOtp(phone: phone);
    state =
        state.copyWith(isResending: false, secondsLeft: otpResendDelaySeconds);
    _startCountdown();
  }

  /// Vérifie le code. Renvoie vrai si le code est bon.
  ///
  /// Si une inscription est en cours, l'utilisateur en attente devient
  /// l'utilisateur connecté ; sinon (connexion par SMS), c'est l'utilisateur
  /// fictif qui est connecté.
  Future<bool> verify({required String phone, required String code}) async {
    if (state.isLoading) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(phone: phone, code: code);
      final pending = ref.read(pendingUserProvider);
      // Inscription : le nouveau compte ; connexion par SMS : le compte du numéro.
      ref.read(currentUserProvider.notifier).state = pending?.copyWith(isVerified: true) ??
          ref.read(authRepositoryProvider).findByPhone(phone)?.user ??
          mockUser;
      ref.read(pendingUserProvider.notifier).state = null;
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        errorCount: state.errorCount + 1,
      );
      return false;
    }
  }
}

final otpControllerProvider =
    NotifierProvider.autoDispose<OtpController, OtpState>(OtpController.new);
