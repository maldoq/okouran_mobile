import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../data/mock_recharge_offers.dart';
import '../../domain/recharge_quote.dart';
import '../providers/meter_providers.dart';
import '../providers/recharge_quote_provider.dart';
import '../widgets/meter_picker_sheet.dart';
import '../widgets/meter_style.dart';

/// Écran 11 : Recharger (choix du montant).
///
/// Chaque montant est converti en kWh et surtout en jours d'autonomie
/// gagnés, à partir du tarif et du rythme de consommation du compteur.
/// Aucun paiement n'est branché : « Continuer » ouvre l'écran de paiement
/// (simulé plus tard).
class RechargeScreen extends ConsumerWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(selectedMeterProvider);
    final amount = ref.watch(rechargeAmountProvider);
    final quote = ref.watch(rechargeQuoteProvider(amount));
    final text = Theme.of(context).textTheme;

    // Suggestion : montant pour tenir 7 jours de plus.
    final suggested = RechargeQuote.amountForDays(meter, 7);

    void setAmount(int v) =>
        ref.read(rechargeAmountProvider.notifier).state = v;

    final isCustom = !rechargeAmounts.contains(amount);

    return Scaffold(
      appBar: AppTopBar(
        title: 'Recharger',
        trailing: Text('1 / 2',
            style: text.bodySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()])),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          // ---- Compteur à recharger ----
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => showMeterPicker(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(meterKindIcon(meter.kind),
                        size: 26, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meter.name, style: text.titleSmall),
                          Text(
                            '${meter.number} · ${meter.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(fontSize: 10.5),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              StatusPill(
                                label: '${Fmt.kwh(meter.balanceKwh)} kWh',
                                tone: riskTone(meter.risk),
                              ),
                              StatusPill(
                                label: meter.remoteRecharge
                                    ? 'à distance'
                                    : 'code manuel',
                                tone: riskTone(meter.risk),
                                showLed: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.unfold_more_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ---- Récapitulatif du montant ----
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 16),
              child: Column(
                children: [
                  Text('MONTANT À PAYER', style: text.labelSmall),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: amount.toDouble()),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: Fmt.fcfa(v).replaceAll(' FCFA', '')),
                        TextSpan(
                          text: ' F',
                          style: text.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ]),
                      style: text.displayMedium?.copyWith(
                        fontSize: 40,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        _figure(text, Fmt.kwh(quote.kwhBought), 'kWh achetés',
                            AppColors.secondary),
                        const VerticalDivider(width: 1),
                        _figure(text, '+${Fmt.duration(quote.addedAutonomy)}',
                            'd\'autonomie', AppColors.success),
                        const VerticalDivider(width: 1),
                        _figure(text, Fmt.kwh(quote.totalKwh), 'kWh au total',
                            AppColors.textPrimary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nouvelle coupure estimée : ${Fmt.dateTimeLong(quote.newCutoff)}',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tarif ${meter.tariffPerKwh.round()} FCFA/kWh · '
                    'frais de service ${quote.serviceFeeFcfa} FCFA',
                    style: text.bodySmall?.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ),

          // ---- Montants fréquents ----
          const SectionHeader(title: 'Montants fréquents'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.15,
            children: [
              for (final a in rechargeAmounts)
                _AmountTile(
                  title: '${Fmt.fcfa(a).replaceAll(' FCFA', '')} F',
                  quote: ref.watch(rechargeQuoteProvider(a)),
                  selected: a == amount,
                  onTap: () => setAmount(a),
                ),
              _AmountTile(
                title: isCustom
                    ? '${Fmt.fcfa(amount).replaceAll(' FCFA', '')} F'
                    : 'Autre',
                quote: isCustom ? quote : null,
                selected: isCustom,
                onTap: () async {
                  final v = await _askCustomAmount(context, amount);
                  if (v != null) setAmount(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          InfoNote(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Suggestion.',
            message: 'Pour tenir 7 jours de plus à votre rythme actuel '
                '(≈ ${Fmt.kwh(quote.kwhPerDay)} kWh/jour), rechargez '
                'environ ${Fmt.fcfa(suggested)}.',
          ),
          const SizedBox(height: 14),

          AppButton(
            label: 'Continuer · ${Fmt.fcfa(quote.totalToPay)}',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push(AppRoutes.payment, extra: amount),
          ),
          const SizedBox(height: 10),
          Text(
            'Paiement Mobile Money non branché dans cette maquette.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Widget _figure(TextTheme text, String value, String label, Color color) =>
      Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: text.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: text.bodySmall?.copyWith(fontSize: 10)),
          ],
        ),
      );

  /// Boîte de saisie d'un montant libre (500 à 100 000 F).
  Future<int?> _askCustomAmount(BuildContext context, int current) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        void submit() {
          if (formKey.currentState!.validate()) {
            Navigator.pop(ctx, int.parse(ctrl.text));
          }
        }

        return AlertDialog(
          title: const Text('Autre montant'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                hintText: 'Ex. 3 500',
                suffixText: 'FCFA',
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null) return 'Saisissez un montant';
                if (n < minRechargeAmount) {
                  return 'Minimum ${Fmt.fcfa(minRechargeAmount)}';
                }
                if (n > maxRechargeAmount) {
                  return 'Maximum ${Fmt.fcfa(maxRechargeAmount)}';
                }
                return null;
              },
              onFieldSubmitted: (_) => submit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: submit,
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }
}

/// Raccourci de montant : montant, kWh et jours gagnés.
class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.title,
    required this.quote,
    required this.selected,
    required this.onTap,
  });

  final String title;

  /// null pour la tuile « Autre » non encore remplie.
  final RechargeQuote? quote;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: .06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: text.titleSmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            if (quote == null)
              Text('saisir…', style: text.bodySmall?.copyWith(fontSize: 10))
            else ...[
              Text('${Fmt.kwh(quote!.kwhBought)} kWh',
                  style: text.bodySmall?.copyWith(fontSize: 10)),
              Text(
                '+${Fmt.duration(quote!.addedAutonomy)}',
                style: text.bodySmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}