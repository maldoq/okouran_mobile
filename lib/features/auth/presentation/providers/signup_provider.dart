import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/mock_auth_repository.dart';
import '../../domain/app_user.dart';
import 'auth_providers.dart';

/// État du formulaire d'inscription.
class SignupState {
  const SignupState({
    this.isLoading = false,
    this.acceptedTerms = false,
    this.obscurePassword = true,
    this.error,
  });

  final bool isLoading;

  /// Conditions acceptées : obligatoire pour continuer.
  final bool acceptedTerms;
  final bool obscurePassword;
  final String? error;

  SignupState copyWith({
    bool? isLoading,
    bool? acceptedTerms,
    bool? obscurePassword,
    String? error,
    bool clearError = false,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Utilisateur en cours d'inscription, en attente de vérification SMS.
/// L'écran OTP le lira, puis le passera dans [currentUserProvider].
final pendingUserProvider = StateProvider<AppUser?>((ref) => null);

class SignupController extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  void toggleTerms() =>
      state = state.copyWith(acceptedTerms: !state.acceptedTerms);

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Crée le compte (simulé). Renvoie vrai si l'étape suivante peut s'ouvrir.
  Future<bool> register({
    required String fullName,
    required String phone,
    required String commune,
    String? email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).register(
            fullName: fullName,
            phone: phone,
            commune: commune,
            email: email,
            password: password,
          );
      ref.read(pendingUserProvider.notifier).state = user;
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }
}

final signupControllerProvider =
    NotifierProvider.autoDispose<SignupController, SignupState>(
  SignupController.new,
);
