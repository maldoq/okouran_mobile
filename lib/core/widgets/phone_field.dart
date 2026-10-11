import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// Numéro ivoirien : indicatif +225 fixe et 10 chiffres groupés par 2
/// (ex. « 07 08 44 21 90 »). Réutilisé à la connexion et à l'inscription.
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.helper,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;

  /// Texte d'aide facultatif sous le champ.
  final String? helper;

  /// Chiffres seuls (sans espaces), pour l'envoi au futur backend.
  static String digitsOf(String formatted) =>
      formatted.replaceAll(RegExp(r'\D'), '');

  /// « 0708442190 » → « +225 07 08 44 21 90 » (affichage).
  static String format(String digits, {bool withPrefix = true}) {
    final pairs = <String>[];
    for (var i = 0; i < digits.length; i += 2) {
      pairs.add(digits.substring(i, i + 2 > digits.length ? digits.length : i + 2));
    }
    final body = pairs.join(' ');
    return withPrefix ? '+225 $body' : body;
  }

  static String? validate(String? value) {
    final digits = digitsOf(value ?? '');
    if (digits.isEmpty) return 'Saisissez votre numéro';
    if (digits.length != 10) return 'Le numéro doit avoir 10 chiffres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Numéro de téléphone',
      helper: helper,
      controller: controller,
      hint: '07 00 00 00 00',
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      monospaceDigits: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
        _PairGroupingFormatter(),
      ],
      validator: validate,
      leading: Container(
        width: 78,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Text(
          '+225',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 14,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
      ),
    );
  }
}

/// Insère un espace tous les 2 chiffres pendant la saisie.
class _PairGroupingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i.isEven) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}