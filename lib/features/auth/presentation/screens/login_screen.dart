import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/okouran_logo.dart';
import '../../../../core/widgets/phone_field.dart';
import '../providers/auth_providers.dart';
import '../widgets/biometric_sheet.dart';
import '../widgets/demo_accounts_card.dart';

/// Écran 3 : Connexion.
///
/// Trois façons de se connecter (toutes simulées) :
///   1. numéro + mot de passe  → tableau de bord
///   2. « Code SMS »            → écran OTP (le numéro est transmis)
///   3. « Empreinte »           → feuille biométrique → tableau de bord
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Numéro pré-rempli comme sur la maquette (gain de temps en démo).
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(loginControllerProvider.notifier).signIn(
          phone: PhoneField.digitsOf(_phoneCtrl.text),
          password: _passwordCtrl.text,
        );
    if (ok && mounted) context.go(AppRoutes.dashboard);
  }

  /// Le code SMS n'a besoin que du numéro : on ne valide pas le mot de passe.
  void _loginWithSms() {
    final error = PhoneField.validate(_phoneCtrl.text);
    if (error != null) {
      _showMessage(error);
      return;
    }
    context.push(AppRoutes.otp, extra: PhoneField.digitsOf(_phoneCtrl.text));
  }

  Future<void> _loginWithBiometrics() async {
    final ok = await showBiometricSheet(context);
    if (ok && mounted) context.go(AppRoutes.dashboard);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final text = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 14, AppSpacing.xl, AppSpacing.xl),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête.
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: OkouranLogoTile(),
                    ),
                    const SizedBox(height: 16),
                    // Visuel d'accueil (style « GoBus » : image + carte blanche).
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(AppAssets.heroMeter,
                          height: 130, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 18),
                    Text('Bon retour.',
                        style: text.headlineMedium?.copyWith(fontSize: 25)),
                    const SizedBox(height: 7),
                    Text('Connectez-vous pour retrouver vos compteurs.',
                        style: text.bodySmall),
                    const SizedBox(height: AppSpacing.xl),

                    // Champs.
                    PhoneField(controller: _phoneCtrl),
                    const SizedBox(height: 13),
                    AppTextField(
                      label: 'Mot de passe',
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      obscureText: state.obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Saisissez votre mot de passe';
                        }
                        if (v.length < 4) return '4 caractères minimum';
                        return null;
                      },
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
                    ),

                    // Se souvenir / mot de passe oublié.
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppCheckbox(
                            value: state.rememberMe,
                            onChanged: controller.toggleRememberMe,
                            label: 'Se souvenir de moi',
                          ),
                          TextButton(
                            onPressed: () => _showMessage(
                                'Réinitialisation simulée : un SMS serait envoyé.'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              textStyle: text.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ],
                      ),
                    ),

                    // Erreur éventuelle (mot de passe « 0000 » pour la tester).
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

                    AppButton(
                      label: 'Se connecter',
                      variant: AppButtonVariant.dark,
                      loading: state.isLoading,
                      onPressed: _submit,
                    ),

                    // Séparateur « ou ».
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('ou', style: text.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),

                    // Autres méthodes.
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Code SMS',
                            icon: Icons.sms_outlined,
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.small,
                            onPressed: state.isLoading ? null : _loginWithSms,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'Empreinte',
                            icon: Icons.fingerprint_rounded,
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.small,
                            onPressed:
                                state.isLoading ? null : _loginWithBiometrics,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    const InfoNote(
                      icon: Icons.wifi_off_rounded,
                      title: 'Mode hors connexion.',
                      message:
                          'Sans réseau, vos derniers relevés, vos codes de recharge '
                          'et votre historique restent consultables. Seules les '
                          'opérations de paiement nécessitent une connexion.',
                    ),
                    const SizedBox(height: 14),

                    // Comptes de démonstration : remplit numéro et mot de passe.
                    DemoAccountsCard(
                      onPick: (a) {
                        _phoneCtrl.text = PhoneField.format(a.user.phone, withPrefix: false);
                        _passwordCtrl.text = a.password;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Lien inscription.
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Pas encore de compte ? ', style: text.bodySmall),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: Text(
                              'Créer un compte',
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