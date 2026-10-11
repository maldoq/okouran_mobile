import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../domain/payment.dart';

/// Écran de confirmation après un paiement réussi : reçu, code de recharge,
/// nouveau solde et nouvelle date de coupure.
class PaymentReceiptView extends StatelessWidget {
  const PaymentReceiptView({
    super.key,
    required this.receipt,
    required this.meterName,
  });

  final PaymentReceipt receipt;
  final String meterName;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final r = receipt;

    Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(label, style: text.bodySmall)),
              Text(value,
                  style: text.titleSmall?.copyWith(
                      fontSize: 12.5,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
      children: [
        // Coche animée.
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, t, child) =>
                Transform.scale(scale: t, child: child),
            child: Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 42, color: AppColors.success),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Recharge réussie',
            textAlign: TextAlign.center, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '+${Fmt.kwh(r.kwh)} kWh sur $meterName',
          textAlign: TextAlign.center,
          style: text.bodyMedium,
        ),
        const SizedBox(height: 18),

        // Code de recharge.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Text('CODE DE RECHARGE', style: text.labelSmall),
                const SizedBox(height: 8),
                SelectableText(
                  r.rechargeCode,
                  textAlign: TextAlign.center,
                  style: text.titleLarge?.copyWith(
                    letterSpacing: 1.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: r.rechargeCode.replaceAll(' ', '')));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Code copié'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copier le code'),
                ),
                const SizedBox(height: 4),
                r.remote
                    ? const InfoNote(
                        icon: Icons.wifi_tethering_rounded,
                        tone: BadgeTone.success,
                        title: 'Transmis au compteur.',
                        message: 'Rien à saisir : le crédit est ajouté '
                            'automatiquement. Le code reste ici en secours.',
                      )
                    : const InfoNote(
                        icon: Icons.dialpad_rounded,
                        tone: BadgeTone.warning,
                        title: 'À saisir sur le compteur.',
                        message: 'Tapez ces 20 chiffres sur le clavier du '
                            'compteur, puis validez. Le code reste consultable '
                            'dans l\'historique, même hors connexion.',
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Reçu.
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Column(
              children: [
                line('Montant payé', Fmt.fcfa(r.amountFcfa)),
                line('Moyen de paiement', r.method.label),
                line('Nouveau solde', '${Fmt.kwh(r.newBalanceKwh)} kWh'),
                line('Nouvelle autonomie', Fmt.duration(r.newAutonomy)),
                line('Coupure estimée',
                    '${Fmt.dayMedium(r.newCutoff)} ${Fmt.time(r.newCutoff)}'),
                line('Référence', r.reference),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Retour à l\'accueil',
          icon: Icons.home_rounded,
          variant: AppButtonVariant.dark,
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Voir l\'historique des recharges',
          variant: AppButtonVariant.outline,
          size: AppButtonSize.small,
          onPressed: () {
            // Routeur récupéré avant `go` : cet écran disparaît ensuite.
            final router = GoRouter.of(context);
            router.go(AppRoutes.dashboard);
            router.push(AppRoutes.history);
          },
        ),
      ],
    );
  }
}