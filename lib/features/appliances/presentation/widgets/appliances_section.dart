import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../meter/domain/meter.dart';
import '../../../meter/presentation/widgets/meter_style.dart';
import '../providers/appliances_provider.dart';
import 'appliance_form_sheet.dart';

/// Liste des appareils d'un compteur avec ajout / modification / suppression.
/// Utilisée dans Paramètres et dans l'écran « Mes appareils ».
class AppliancesSection extends ConsumerWidget {
  const AppliancesSection({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(meterAppliancesProvider(meter.id));
    final text = Theme.of(context).textTheme;
    final total = items.fold<double>(0, (s, a) => s + a.dailyKwh);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
            child: Row(
              children: [
                Text(meterKindEmoji(meter.kind), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meter.name, style: text.titleSmall),
                      Text('${items.length} appareil${items.length > 1 ? 's' : ''} · ${Fmt.kwh(total)} kWh/j prévus',
                          style: text.bodySmall?.copyWith(fontSize: 10.5)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showApplianceForm(context, meterId: meter.id, tariffPerKwh: meter.tariffPerKwh),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Text('Aucun appareil. Ajoutez-en pour obtenir une prévision et des conseils précis.',
                  style: text.bodySmall),
            ),
          for (final a in items) ...[
            const Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: () => showApplianceForm(context, meterId: meter.id, tariffPerKwh: meter.tariffPerKwh, initial: a),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 9, 4, 9),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.brandBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(a.type.emoji, style: const TextStyle(fontSize: 17)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.quantity > 1 ? '${a.name} ×${a.quantity}' : a.name,
                              style: text.titleSmall?.copyWith(fontSize: 12.5)),
                          Text('${a.watts} W · ${Fmt.kwh(a.hoursPerDay)} h/j · ${a.usage.label}',
                              style: text.bodySmall?.copyWith(fontSize: 10.5)),
                        ],
                      ),
                    ),
                    Text('${Fmt.kwh(a.dailyKwh)} kWh', style: AppTextStyles.figure(12)),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 18),
                      onSelected: (v) {
                        if (v == 'edit') {
                          showApplianceForm(context, meterId: meter.id, tariffPerKwh: meter.tariffPerKwh, initial: a);
                        } else {
                          ref.read(appliancesProvider.notifier).remove(meter.id, a.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('« ${a.name} » supprimé'),
                            action: SnackBarAction(
                              label: 'Annuler',
                              onPressed: () => ref.read(appliancesProvider.notifier).add(meter.id, a),
                            ),
                          ));
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
