import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/payment.dart';
import '../../domain/recharge_quote.dart';
import '../providers/meter_providers.dart';
import '../providers/payment_provider.dart';
import '../providers/recharge_quote_provider.dart';
import '../widgets/payment_receipt_view.dart';

/// Écran 15 : Paiement (étape 2 / 2 de la recharge).
///
/// Tous les frais sont affichés ligne par ligne, même nuls. Le paiement
/// est simulé : aucun opérateur Mobile Money n'est contacté.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.amountFcfa});

  final int amountFcfa;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  /// Devis figé à l'ouverture : après paiement, le compteur est crédité
  /// et un nouveau calcul donnerait d'autres chiffres.
  late final RechargeQuote _quote =
      ref.read(rechargeQuoteProvider(widget.amountFcfa));

  /// Nom du compteur, figé aussi pour le reçu.
  late final String _meterName = ref.read(selectedMeterProvider).name;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentControllerProvider);
    final controller = ref.read(paymentControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final q = _quote;

    // Paiement réussi : on affiche le reçu à la place du formulaire.
    if (state.receipt != null) {
      return Scaffold(
        body: SafeArea(
          child: PaymentReceiptView(
              receipt: state.receipt!, meterName: _meterName),
        ),
      );
    }

    Widget feeLine(String label, int amount) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(label, style: text.bodySmall)),
              Text('${Fmt.fcfa(amount).replaceAll(' FCFA', '')} F',
                  style: text.titleSmall?.copyWith(
                      fontSize: 12.5,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        );

    return Scaffold(
      appBar: AppTopBar(
        title: 'Paiement',
        trailing: Text('2 / 2', style: text.bodySmall),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
        children: [
          const SectionHeader(title: 'Mobile Money'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, m) in PaymentMethod.values.indexed) ...[
                  if (i > 0) const Divider(indent: 66),
                  _MethodTile(
                    method: m,
                    selected: state.method == m,
                    onTap: state.isPaying ? null : () => controller.select(m),
                  ),
                ],
              ],
            ),
          ),

          const SectionHeader(title: 'Autres moyens'),
          Card(
            child: Column(
              children: [
                _disabledTile(text, Icons.credit_card_rounded, 'Carte bancaire',
                    'Visa · Mastercard · GIM-UEMOA', 'bientôt'),
                const Divider(indent: 66),
                _disabledTile(text, Icons.account_balance_wallet_outlined,
                    'Compte O\'kouran', 'Solde 1 250 FCFA : insuffisant',
                    'indispo.'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Récapitulatif.
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RÉCAPITULATIF', style: text.labelSmall),
                  const SizedBox(height: 4),
                  feeLine('Recharge · ${Fmt.kwh(q.kwhBought)} kWh · $_meterName',
                      q.amountFcfa),
                  feeLine('Frais de service O\'kouran', q.serviceFeeFcfa),
                  feeLine('Frais opérateur Mobile Money', 0),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('Total à débiter',
                                style: text.titleSmall)),
                        Text(
                          '${Fmt.fcfa(q.totalToPay).replaceAll(' FCFA', '')} F',
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const InfoNote(
                    icon: Icons.lock_outline_rounded,
                    tone: BadgeTone.success,
                    message: 'Aucun frais caché. Le montant débité est '
                        'exactement celui affiché ici.',
                  ),
                ],
              ),
            ),
          ),

          if (state.error != null) ...[
            const SizedBox(height: 12),
            InfoNote(
              icon: Icons.error_outline_rounded,
              tone: BadgeTone.danger,
              message: state.error!,
            ),
          ],
          const SizedBox(height: 14),

          AppButton(
            label: 'Payer ${Fmt.fcfa(q.totalToPay)}',
            icon: Icons.lock_rounded,
            loading: state.isPaying,
            onPressed: () => controller.pay(q),
          ),
          const SizedBox(height: 10),
          Text(
            state.isPaying
                ? 'Confirmez sur votre téléphone (${state.method.label})…'
                : 'Vous recevrez une demande de confirmation sur votre '
                    'téléphone. Un appui répété ne déclenche jamais un '
                    'second débit.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(fontSize: 10.5, height: 1.5),
          ),
          const SizedBox(height: 12),
          const InfoNote(
            icon: Icons.science_outlined,
            tone: BadgeTone.neutral,
            title: 'Démo.',
            message: 'Aucun paiement réel. Moov Money simule un refus '
                '(solde insuffisant) ; les autres moyens réussissent.',
          ),
        ],
      ),
    );
  }

  Widget _disabledTile(TextTheme text, IconData icon, String title,
          String subtitle, String tag) =>
      Opacity(
        opacity: .6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Icon(icon, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall?.copyWith(fontSize: 12.5)),
                    Text(subtitle,
                        style: text.bodySmall?.copyWith(fontSize: 10.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4F7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(tag,
                    style: text.bodySmall?.copyWith(
                        fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
}

/// Ligne d'un moyen Mobile Money avec bouton radio.
class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: method.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                method.short,
                style: text.labelSmall?.copyWith(
                  fontSize: 8.5,
                  letterSpacing: .2,
                  color: method == PaymentMethod.mtnMomo
                      ? AppColors.textPrimary
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label,
                      style: text.titleSmall?.copyWith(fontSize: 12.5)),
                  Text(method.account,
                      style: text.bodySmall?.copyWith(
                          fontSize: 10.5,
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
            // Bouton radio.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.secondary : const Color(0xFFD3DDE3),
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}