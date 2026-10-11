import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/info_note.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../../meter/presentation/providers/meter_providers.dart';
import '../widgets/appliances_section.dart';

/// Écran « Mes appareils » : un bloc par compteur de l'utilisateur.
class AppliancesScreen extends ConsumerWidget {
  const AppliancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meters = ref.watch(liveMetersProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Mes appareils'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          const InfoNote(
            icon: Icons.bolt_rounded,
            tone: BadgeTone.brand,
            message: 'La prévision de consommation, la baisse du crédit heure par heure et les '
                'conseils sont calculés à partir de ces appareils. Touchez un appareil pour le modifier.',
          ),
          for (final m in meters) ...[
            const SizedBox(height: 14),
            AppliancesSection(meter: m),
          ],
        ],
      ),
    );
  }
}
