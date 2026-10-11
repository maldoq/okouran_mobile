import '../domain/app_user.dart';

/// Utilisateur fictif de la maquette (numéro repris de la maquette).
const AppUser mockUser = AppUser(
  id: 'u1',
  firstName: 'Aya',
  lastName: 'Kouassi',
  phone: '0708442190',
  email: 'aya.kouassi@exemple.ci',
  commune: 'Cocody',
);

const List<DemoAccount> demoAccounts = [
  DemoAccount(
    user: mockUser,
    password: '1234',
    scenario: 'Consommation normale',
  ),
  DemoAccount(
    user: AppUser(
      id: 'u2',
      firstName: 'Koffi',
      lastName: 'Yao',
      phone: '0708442191',
      commune: 'Yopougon',
    ),
    password: '5678',
    scenario: 'Crédit critique et anomalie',
  ),
];

class DemoAccount {
  const DemoAccount({
    required this.user,
    required this.password,
    required this.scenario,
  });

  final AppUser user;
  final String password;
  final String scenario;
}

/// Authentification simulée : aucun appel réseau.
///
/// Les délais imitent un vrai serveur pour que les états de chargement
/// soient visibles. Le futur dépôt branché sur l'API exposera les mêmes
/// méthodes : l'interface n'aura pas à changer.
class MockAuthRepository {
  const MockAuthRepository();

  /// Accepte tout numéro valide et tout mot de passe d'au moins 4 caractères.
  /// Le mot de passe « 0000 » simule un refus, pour tester l'affichage d'erreur.
  Future<AppUser> signInWithPassword({
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (password == '0000') {
      throw const AuthFailure('Numéro ou mot de passe incorrect.');
    }
    return findByPhone(phone)?.user ?? mockUser;
  }

  /// Simule la création d'un compte. Le compte n'est actif qu'après la
  /// vérification du code SMS (écran OTP).
  /// Le numéro « 0101010101 » simule un numéro déjà inscrit.
  Future<AppUser> register({
    required String fullName,
    required String phone,
    required String commune,
    String? email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (phone == '0101010101') {
      throw const AuthFailure(
          'Ce numéro a déjà un compte. Connectez-vous plutôt.');
    }
    // « KOUASSI Aya Marie » → nom = premier mot, prénoms = le reste.
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return AppUser(
      id: 'user_$phone',
      lastName: parts.first,
      firstName: parts.skip(1).join(' '),
      phone: phone,
      email: email,
      commune: commune,
    );
  }

  DemoAccount? findByPhone(String phone) {
    for (final account in demoAccounts) {
      if (account.user.phone == phone) return account;
    }
    return null;
  }

  /// Code SMS accepté par la simulation (affiché à l'écran en démo).
  static const String demoOtp = '123456';

  /// Simule l'envoi d'un nouveau code SMS.
  Future<void> sendOtp({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  /// Simule la vérification du code SMS.
  Future<void> verifyOtp({required String phone, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (code != demoOtp) {
      throw const AuthFailure('Code incorrect. Vérifiez le SMS et réessayez.');
    }
  }

  /// Simule une connexion par empreinte réussie.
  Future<AppUser> signInWithBiometrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    return mockUser;
  }
}

/// Erreur d'authentification lisible par l'utilisateur.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
