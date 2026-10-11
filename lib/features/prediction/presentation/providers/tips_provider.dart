import 'package:flutter_riverpod/legacy.dart';

/// Conseils que l'utilisateur a décidé d'appliquer (identifiants).
final appliedTipsProvider =
    StateProvider.autoDispose<Set<String>>((ref) => <String>{});