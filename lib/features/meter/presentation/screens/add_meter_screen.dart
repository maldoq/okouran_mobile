import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/step_progress.dart';
import '../../data/mock_meter_repository.dart';
import '../../domain/meter.dart';
import '../providers/add_meter_provider.dart';
import '../widgets/meter_capabilities_card.dart';
import '../widgets/meter_style.dart';
import '../../../appliances/presentation/providers/appliances_provider.dart';

/// Écran 13 : Ajout d'un compteur.
///
/// Deux entrées :
///   - fin de l'inscription (étape 3 / 3, barre d'étapes) ;
///   - depuis l'app (barre de titre avec retour).
///
/// Le compteur est identifié avant l'ajout, et l'écran annonce ce qu'il
/// sait faire (recharge à distance ou code à saisir à la main).
class AddMeterScreen extends ConsumerStatefulWidget {
  const AddMeterScreen({super.key, this.fromSignup = false});

  final bool fromSignup;

  @override
  ConsumerState<AddMeterScreen> createState() => _AddMeterScreenState();
}

class _AddMeterScreenState extends ConsumerState<AddMeterScreen> {
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {})); // active / désactive le bouton
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _digits => _numberCtrl.text.replaceAll(' ', '');

  void _onNumberChanged(String _) {
    final controller = ref.read(addMeterControllerProvider.notifier);
    controller.reset();
    // Identification automatique dès le 12e chiffre.
    if (_digits.length == 12) {
      FocusScope.of(context).unfocus();
      controller.lookup(_digits);
    }
  }

  Future<void> _scan() async {
    final controller = ref.read(addMeterControllerProvider.notifier);
    final digits = await controller.scan();
    if (!mounted) return;
    _numberCtrl.text = MockMeterRepository.groupBy4(digits);
    controller.lookup(digits);
  }

  void _add() {
    final kind = ref.read(addMeterControllerProvider).kind;
    final id = ref.read(addMeterControllerProvider.notifier).add(_nameCtrl.text.trim());
    // Appareils proposés par défaut selon le type de lieu (modifiables dans Paramètres).
    ref.read(appliancesProvider.notifier).ensureDefaults(id, kind);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('« ${_nameCtrl.text.trim()} » ajouté'),
      behavior: SnackBarBehavior.floating,
    ));
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMeterControllerProvider);
    final controller = ref.read(addMeterControllerProvider.notifier);
    final text = Theme.of(context).textTheme;
    final canAdd = state.result != null && _nameCtrl.text.trim().isNotEmpty;

    final content = ListView(
      padding: EdgeInsets.fromLTRB(18, widget.fromSignup ? 6 : 16, 18, 28),
      children: [
        if (widget.fromSignup) ...[
          StepProgressHeader(
            current: 3,
            total: 3,
            onBack: () => context.go(AppRoutes.login),
          ),
          const SizedBox(height: 16),
          Text('Ajoutez votre compteur.',
              style: text.headlineMedium?.copyWith(fontSize: 24)),
          const SizedBox(height: 7),
          Text('Son numéro figure sur votre facture et sur le compteur.',
              style: text.bodySmall),
          const SizedBox(height: 16),
        ],

        // ---- Scan du QR code ----
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 132,
                width: double.infinity,
                decoration:
                    const BoxDecoration(gradient: AppColors.brandGradient),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .4),
                          width: 2,
                        ),
                      ),
                      child: state.isScanning
                          ? const Center(
                              child: SizedBox.square(
                                dimension: 28,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: AppColors.accent),
                              ),
                            )
                          : Icon(Icons.qr_code_2_rounded,
                              size: 40,
                              color: Colors.white.withValues(alpha: .85)),
                    ),
                    Positioned(
                      bottom: 11,
                      child: Text(
                        state.isScanning
                            ? 'LECTURE EN COURS…'
                            : 'SCANNER LE QR CODE DE LA FACTURE',
                        style: text.labelSmall?.copyWith(
                          fontSize: 9.5,
                          color: Colors.white.withValues(alpha: .65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: AppButton(
                  label: 'Ouvrir l\'appareil photo',
                  icon: Icons.qr_code_scanner_rounded,
                  variant: AppButtonVariant.dark,
                  size: AppButtonSize.small,
                  loading: state.isScanning,
                  onPressed: _scan,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('ou saisir à la main', style: text.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),

        // ---- Numéro ----
        AppTextField(
          label: 'Numéro de compteur (12 chiffres)',
          controller: _numberCtrl,
          hint: '0451 0000 0000',
          keyboardType: TextInputType.number,
          monospaceDigits: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
            _GroupBy4Formatter(),
          ],
          suffix: state.isLookingUp
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : state.result != null
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.success)
                  : null,
          onChanged: _onNumberChanged,
        ),
        const SizedBox(height: 13),

        // ---- Nom du lieu + type ----
        AppTextField(
          label: 'Nom du lieu',
          controller: _nameCtrl,
          hint: 'Ex. Maison Riviera',
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in MeterKind.values)
              _KindChip(
                kind: kind,
                selected: state.kind == kind,
                onTap: () => controller.setKind(kind),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // ---- Résultat de l'identification ----
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.error != null)
                InfoNote(
                  icon: Icons.error_outline_rounded,
                  tone: BadgeTone.danger,
                  message: state.error!,
                ),
              if (state.result != null) ...[
                InfoNote(
                  icon: Icons.check_rounded,
                  tone: BadgeTone.success,
                  title: 'Compteur reconnu.',
                  message: 'Abonné ${state.result!.holder} · '
                      '${state.result!.location} · ${state.result!.tariffLabel}.',
                ),
                const SizedBox(height: 12),
                MeterCapabilitiesCard(lookup: state.result!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        AppButton(
          label: 'Ajouter ce compteur',
          variant: AppButtonVariant.dark,
          onPressed: canAdd ? _add : null,
        ),
        if (widget.fromSignup)
          TextButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            child: const Text('Plus tard'),
          ),
        const SizedBox(height: 10),
        const InfoNote(
          icon: Icons.science_outlined,
          tone: BadgeTone.neutral,
          title: 'Démo.',
          message: 'Le numéro doit commencer par 04. Dernier chiffre pair : '
              'compteur communicant ; impair : compteur à touches. '
              'Le scan renvoie toujours 0451 4472 3306.',
        ),
      ],
    );

    return Scaffold(
      appBar: widget.fromSignup
          ? null
          : const AppTopBar(title: 'Ajouter un compteur'),
      body: widget.fromSignup
          ? AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: SafeArea(child: content),
            )
          : content,
    );
  }
}

/// Puce de choix du type de lieu (maison, bureau, famille).
class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final MeterKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = meterKindLabel(kind);
    return ChoiceChip(
      avatar: Icon(meterKindIcon(kind),
          size: 16, color: selected ? Colors.white : AppColors.primary),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}

/// Insère un espace tous les 4 chiffres pendant la saisie.
class _GroupBy4Formatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = MockMeterRepository.groupBy4(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}