import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../../core/widgets/step_progress.dart';
import '../../data/mock_auth_repository.dart';
import '../providers/otp_provider.dart';
import '../providers/signup_provider.dart';
import '../widgets/otp_code_input.dart';

/// Écran 5 : Vérification du code SMS (OTP).
///
/// Deux cas, détectés automatiquement :
///   - inscription en cours  → étape 2 / 3, puis ajout du compteur ;
///   - connexion par SMS     → pas de barre d'étapes, puis tableau de bord.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  /// Numéro (10 chiffres) auquel le code a été « envoyé ».
  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeCtrl = TextEditingController();

  /// Lu une seule fois : l'utilisateur en attente est effacé après validation.
  late final bool _isSignup = ref.read(pendingUserProvider) != null;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.login);

  Future<void> _verify([String? code]) async {
    final value = code ?? _codeCtrl.text;
    if (value.length < 6) return;
    final ok = await ref
        .read(otpControllerProvider.notifier)
        .verify(phone: widget.phone, code: value);
    if (!mounted) return;
    if (ok) {
      context.go(
          _isSignup ? AppRoutes.addMeterAfterSignup : AppRoutes.dashboard);
    } else {
      _codeCtrl.clear(); // on vide pour une nouvelle saisie
    }
  }

  Future<void> _resend() async {
    await ref.read(otpControllerProvider.notifier).resend(widget.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Nouveau code envoyé au ${PhoneField.format(widget.phone)}'),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpControllerProvider);
    final text = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 6, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête.
                if (_isSignup)
                  StepProgressHeader(current: 2, total: 3, onBack: _back)
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(onPressed: _back),
                  ),
                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: IconBadge(
                    icon: Icons.sms_outlined,
                    tone: BadgeTone.info,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 18),
                Text('Vérifiez votre numéro.',
                    style: text.headlineMedium?.copyWith(fontSize: 24)),
                const SizedBox(height: 7),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(
                        text: 'Saisissez le code à 6 chiffres envoyé par SMS au '),
                    TextSpan(
                      text: PhoneField.format(widget.phone),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '. '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: _back,
                        child: Text(
                          'Modifier',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ]),
                  style: text.bodySmall?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 26),

                // Saisie du code (validation automatique au 6e chiffre).
                OtpCodeInput(
                  controller: _codeCtrl,
                  hasError: state.error != null,
                  errorCount: state.errorCount,
                  enabled: !state.isLoading,
                  onChanged: (_) =>
                      ref.read(otpControllerProvider.notifier).clearError(),
                  onCompleted: _verify,
                ),

                // Message d'erreur.
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: state.error == null
                      ? const SizedBox(height: 10)
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            state.error!,
                            style: text.bodySmall
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ),
                ),
                const SizedBox(height: 10),

                // Renvoi du code.
                Center(
                  child: state.canResend
                      ? TextButton.icon(
                          onPressed: _resend,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Renvoyer le code'),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            state.isResending
                                ? 'Envoi en cours…'
                                : 'Renvoyer le code dans 0:${state.secondsLeft.toString().padLeft(2, '0')}',
                            style: text.bodySmall?.copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 18),

                AppButton(
                  label: 'Vérifier',
                  variant: AppButtonVariant.dark,
                  loading: state.isLoading,
                  onPressed: () => _verify(),
                ),
                const SizedBox(height: 18),

                // Aide pour la démo (aucun SMS n'est réellement envoyé).
                const InfoNote(
                  icon: Icons.info_outline_rounded,
                  title: 'Démo.',
                  message: 'Aucun SMS n\'est envoyé. Utilisez le code '
                      '${MockAuthRepository.demoOtp} ; tout autre code '
                      'affiche une erreur.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}