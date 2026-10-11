import 'package:flutter/material.dart';

import '../constants/communes.dart';
import '../theme/app_colors.dart';

/// Champ « Commune » (liste déroulante) : inscription et informations du compte.
/// S'intègre dans un `Form` : la validation exige une commune.
class CommuneField extends StatelessWidget {
  const CommuneField({
    super.key,
    required this.value,
    required this.onChanged,
    this.helper,
    this.required = true,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? helper;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMMUNE', style: text.labelSmall),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: communes.contains(value) ? value : null,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.textSecondary),
          hint: const Text('Choisir votre commune…'),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.place_outlined,
                size: 20, color: AppColors.textSecondary),
            helperText: helper,
            helperMaxLines: 2,
          ),
          items: [
            for (final c in communes) DropdownMenuItem(value: c, child: Text(c))
          ],
          onChanged: onChanged,
          validator: required
              ? (v) =>
                  (v == null || v.isEmpty) ? 'Choisissez votre commune' : null
              : null,
        ),
      ],
    );
  }
}
