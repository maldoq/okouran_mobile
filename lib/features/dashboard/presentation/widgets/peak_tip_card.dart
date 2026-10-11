import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/icon_badge.dart';

/// Carte conseil sur l'heure de pointe (contenu simulé, marqué « estimé »).
class PeakTipCard extends StatelessWidget {
  const PeakTipCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2D9A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBadge(
              icon: Icons.lightbulb_outline_rounded, tone: BadgeTone.warning),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Votre pic est entre 18 h et 22 h',
                        style: text.titleSmall?.copyWith(fontSize: 12.5)),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ESTIMÉ',
                        style: text.labelSmall?.copyWith(
                            fontSize: 8.5, color: const Color(0xFF8A5A00)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '41 % de votre consommation quotidienne tient dans ces '
                  'quatre heures. Trois gestes peuvent vous faire gagner '
                  '≈ 1 j d\'autonomie.',
                  style: text.bodySmall?.copyWith(fontSize: 10.5, height: 1.5),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Voir les conseils →',
                      style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}