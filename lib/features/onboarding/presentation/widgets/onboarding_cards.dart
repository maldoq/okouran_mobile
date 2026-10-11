import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/icon_badge.dart';

/// Coque commune des mini-cartes posées sur les photos.
class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 40,
            offset: Offset(0, 18),
            spreadRadius: -14,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Ligne « pastille + titre + sous-titre », commune aux 3 mini-cartes.
class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final BadgeTone tone;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        IconBadge(icon: icon, tone: tone, size: 30),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: text.titleSmall?.copyWith(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(subtitle,
                  style: text.bodySmall?.copyWith(
                      fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Barre de niveau fine.
class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: const Color(0xFFF0F4F6),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

/// Page 1 : solde traduit en jours.
class BalanceMiniCard extends StatelessWidget {
  const BalanceMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MiniCard(
      child: Column(
        children: [
          _Header(
            icon: Icons.bolt_rounded,
            tone: BadgeTone.success,
            title: '18,6 kWh restants',
            subtitle: 'Soit ≈ 3 j 8 h',
          ),
          SizedBox(height: 9),
          _LevelBar(value: .62, color: AppColors.success),
        ],
      ),
    );
  }
}

/// Page 2 : alerte crédit faible (reprend la maquette).
class LowCreditMiniCard extends StatelessWidget {
  const LowCreditMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MiniCard(
      child: Column(
        children: [
          _Header(
            icon: Icons.warning_amber_rounded,
            tone: BadgeTone.warning,
            title: 'Crédit faible',
            subtitle: 'Il reste ≈ 1 j 4 h',
          ),
          SizedBox(height: 9),
          _LevelBar(value: .18, color: AppColors.warning),
        ],
      ),
    );
  }
}

/// Page 3 : heure de coupure estimée + effet d'une recharge.
class ForecastMiniCard extends StatelessWidget {
  const ForecastMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _MiniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(
            icon: Icons.schedule_rounded,
            tone: BadgeTone.info,
            title: 'Coupure estimée',
            subtitle: '12 oct. vers 21 h 35',
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline_rounded,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('2 000 FCFA → +2 jours',
                    style: text.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}