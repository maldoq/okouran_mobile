/// Réglages des alertes de l'utilisateur.
///
/// Trois seuils, exprimés en heures d'autonomie restante :
///   - préventif : 72 h (3 jours) ;
///   - fort : 36 h ;
///   - critique : 12 h.
class NotificationSettings {
  const NotificationSettings({
    this.push = true,
    this.sms = true,
    this.whatsapp = false,
    this.voiceCall = false,
    this.anomalies = true,
    this.quietHours = true,
    this.preventiveOn = true,
    this.strongOn = true,
    this.criticalOn = true,
    this.lowCreditThresholdHours = 72,
    this.strongThresholdHours = 36,
    this.criticalThresholdHours = 12,
  });

  /// Canaux.
  final bool push;

  /// SMS pour les alertes critiques (fonctionne sans données mobiles).
  final bool sms;
  final bool whatsapp;

  /// Appel vocal si le SMS critique reste non lu 2 h.
  final bool voiceCall;

  /// Prévenir en cas de consommation inhabituelle.
  final bool anomalies;

  /// Heures silencieuses 22 h – 6 h (sauf alerte critique).
  final bool quietHours;

  /// Seuils activés.
  final bool preventiveOn;
  final bool strongOn;
  final bool criticalOn;

  /// Seuil préventif (« crédit faible »), en heures. Réglable depuis le Profil.
  final int lowCreditThresholdHours;
  final int strongThresholdHours;
  final int criticalThresholdHours;

  NotificationSettings copyWith({
    bool? push,
    bool? sms,
    bool? whatsapp,
    bool? voiceCall,
    bool? anomalies,
    bool? quietHours,
    bool? preventiveOn,
    bool? strongOn,
    bool? criticalOn,
    int? lowCreditThresholdHours,
  }) =>
      NotificationSettings(
        push: push ?? this.push,
        sms: sms ?? this.sms,
        whatsapp: whatsapp ?? this.whatsapp,
        voiceCall: voiceCall ?? this.voiceCall,
        anomalies: anomalies ?? this.anomalies,
        quietHours: quietHours ?? this.quietHours,
        preventiveOn: preventiveOn ?? this.preventiveOn,
        strongOn: strongOn ?? this.strongOn,
        criticalOn: criticalOn ?? this.criticalOn,
        lowCreditThresholdHours:
            lowCreditThresholdHours ?? this.lowCreditThresholdHours,
        strongThresholdHours: strongThresholdHours,
        criticalThresholdHours: criticalThresholdHours,
      );
}