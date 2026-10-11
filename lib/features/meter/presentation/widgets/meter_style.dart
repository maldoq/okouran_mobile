import 'package:flutter/material.dart';

import '../../../../core/widgets/icon_badge.dart';
import '../../domain/meter.dart';

/// Icône du lieu selon le type de compteur.
IconData meterKindIcon(MeterKind kind) => switch (kind) {
      MeterKind.home => Icons.home_rounded,
      MeterKind.office => Icons.business_rounded,
      MeterKind.family => Icons.family_restroom_rounded,
      MeterKind.workshop => Icons.handyman_rounded,
    };

/// Ton (couleur + fond) associé au niveau de risque.
BadgeTone riskTone(RiskLevel risk) => switch (risk) {
      RiskLevel.low => BadgeTone.success,
      RiskLevel.medium => BadgeTone.warning,
      RiskLevel.high => BadgeTone.danger,
    };

/// Ton associé à l'état de liaison du compteur.
BadgeTone statusTone(MeterStatus status) => switch (status) {
      MeterStatus.active => BadgeTone.success,
      MeterStatus.offline => BadgeTone.neutral,
    };
/// Emoji du lieu (utilisé dans les listes compactes, comme la version HTML).
String meterKindEmoji(MeterKind kind) => switch (kind) {
      MeterKind.home => '🏠',
      MeterKind.office => '🏢',
      MeterKind.family => '🏡',
      MeterKind.workshop => '🛠️',
    };

/// Libellé du type de lieu.
String meterKindLabel(MeterKind kind) => switch (kind) {
      MeterKind.home => 'Maison',
      MeterKind.office => 'Bureau',
      MeterKind.family => 'Famille',
      MeterKind.workshop => 'Atelier',
    };
