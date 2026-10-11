import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

/// Ouvre la feuille de connexion par empreinte (simulée).
/// Renvoie vrai si la connexion a réussi.
Future<bool> showBiometricSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _BiometricSheet(),
  );
  return result ?? false;
}

enum _BioStep { waiting, scanning, success }

class _BiometricSheet extends ConsumerStatefulWidget {
  const _BiometricSheet();

  @override
  ConsumerState<_BiometricSheet> createState() => _BiometricSheetState();
}

class _BiometricSheetState extends ConsumerState<_BiometricSheet>
    with SingleTickerProviderStateMixin {
  _BioStep _step = _BioStep.waiting;

  // Pulsation douce de l'empreinte.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// Simule la lecture : l'utilisateur touche l'icône.
  Future<void> _scan() async {
    if (_step != _BioStep.waiting) return;
    setState(() => _step = _BioStep.scanning);
    final user = await ref.read(authRepositoryProvider).signInWithBiometrics();
    if (!mounted) return; // feuille fermée pendant la lecture
    ref.read(currentUserProvider.notifier).state = user;
    setState(() => _step = _BioStep.success);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final success = _step == _BioStep.success;
    final color = success ? AppColors.success : AppColors.secondary;

    final (title, subtitle) = switch (_step) {
      _BioStep.waiting => ('Connexion par empreinte',
          'Touchez le capteur pour vous connecter.'),
      _BioStep.scanning => ('Lecture en cours…', 'Gardez le doigt posé.'),
      _BioStep.success => ('Empreinte reconnue', 'Connexion…'),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: text.titleLarge),
            const SizedBox(height: 6),
            Text(subtitle, style: text.bodyMedium),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: _scan,
              child: ScaleTransition(
                scale: Tween<double>(begin: .94, end: 1.06).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: .12),
                    border: Border.all(color: color.withValues(alpha: .35), width: 2),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      success ? Icons.check_rounded : Icons.fingerprint_rounded,
                      key: ValueKey(success),
                      size: 48,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: _step == _BioStep.waiting
                  ? () => Navigator.of(context).pop(false)
                  : null,
              child: const Text('Annuler'),
            ),
            Text('Simulation : aucune donnée biométrique n\'est lue.',
                style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}