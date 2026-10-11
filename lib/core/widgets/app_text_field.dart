import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Champ de saisie de la maquette : libellé en petites capitales au-dessus,
/// champ arrondi en dessous, message d'erreur sous le champ.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.labelHint,
    this.helper,
    this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.leading,
    this.validator,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofillHints,
    this.monospaceDigits = false,
    this.below,
  });

  final String label;

  /// Précision affichée après le libellé, en minuscules (ex. « facultatif »).
  final String? labelHint;

  /// Texte d'aide sous le champ (ex. à quoi sert le numéro).
  final String? helper;

  /// Contenu libre sous le champ (ex. jauge de solidité du mot de passe).
  final Widget? below;

  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  /// Widget à droite dans le champ (ex. œil du mot de passe).
  final Widget? suffix;

  /// Widget séparé à gauche du champ (ex. indicatif « +225 »).
  final Widget? leading;

  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  /// Chiffres à chasse fixe (numéros, codes) pour un alignement propre.
  final bool monospaceDigits;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autofillHints: autofillHints,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: text.bodyLarge?.copyWith(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontFeatures:
            monospaceDigits ? const [FontFeature.tabularFigures()] : null,
      ),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(text: label.toUpperCase()),
            if (labelHint != null)
              TextSpan(
                text: '  ($labelHint)',
                style: const TextStyle(
                    letterSpacing: 0, fontWeight: FontWeight.w500),
              ),
          ]),
          style: text.labelSmall?.copyWith(
            letterSpacing: 1.3,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 7),
        if (leading == null)
          field
        else
          Row(
            // Aligne en haut pour que le message d'erreur ne décale pas l'indicatif.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading!,
              const SizedBox(width: 8),
              Expanded(child: field),
            ],
          ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: text.bodySmall?.copyWith(fontSize: 10.5)),
        ],
        if (below != null) ...[
          const SizedBox(height: 7),
          below!,
        ],
      ],
    );
  }
}