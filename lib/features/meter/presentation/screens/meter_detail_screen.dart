import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/meter.dart';
import '../providers/meter_providers.dart';
import '../widgets/meter_hero_card.dart';
import '../widgets/meter_style.dart';

/// Écran 7 : Détails du compteur.
///
/// Fiche d'identité (numéro, localisation, type, statut), crédit et
/// prévision en résumé, partage, et actions : recharger, renommer, retirer.
class MeterDetailScreen extends ConsumerWidget {
  const MeterDetailScreen({super.key, required this.meterId});

  final String meterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meter = ref.watch(meterByIdProvider(meterId));

    // Compteur introuvable (ex. retiré) : message simple.
    if (meter == null) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Compteur'),
        body: Center(
          child: Text('Ce compteur n\'existe plus.',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return Scaffold(
      appBar: AppTopBar(
        title: 'Mon compteur',
        trailing: IconButton(
          tooltip: 'Renommer',
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => _rename(context, ref, meter),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          MeterHeroCard(meter: meter),
          const SizedBox(height: 14),
          AppButton(
            label: 'Recharger ce compteur',
            icon: Icons.bolt_rounded,
            onPressed: () => context.push(AppRoutes.recharge),
          ),

          // ---- Informations ----
          const SectionHeader(title: 'Informations'),
          _SectionCard(children: [
            InfoRow(
              icon: Icons.tag_rounded,
              label: 'Numéro du compteur',
              value: meter.number,
              trailing: IconButton(
                tooltip: 'Copier le numéro',
                icon: const Icon(Icons.copy_rounded, size: 18),
                color: AppColors.secondary,
                onPressed: () => _copyNumber(context, meter),
              ),
            ),
            InfoRow(
              icon: Icons.place_outlined,
              label: 'Localisation',
              value: meter.location,
            ),
            InfoRow(
              icon: Icons.electric_meter_outlined,
              label: 'Type',
              value: meter.type,
            ),
            InfoRow(
              icon: Icons.sensors_rounded,
              label: 'Statut',
              value: meter.status.label,
              valueWidget: Align(
                alignment: Alignment.centerLeft,
                child: StatusPill(
                  label: meter.status.label,
                  tone: statusTone(meter.status),
                ),
              ),
            ),
            InfoRow(
              icon: Icons.bolt_outlined,
              label: 'Mode de recharge',
              value: meter.remoteRecharge
                  ? 'Recharge à distance'
                  : 'Code à saisir sur le compteur',
            ),
          ]),

          // ---- Crédit et prévision ----
          const SectionHeader(title: 'Crédit et prévision'),
          _SectionCard(children: [
            InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Solde',
              value:
                  '${Fmt.kwh(meter.balanceKwh)} kWh  ·  ≈ ${Fmt.fcfa(meter.balanceFcfa)}',
            ),
            InfoRow(
              icon: Icons.sell_outlined,
              label: 'Tarif moyen',
              value: '${meter.tariffPerKwh.round()} FCFA / kWh',
            ),
            InfoRow(
              icon: Icons.replay_rounded,
              label: 'Recharge habituelle',
              value: '${Fmt.kwh(meter.usualRechargeKwh)} kWh',
            ),
            InfoRow(
              icon: Icons.event_busy_rounded,
              label: 'Coupure estimée',
              value: Fmt.dateTimeLong(meter.estimatedCutoff),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ),
          ], onLastTap: () => context.push(AppRoutes.forecast)),

          // ---- Partage ----
          const SectionHeader(title: 'Partage'),
          _SectionCard(children: [
            InfoRow(
              icon: Icons.group_outlined,
              label: 'Suivi partagé avec',
              value: meter.sharedWith ?? 'Personne pour l\'instant',
              trailing: TextButton(
                onPressed: () => _snack(context,
                    'Invitation simulée : un lien serait envoyé par SMS.'),
                child: const Text('Inviter'),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          AppButton(
            label: 'Tous mes compteurs',
            icon: Icons.swap_horiz_rounded,
            variant: AppButtonVariant.outline,
            onPressed: () => context.push(AppRoutes.meters),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => _confirmRemove(context, ref, meter),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Retirer ce compteur'),
          ),
        ],
      ),
    );
  }

  // ---- Actions ----

  void _copyNumber(BuildContext context, Meter meter) {
    Clipboard.setData(ClipboardData(text: meter.number.replaceAll(' ', '')));
    _snack(context, 'Numéro du compteur copié');
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Meter meter) async {
    final ctrl = TextEditingController(text: meter.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer le compteur'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Ex. Maison Cocody'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    // Pas de ctrl.dispose() ici : la boîte de dialogue l'utilise encore
    // pendant son animation de fermeture. Le ramasse-miettes s'en charge.
    final value = name?.trim() ?? '';
    if (value.isNotEmpty && value != meter.name) {
      ref.read(metersProvider.notifier).rename(meter.id, value);
    }
  }

  Future<void> _confirmRemove(
      BuildContext context, WidgetRef ref, Meter meter) async {
    if (ref.read(metersProvider).length <= 1) {
      _snack(context, 'Gardez au moins un compteur dans la maquette.');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer ce compteur ?'),
        content: Text(
            '« ${meter.name} » ne sera plus suivi dans O\'kouran. '
            'Vous pourrez l\'ajouter de nouveau avec son numéro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    // Message affiché avant de quitter l'écran (le contexte disparaît ensuite).
    _snack(context, '« ${meter.name} » a été retiré');
    context.pop();
    ref.read(metersProvider.notifier).remove(meter.id);
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
  }
}

/// Carte blanche contenant des [InfoRow] séparées par un filet.
/// [onLastTap] rend la dernière ligne cliquable.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children, this.onLastTap});

  final List<Widget> children;
  final VoidCallback? onLastTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 44),
            InkWell(
              onTap: i == children.length - 1 ? onLastTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: children[i],
              ),
            ),
          ],
        ],
      ),
    );
  }
}