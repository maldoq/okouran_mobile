/// Utilisateur connecté (simulé pour la maquette).
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.commune,
    this.isVerified = true,
  });

  final String id;
  final String firstName;
  final String lastName;

  /// 10 chiffres, sans indicatif ni espaces.
  final String phone;

  /// Facultatif (sert aux reçus).
  final String? email;

  /// Commune de résidence, si elle est connue.
  final String? commune;

  /// Numéro vérifié par code SMS.
  final bool isVerified;

  String get fullName => '$firstName $lastName';

  /// Initiales pour l'avatar : « Aya Kouassi » → « AK ».
  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    return '${f.isEmpty ? '' : f[0]}${l.isEmpty ? '' : l[0]}'.toUpperCase();
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? commune,
    bool? isVerified,
    bool clearEmail = false,
    bool clearCommune = false,
  }) =>
      AppUser(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone,
        email: clearEmail ? null : (email ?? this.email),
        commune: clearCommune ? null : (commune ?? this.commune),
        isVerified: isVerified ?? this.isVerified,
      );
}
