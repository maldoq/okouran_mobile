/// Réglages généraux de l'application (en mémoire pour la maquette).
class AppSettings {
  const AppSettings({
    this.dataSaver = true,
    this.offline = true,
    this.autoSync = true,
    this.largeText = false,
    this.highContrast = true,
    this.pinLock = true,
    this.biometrics = true,
    this.autonomyTargetDays = 7,
  });

  /// Objectif d'autonomie qui vaut 100 % sur les jauges (en jours).
  final int autonomyTargetDays;

  /// Graphiques allégés, synchronisation espacée.
  final bool dataSaver;

  /// Derniers relevés, codes et historique gardés sur le téléphone.
  final bool offline;

  /// Synchronisation automatique (30 min en Wi-Fi, 2 h en données mobiles).
  final bool autoSync;

  /// Texte agrandi de 15 % dans toute l'app.
  final bool largeText;

  /// États doublés par une icône, jamais par la couleur seule.
  final bool highContrast;

  /// Code PIN à l'ouverture et avant tout paiement.
  final bool pinLock;

  /// Connexion par empreinte digitale.
  final bool biometrics;

  AppSettings copyWith({
    bool? dataSaver,
    bool? offline,
    bool? autoSync,
    bool? largeText,
    bool? highContrast,
    bool? pinLock,
    bool? biometrics,
    int? autonomyTargetDays,
  }) =>
      AppSettings(
        dataSaver: dataSaver ?? this.dataSaver,
        offline: offline ?? this.offline,
        autoSync: autoSync ?? this.autoSync,
        largeText: largeText ?? this.largeText,
        highContrast: highContrast ?? this.highContrast,
        pinLock: pinLock ?? this.pinLock,
        biometrics: biometrics ?? this.biometrics,
        autonomyTargetDays: autonomyTargetDays ?? this.autonomyTargetDays,
      );
}