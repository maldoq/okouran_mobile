import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/appliance.dart';
import '../providers/appliances_provider.dart';

/// Ouvre le formulaire d'ajout (initial == null) ou de modification d'un appareil.
Future<void> showApplianceForm(
  BuildContext context, {
  required String meterId,
  required double tariffPerKwh,
  Appliance? initial,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => ApplianceFormSheet(
        meterId: meterId, tariffPerKwh: tariffPerKwh, initial: initial),
  );
}

/// Formulaire appareil : type, nom, puissance, quantité, heures/jour, plage
/// d'utilisation. Aperçu en direct kWh/jour et FCFA/jour. Validation des champs.
class ApplianceFormSheet extends ConsumerStatefulWidget {
  const ApplianceFormSheet(
      {super.key,
      required this.meterId,
      required this.tariffPerKwh,
      this.initial});

  final String meterId;
  final double tariffPerKwh;
  final Appliance? initial;

  @override
  ConsumerState<ApplianceFormSheet> createState() => _ApplianceFormSheetState();
}

class _ApplianceFormSheetState extends ConsumerState<ApplianceFormSheet> {
  final _form = GlobalKey<FormState>();
  late ApplianceType _type = widget.initial?.type ?? ApplianceType.fan;
  late UsageWindow _usage = widget.initial?.usage ?? _type.defaultUsage;
  late final _name =
      TextEditingController(text: widget.initial?.name ?? _type.label);
  late final _watts = TextEditingController(
      text: '${widget.initial?.watts ?? _type.defaultWatts}');
  late final _qty =
      TextEditingController(text: '${widget.initial?.quantity ?? 1}');
  late final _hours = TextEditingController(
      text: _fmtHours(widget.initial?.hoursPerDay ?? _type.defaultHours));

  bool get _isEdit => widget.initial != null;

  static String _fmtHours(double h) => h == h.roundToDouble()
      ? h.toStringAsFixed(0)
      : h.toString().replaceAll('.', ',');

  static double? _num(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _name.dispose();
    _watts.dispose();
    _qty.dispose();
    _hours.dispose();
    super.dispose();
  }

  void _onType(ApplianceType t) {
    setState(() {
      // Pré-remplit avec les valeurs typiques si l'utilisateur ne les a pas personnalisées.
      if (_name.text.trim().isEmpty || _name.text == _type.label) {
        _name.text = t.label;
      }
      _watts.text = '${t.defaultWatts}';
      _hours.text = _fmtHours(t.defaultHours);
      _usage = t.defaultUsage;
      _type = t;
    });
  }

  double get _previewKwh {
    final w = _num(_watts.text) ?? 0;
    final q = _num(_qty.text) ?? 0;
    final h = _num(_hours.text) ?? 0;
    return w * q * h / 1000;
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final notifier = ref.read(appliancesProvider.notifier);
    final a = Appliance(
      id: widget.initial?.id ?? notifier.newId(),
      type: _type,
      name: _name.text.trim(),
      watts: _num(_watts.text)!.round(),
      quantity: _num(_qty.text)!.round(),
      hoursPerDay: _num(_hours.text)!,
      usage: _usage,
    );
    if (_isEdit) {
      notifier.replace(widget.meterId, a);
    } else {
      notifier.add(widget.meterId, a);
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isEdit
          ? 'Appareil modifié'
          : 'Appareil ajouté · prévision recalculée'),
    ));
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer cet appareil ?'),
        content: Text(
            '« ${widget.initial!.name} » ne sera plus pris en compte dans la prévision.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref
        .read(appliancesProvider.notifier)
        .remove(widget.meterId, widget.initial!.id);
    Navigator.of(context).pop();
  }

  String? _required(String? v,
      {double min = 0.01, double max = 100000, String unit = ''}) {
    final n = _num(v ?? '');
    if (n == null) return 'Valeur requise';
    if (n < min || n > max) {
      return 'Entre ${_fmtHours(min)} et ${_fmtHours(max)}$unit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final kwh = _previewKwh;
    final digits = [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
    final decimals = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _form,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text(_isEdit ? 'Modifier l\'appareil' : 'Ajouter un appareil',
                  style: text.titleLarge?.copyWith(fontFamily: AppFonts.brand)),
              const SizedBox(height: 16),
              DropdownButtonFormField<ApplianceType>(
                initialValue: _type,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Type d\'appareil'),
                items: [
                  for (final t in ApplianceType.values)
                    DropdownMenuItem(
                        value: t, child: Text('${t.emoji}  ${t.label}')),
                ],
                onChanged: (t) {
                  if (t != null) _onType(t);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Nom (ex. « Clim chambre »)'),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Donnez un nom à l\'appareil'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _watts,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: const InputDecoration(
                          labelText: 'Puissance', suffixText: 'W'),
                      validator: (v) =>
                          _required(v, min: 1, max: 20000, unit: ' W'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _qty,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: const InputDecoration(labelText: 'Quantité'),
                      validator: (v) => _required(v, min: 1, max: 50),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _hours,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: decimals,
                      decoration: const InputDecoration(
                          labelText: 'Heures/j', suffixText: 'h'),
                      validator: (v) =>
                          _required(v, min: 0.1, max: 24, unit: ' h'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UsageWindow>(
                initialValue: _usage,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Moment d\'utilisation'),
                items: [
                  for (final u in UsageWindow.values)
                    DropdownMenuItem(value: u, child: Text(u.label))
                ],
                onChanged: (u) => setState(() => _usage = u ?? _usage),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.brandBg,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimation', style: text.bodySmall),
                    Text(
                      '${Fmt.kwh(kwh)} kWh/j · ${Fmt.fcfa(kwh * widget.tariffPerKwh)}/j',
                      style:
                          AppTextStyles.figure(13, color: AppColors.orangeDeep),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                  onPressed: _save,
                  child: Text(_isEdit ? 'Enregistrer' : 'Ajouter l\'appareil')),
              if (_isEdit) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.danger),
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Supprimer l\'appareil'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
