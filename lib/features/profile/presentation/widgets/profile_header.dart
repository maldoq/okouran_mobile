import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../auth/domain/app_user.dart';

/// En-tête bleu nuit du profil : avatar à initiales, nom, numéro, statut.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.onSettings,
  });

  final AppUser user;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(18, topInset + 10, 18, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Mon profil',
                    style: text.titleLarge?.copyWith(color: Colors.white)),
              ),
              Material(
                color: Colors.white.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onSettings,
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox.square(
                    dimension: 40,
                    child: Icon(Icons.settings_outlined,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Avatar à initiales.
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, Color(0xFF6E9420)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.initials,
                  style: text.headlineSmall?.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName,
                        style: text.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                      PhoneField.format(user.phone),
                      style: text.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: .65),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusPill(
                      label: user.isVerified
                          ? 'Compte vérifié'
                          : 'Numéro à vérifier',
                      tone: user.isVerified
                          ? BadgeTone.success
                          : BadgeTone.warning,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}