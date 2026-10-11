import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/recharge.dart';

extension RechargeStatusStyle on RechargeStatus {
  BadgeTone get tone => switch (this) {
        RechargeStatus.success => BadgeTone.success,
        RechargeStatus.pending => BadgeTone.warning,
        RechargeStatus.refunded => BadgeTone.danger,
      };
}

/// Carte d'une recharge : liseré coloré selon l'issue, compteur, date,
/// montant, kWh crédités, moyen de paiement et éventuelle action.
class RechargeCard extends StatelessWidget {
  const RechargeCard({super.key, required this.recharge, this.onAction});

  final Recharge recharge;

  /// Action liée à l'état (voir le justificatif, saisir le code…).
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final r = recharge;
    final tone = r.status.tone;
    final action = switch (r.status) {
      RechargeStatus.refunded => 'Voir le justificatif de remboursement →',
      RechargeStatus.pending => 'Code disponible pour saisie manuelle →',
      RechargeStatus.success => null,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: tone.color), // liseré
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                  text: r.meterName,
                                  style: text.titleSmall
                                      ?.copyWith(fontSize: 12.5)),
                              TextSpan(
                                text:
                                    '  ·  ${Fmt.dateNumeric(r.date)} à ${Fmt.time(r.date)}',
                                style: text.bodySmall?.copyWith(fontSize: 10.5),
                              ),
                            ]),
                          ),
                        ),
                        Text(
                          Fmt.fcfa(r.amountFcfa),
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusPill(label: r.status.label, tone: tone),
                        const Spacer(),
                        Text(
                          r.kwh == null ? 'non crédité' : '+${Fmt.kwh(r.kwh!)} kWh',
                          style: text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: r.kwh == null
                                ? AppColors.textSecondary
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      r.note == null ? r.method : '${r.method} · ${r.note}',
                      style: text.bodySmall?.copyWith(fontSize: 10.5),
                    ),
                    if (action != null)
                      GestureDetector(
                        onTap: onAction,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            action,
                            style: text.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: r.status == RechargeStatus.pending
                                  ? AppColors.warning
                                  : AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}