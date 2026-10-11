import 'package:flutter_riverpod/legacy.dart';

/// Page d'onboarding affichée (0, 1 ou 2).
final onboardingIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Vrai une fois l'onboarding terminé ou passé.
/// En mémoire seulement pour la maquette ; à persister plus tard
/// (shared_preferences) pour sauter l'onboarding au prochain lancement.
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);