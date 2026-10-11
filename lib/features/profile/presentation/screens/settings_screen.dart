import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/menu_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/segmented_tabs.dart';
import '../../../appliances/presentation/widgets/appliances_section.dart';
import '../../../meter/domain/meter.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../../domain/app_settings.dart';
import '../../domain/notification_settings.dart';
import '../providers/profile_providers.dart';

/// Écran 20 : Paramètres.
///
/// Seuils d'alerte (exprimés d'abord en jours d'autonomie), canaux de
/// notification (le SMS en premier plan), données, langue, sécurité.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// Unité d'affichage des seuils : 0 = jours, 1 = kWh, 2 = %.
  int _unit = 0;

  @override
  Widget build(BuildContext context) {
    final n = ref.watch(notificationSettingsProvider);
    final a = ref.watch(appSettingsProvider);
    final meter = ref.watch(selectedMeterProvider);
    final text = Theme.of(context).textTheme;

    void setN(NotificationSettings v) =>
        ref.read(notificationSettingsProvider.notifier).state = v;
    void setA(AppSettings v) =>
        ref.read(appSettingsProvider.notifier).state = v;

    Widget sw(bool value, ValueChanged<bool> onChanged) =>
        Switch(value: value, onChanged: onChanged);

    return Scaffold(
      appBar: const AppTopBar(title: 'Paramètres'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          // ---------------- Mes appareils (CRUD) ----------------
          const SectionHeader(title: 'Mes appareils'),
          for (final m in ref.watch(liveMetersProvider)) ...[
            AppliancesSection(meter: m),
            const SizedBox(height: 10),
          ],

          // ---------------- Jauge ----------------
          const SectionHeader(title: 'Jauge d\'autonomie'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Objectif qui vaut 100 %',
                      style: text.titleSmall?.copyWith(fontSize: 12.5)),
                  const SizedBox(height: 2),
                  Text(
                    'La jauge est pleine quand le crédit permet de tenir '
                    'ce nombre de jours, puis baisse avec l\'autonomie.',
                    style: text.bodySmall?.copyWith(fontSize: 10.5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final d in const [3, 5, 7, 10, 14])
                        ChoiceChip(
                          label: Text('$d jours'),
                          selected: a.autonomyTargetDays == d,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: a.autonomyTargetDays == d
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          onSelected: (_) =>
                              setA(a.copyWith(autonomyTargetDays: d)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Exemple, ${meter.name} : ${Fmt.duration(meter.autonomy)} '
                    '÷ ${a.autonomyTargetDays} jours = '
                    '${(meter.gaugeRatio(Duration(days: a.autonomyTargetDays)) * 100).round()} %.',
                    style: text.bodySmall?.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- Seuils ----------------
          const SectionHeader(title: 'Seuils d\'alerte'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedTabs(
                    labels: const ['En jours', 'En kWh', 'En %'],
                    selected: _unit,
                    onChanged: (i) => setState(() => _unit = i),
                  ),
                  const SizedBox(height: 6),
                  _ThresholdRow(
                    color: AppColors.success,
                    title: 'Alerte préventive',
                    value: _format(n.lowCreditThresholdHours, meter, a),
                    on: n.preventiveOn,
                    onChanged: (v) => setN(n.copyWith(preventiveOn: v)),
                  ),
                  const Divider(),
                  _ThresholdRow(
                    color: AppColors.warning,
                    title: 'Alerte forte',
                    value: _format(n.strongThresholdHours, meter, a),
                    on: n.strongOn,
                    onChanged: (v) => setN(n.copyWith(strongOn: v)),
                  ),
                  const Divider(),
                  _ThresholdRow(
                    color: AppColors.danger,
                    title: 'Alerte critique',
                    value: _format(n.criticalThresholdHours, meter, a),
                    on: n.criticalOn,
                    onChanged: (v) => setN(n.copyWith(criticalOn: v)),
                  ),
                  const SizedBox(height: 8),
                  InfoNote(
                    icon: Icons.lightbulb_outline_rounded,
                    tone: _unit == 2 ? BadgeTone.warning : BadgeTone.info,
                    message: _unit == 2
                        ? 'Le pourcentage est celui de la jauge : heures du '
                            'seuil ÷ objectif de ${a.autonomyTargetDays} jours. '
                            'Il change si vous changez l\'objectif.'
                        : 'Un seuil en jours reste juste quand vos usages '
                            'changent. Conversion pour ${meter.name} : '
                            '${Fmt.kwh(meter.kwhPerDay)} kWh par jour.',
                  ),
                ],
              ),
            ),
          ),

          // ---------------- Canaux ----------------
          const SectionHeader(title: 'Canaux de notification'),
          MenuCard(children: [
            MenuTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notification sur le téléphone',
              subtitle: 'Toutes les alertes',
              trailing: sw(n.push, (v) => setN(n.copyWith(push: v))),
            ),
            MenuTile(
              icon: Icons.sms_outlined,
              title: 'SMS',
              subtitle: 'Alertes critiques · fonctionne sans données',
              trailing: sw(n.sms, (v) => setN(n.copyWith(sms: v))),
            ),
            MenuTile(
              icon: Icons.chat_outlined,
              title: 'WhatsApp',
              subtitle: 'Résumés hebdomadaires',
              trailing: sw(n.whatsapp, (v) => setN(n.copyWith(whatsapp: v))),
            ),
            MenuTile(
              icon: Icons.call_outlined,
              title: 'Appel vocal',
              subtitle: 'Alerte critique, si le SMS reste non lu 2 h',
              trailing:
                  sw(n.voiceCall, (v) => setN(n.copyWith(voiceCall: v))),
            ),
            MenuTile(
              icon: Icons.bedtime_outlined,
              title: 'Heures silencieuses',
              subtitle: '22 h – 6 h · sauf alerte critique',
              trailing:
                  sw(n.quietHours, (v) => setN(n.copyWith(quietHours: v))),
            ),
          ]),

          // ---------------- Données ----------------
          const SectionHeader(title: 'Données et réseau'),
          MenuCard(children: [
            MenuTile(
              icon: Icons.data_saver_on_outlined,
              title: 'Mode économie de données',
              subtitle: 'Graphiques allégés, synchronisation espacée',
              trailing: sw(a.dataSaver, (v) => setA(a.copyWith(dataSaver: v))),
            ),
            MenuTile(
              icon: Icons.cloud_off_outlined,
              title: 'Consultation hors connexion',
              subtitle: 'Derniers relevés, codes et historique conservés',
              trailing: sw(a.offline, (v) => setA(a.copyWith(offline: v))),
            ),
            MenuTile(
              icon: Icons.sync_rounded,
              title: 'Synchronisation automatique',
              subtitle: 'Toutes les 30 min en Wi-Fi, 2 h en données mobiles',
              trailing: sw(a.autoSync, (v) => setA(a.copyWith(autoSync: v))),
            ),
          ]),

          // ---------------- Langue et accessibilité ----------------
          const SectionHeader(title: 'Langue et accessibilité'),
          MenuCard(children: [
            MenuTile(
              icon: Icons.translate_rounded,
              title: 'Langue',
              subtitle: 'Français · English et Dioula à venir',
              trailing: _tag(text, 'Français'),
              onTap: () => _snack('Seul le français est disponible pour l\'instant.'),
            ),
            MenuTile(
              icon: Icons.format_size_rounded,
              title: 'Grande taille de texte',
              subtitle: 'Texte agrandi de 15 % sur tous les écrans',
              trailing: sw(a.largeText, (v) => setA(a.copyWith(largeText: v))),
            ),
            MenuTile(
              icon: Icons.contrast_rounded,
              title: 'Contraste renforcé',
              subtitle: 'États doublés par une icône, jamais par la couleur seule',
              trailing: sw(
                  a.highContrast, (v) => setA(a.copyWith(highContrast: v))),
            ),
            MenuTile(
              icon: Icons.dark_mode_outlined,
              title: 'Mode sombre',
              subtitle: 'Préparé, pas encore disponible',
              trailing: _tag(text, 'Clair'),
            ),
          ]),

          // ---------------- Sécurité ----------------
          const SectionHeader(title: 'Sécurité'),
          MenuCard(children: [
            MenuTile(
              icon: Icons.lock_outline_rounded,
              title: 'Code PIN à l\'ouverture',
              subtitle: 'Requis avant tout paiement',
              trailing: sw(a.pinLock, (v) => setA(a.copyWith(pinLock: v))),
            ),
            MenuTile(
              icon: Icons.fingerprint_rounded,
              title: 'Empreinte digitale',
              subtitle: 'Activée sur cet appareil',
              trailing:
                  sw(a.biometrics, (v) => setA(a.copyWith(biometrics: v))),
            ),
          ]),
          const SizedBox(height: 14),
          Text(
            'Réglages simulés : ils sont gardés en mémoire jusqu\'à la '
            'fermeture de l\'app. Seule la taille du texte agit déjà sur '
            'l\'affichage, et l\'option SMS sur l\'aperçu d\'alerte critique.',
            style: text.bodySmall?.copyWith(fontSize: 10.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Convertit un seuil en heures dans l'unité choisie.
  ///   jours : heures ÷ 24 ;
  ///   kWh   : heures × rythme (kWh par heure) ;
  ///   %     : heures ÷ objectif d'autonomie (même calcul que la jauge).
  String _format(int hours, Meter meter, AppSettings a) {
    final kwh = hours * meter.kwhPerDay / 24;
    final pct = hours / (a.autonomyTargetDays * 24) * 100;
    return switch (_unit) {
      0 => hours % 24 == 0
          ? '${hours ~/ 24} jour${hours >= 48 ? 's' : ''} d\'autonomie'
          : '$hours heures d\'autonomie',
      1 => '${Fmt.kwh(kwh)} kWh restants',
      _ => '${pct.round()} % de la jauge',
    };
  }

  Widget _tag(TextTheme text, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4F7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: text.bodySmall
                ?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w700)),
      );

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(message), behavior: SnackBarBehavior.floating));
  }
}

/// Ligne de seuil : pastille de couleur, titre, valeur, interrupteur.
class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({
    required this.color,
    required this.title,
    required this.value,
    required this.on,
    required this.onChanged,
  });

  final Color color;
  final String title;
  final String value;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall?.copyWith(fontSize: 12.5)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: text.bodySmall?.copyWith(
                      fontSize: 10.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: onChanged,
            activeTrackColor: color,
          ),
        ],
      ),
    );
  }
}