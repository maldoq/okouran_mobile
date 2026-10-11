import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/commune_field.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../../core/widgets/step_progress.dart';
import '../providers/signup_provider.dart';
import '../widgets/password_strength_meter.dart';

/// Écran 4 : Inscription, étape 1 sur 3.
///
/// Parcours : 1. compte (cet écran) → 2. code SMS (OTP) → 3. ajout du compteur.
/// Le numéro sert d'identifiant ; l'e-mail est facultatif.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _commune;
  final _passwordCtrl = TextEditingController();

  /// Solidité recalculée à chaque frappe dans le mot de passe.
  PasswordStrength _strength = PasswordStrength.empty;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() {
      final s = PasswordStrength.of(_passwordCtrl.text);
      if (s != _strength) setState(() => _strength = s);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.login);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final phone = PhoneField.digitsOf(_phoneCtrl.text);
    final email = _emailCtrl.text.trim();
    final ok = await ref.read(signupControllerProvider.notifier).register(
          fullName: _nameCtrl.text,
          phone: phone,
          commune: _commune!,
          email: email.isEmpty ? null : email,
          password: _passwordCtrl.text,
        );
    if (ok && mounted) context.push(AppRoutes.otp, extra: phone);
  }

  // ---- Règles de validation ----

  static String? _validateName(String? v) {
    final words = (v ?? '').trim().split(RegExp(r'\s+'));
    if ((v ?? '').trim().isEmpty) return 'Saisissez votre nom et vos prénoms';
    if (words.length < 2) return 'Indiquez au moins un nom et un prénom';
    return null;
  }

  static String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return null; // facultatif
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : 'Adresse e-mail invalide';
  }

  static String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Choisissez un mot de passe';
    if (value.length < 8) return '8 caractères minimum';
    if (PasswordStrength.of(value).index < PasswordStrength.medium.index) {
      return 'Ajoutez un chiffre ou une majuscule';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final controller = ref.read(signupControllerProvider.notifier);
    final text = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 6, AppSpacing.xl, AppSpacing.xl),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StepProgressHeader(current: 1, total: 3, onBack: _back),
                    const SizedBox(height: AppSpacing.lg),

                    Text('Créons votre compte.',
                        style: text.headlineMedium?.copyWith(fontSize: 24)),
                    const SizedBox(height: 7),
                    Text(
                      'Trente secondes. Vous ajouterez vos compteurs juste après.',
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Nom & prénoms',
                      controller: _nameCtrl,
                      hint: 'KOUASSI Aya Marie',
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: _validateName,
                    ),
                    const SizedBox(height: 13),

                    PhoneField(
                      controller: _phoneCtrl,
                      helper: 'C\'est ce numéro qui recevra vos alertes, '
                          'par notification et par SMS.',
                    ),
                    const SizedBox(height: 13),
                    CommuneField(
                      value: _commune,
                      helper: 'Sert à adapter les conseils et les alertes à votre zone.',
                      onChanged: (v) => setState(() => _commune = v),
                    ),
                    const SizedBox(height: 13),

                    AppTextField(
                      label: 'E-mail',
                      labelHint: 'facultatif',
                      controller: _emailCtrl,
                      hint: 'pour recevoir vos reçus',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 13),

                    AppTextField(
                      label: 'Mot de passe',
                      controller: _passwordCtrl,
                      hint: '8 caractères minimum',
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: _validatePassword,
                      suffix: IconButton(
                        tooltip: state.obscurePassword
                            ? 'Afficher le mot de passe'
                            : 'Masquer le mot de passe',
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(
                          state.obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      below: PasswordStrengthMeter(strength: _strength),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppCheckbox(
                      value: state.acceptedTerms,
                      onChanged: controller.toggleTerms,
                      label: 'J\'accepte les conditions d\'utilisation et la '
                          'politique de confidentialité. Mes relevés de '
                          'consommation ne sont pas revendus à des tiers.',
                    ),
                    const SizedBox(height: 14),

                    // Erreur éventuelle (numéro 01 01 01 01 01 pour la tester).
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: state.error == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InfoNote(
                                icon: Icons.error_outline_rounded,
                                tone: BadgeTone.danger,
                                message: state.error!,
                              ),
                            ),
                    ),

                    // Désactivé tant que les conditions ne sont pas acceptées.
                    AppButton(
                      label: 'Continuer',
                      variant: AppButtonVariant.dark,
                      loading: state.isLoading,
                      onPressed: state.acceptedTerms ? _submit : null,
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Déjà un compte ? ', style: text.bodySmall),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: Text(
                              'Se connecter',
                              style: text.bodySmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}