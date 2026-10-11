import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/mock_auth_repository.dart';
import '../../domain/app_user.dart';

/// Dépôt d'authentification (simulé). À remplacer par le vrai plus tard.
final authRepositoryProvider =
    Provider<MockAuthRepository>((ref) => MockAuthRepository());

/// Utilisateur connecté, ou null si personne n'est connecté.
final currentUserProvider = StateProvider<AppUser?>((ref) => null);

/// État du formulaire de connexion.
class LoginState {
  const LoginState({
    this.isLoading = false,
    this.rememberMe = true,
    this.obscurePassword = true,
    this.error,
  });

  final bool isLoading;
  final bool rememberMe;
  final bool obscurePassword;

  /// Message d'erreur à afficher sous le formulaire.
  final String? error;

  LoginState copyWith({
    bool? isLoading,
    bool? rememberMe,
    bool? obscurePassword,
    String? error,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Logique de l'écran de connexion.
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void toggleRememberMe() =>
      state = state.copyWith(rememberMe: !state.rememberMe);

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Connexion par mot de passe. Renvoie vrai si elle a réussi.
  Future<bool> signIn({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithPassword(phone: phone, password: password);
      ref.read(currentUserProvider.notifier).state = user;
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }
}

final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
  LoginController.new,
);
