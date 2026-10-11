import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/meter_lookup.dart';

/// « Capacités détectées » : ce que le compteur permet, annoncé avant l'ajout.
class MeterCapabilitiesCard extends StatelessWidget {
  const MeterCapabilitiesCard({super.key, required this.lookup});

  final MeterLookup lookup;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remote = lookup.remoteRecharge;

    Widget row(bool ok, String title, String sub) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 18,
                color: ok ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: text.titleSmall?.copyWith(fontSize: 12.5)),
                    Text(
                      sub,
                      style: text.bodySmall?.copyWith(
                        fontSize: 10.5,
                        color: ok ? null : const Color(0xFF8E211D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: remote ? const Color(0xFFF4FBF6) : const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: remote ? const Color(0xFFBFE6CC) : const Color(0xFFF2D9A8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CAPACITÉS DÉTECTÉES',
                  style: text.labelSmall?.copyWith(
                    color: remote
                        ? const Color(0xFF0A5C39)
                        : const Color(0xFF8A5A00),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: remote ? AppColors.successBg : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  remote ? 'Compteur communicant' : 'Compteur à touches',
                  style: text.labelSmall?.copyWith(
                    fontSize: 9.5,
                    letterSpacing: .2,
                    color: remote
                        ? const Color(0xFF0A5C39)
                        : const Color(0xFF8A5A00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          row(true, 'Suivi du crédit et de la consommation',
              'Relevés via la plateforme du distributeur'),
          row(true, 'Alertes, prévision, achat de recharge',
              'Disponible immédiatement'),
          row(
            remote,
            'Transmission du code à distance',
            remote
                ? 'Le code est envoyé directement au compteur après paiement.'
                : 'Non disponible sur ce compteur. Le code vous sera affiché '
                    'et devra être saisi sur le clavier du compteur.',
          ),
        ],
      ),
    );
  }
}