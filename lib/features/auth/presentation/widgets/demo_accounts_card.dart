import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../data/mock_auth_repository.dart';

/// Carte « Comptes de démonstration » de l'écran de connexion :
/// toucher un profil remplit le formulaire (numéro + mot de passe).
class DemoAccountsCard extends StatelessWidget {
  const DemoAccountsCard({super.key, required this.onPick});

  final ValueChanged<DemoAccount> onPick;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD3B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMPTES DE DÉMONSTRATION', style: text.labelSmall?.copyWith(color: AppColors.orangeDeep)),
          const SizedBox(height: 4),
          Text('Touchez un profil pour remplir le formulaire.', style: text.bodySmall),
          const SizedBox(height: 4),
          for (final a in demoAccounts)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onPick(a),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: a.user.id == 'u2' ? AppColors.secondary : AppColors.accent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(a.user.initials, style: AppTextStyles.brandName(13)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${a.user.fullName} · ${a.user.commune ?? ''}', style: text.titleSmall),
                          Text('${PhoneField.format(a.user.phone, withPrefix: false)} · ${a.password}',
                              style: AppTextStyles.code(11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: a.user.id == 'u2' ? AppColors.warningBg : AppColors.successBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(a.scenario.toUpperCase(),
                          style: text.labelSmall?.copyWith(
                              fontSize: 8.5,
                              letterSpacing: .4,
                              color: a.user.id == 'u2' ? const Color(0xFF7A4A00) : const Color(0xFF0B5A2E))),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
