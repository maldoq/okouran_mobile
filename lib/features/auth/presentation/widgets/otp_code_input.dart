import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Saisie d'un code à 6 chiffres affiché dans 6 cases.
///
/// Un seul champ texte invisible est posé sur les cases : le clavier,
/// le collage et le remplissage automatique du code SMS fonctionnent
/// comme sur un champ normal.
class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.hasError = false,
    this.errorCount = 0,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;
  final bool hasError;

  /// Chaque changement de valeur déclenche une secousse des cases.
  final int errorCount;
  final bool enabled;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput>
    with SingleTickerProviderStateMixin {
  final _focus = FocusNode();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _focus.addListener(_refresh);
    // Ouvre le clavier dès l'arrivée sur l'écran.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void didUpdateWidget(OtpCodeInput old) {
    super.didUpdateWidget(old);
    if (widget.errorCount != old.errorCount && widget.hasError) {
      _shake.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;
    final text = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        // Oscillation amortie de gauche à droite.
        final t = _shake.value;
        final dx = math.sin(t * math.pi * 6) * 10 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Stack(
        children: [
          // Les cases.
          Row(
            children: List.generate(widget.length, (i) {
              final filled = i < code.length;
              final isCurrent = _focus.hasFocus &&
                  (i == code.length ||
                      (code.length == widget.length && i == widget.length - 1));
              final borderColor = widget.hasError
                  ? AppColors.danger
                  : isCurrent
                      ? AppColors.secondary
                      : filled
                          ? AppColors.primary.withValues(alpha: .35)
                          : AppColors.border;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 56,
                  margin: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.hasError
                        ? AppColors.dangerBg.withValues(alpha: .5)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: borderColor, width: isCurrent ? 2 : 1.5),
                  ),
                  child: Text(
                    filled ? code[i] : '',
                    style: text.headlineSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              );
            }),
          ),
          // Champ invisible qui capte la saisie.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                showCursor: false,
                // Occupe toute la hauteur des cases : un toucher n'importe où ouvre le clavier.
                expands: true,
                maxLines: null,
                enableInteractiveSelection: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  filled: false,
                ),
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  if (value.length == widget.length) widget.onCompleted(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}