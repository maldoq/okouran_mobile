import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/commune_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../../auth/data/mock_auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Feuille « Informations personnelles » : prénoms, nom, e-mail.
/// Le numéro est affiché mais non modifiable (il identifie le compte).
Future<void> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // monte au-dessus du clavier
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _user = ref.read(currentUserProvider) ?? mockUser;
  late final _firstCtrl = TextEditingController(text: _user.firstName);
  late final _lastCtrl = TextEditingController(text: _user.lastName);
  late final _emailCtrl = TextEditingController(text: _user.email ?? '');
  late String? _commune = _user.commune;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    ref.read(currentUserProvider.notifier).state = _user.copyWith(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      commune: _commune,
      email: email.isEmpty ? null : email,
      clearEmail: email.isEmpty,
    );
    Navigator.pop(context);
  }

  static String? _required(String? v) =>
      (v ?? '').trim().isEmpty ? 'Champ obligatoire' : null;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Informations personnelles', style: text.titleLarge),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Prénoms',
              controller: _firstCtrl,
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Nom',
              controller: _lastCtrl,
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            CommuneField(
              value: _commune,
              onChanged: (v) => setState(() => _commune = v),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'E-mail',
              labelHint: 'facultatif',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return null;
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                    ? null
                    : 'Adresse e-mail invalide';
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Numéro : ${PhoneField.format(_user.phone)} (identifiant du '
              'compte, non modifiable ici)',
              style: text.bodySmall,
            ),
            const SizedBox(height: 18),
            AppButton(
              label: 'Enregistrer',
              variant: AppButtonVariant.dark,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}