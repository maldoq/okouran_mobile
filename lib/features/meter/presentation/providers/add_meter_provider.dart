import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_meter_repository.dart';
import '../../domain/meter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/meter_lookup.dart';
import 'meter_providers.dart';

final meterRepositoryProvider =
    Provider<MockMeterRepository>((ref) => const MockMeterRepository());

/// État de l'écran d'ajout.
class AddMeterState {
  const AddMeterState({
    this.isScanning = false,
    this.isLookingUp = false,
    this.result,
    this.error,
    this.kind = MeterKind.home,
  });

  final bool isScanning;
  final bool isLookingUp;

  /// Compteur reconnu (null tant que le numéro n'est pas identifié).
  final MeterLookup? result;
  final String? error;
  final MeterKind kind;

  AddMeterState copyWith({
    bool? isScanning,
    bool? isLookingUp,
    MeterLookup? result,
    String? error,
    MeterKind? kind,
    bool clearResult = false,
    bool clearError = false,
  }) =>
      AddMeterState(
        isScanning: isScanning ?? this.isScanning,
        isLookingUp: isLookingUp ?? this.isLookingUp,
        result: clearResult ? null : (result ?? this.result),
        error: clearError ? null : (error ?? this.error),
        kind: kind ?? this.kind,
      );
}

class AddMeterController extends Notifier<AddMeterState> {
  @override
  AddMeterState build() => const AddMeterState();

  MockMeterRepository get _repo => ref.read(meterRepositoryProvider);

  void setKind(MeterKind kind) => state = state.copyWith(kind: kind);

  /// Le numéro a changé : on oublie le résultat précédent.
  void reset() =>
      state = state.copyWith(clearResult: true, clearError: true);

  /// Simule le scan du QR code. Renvoie le numéro lu.
  Future<String> scan() async {
    state = state.copyWith(isScanning: true, clearError: true);
    final digits = await _repo.scanQrCode();
    state = state.copyWith(isScanning: false);
    return digits;
  }

  /// Identifie le compteur (12 chiffres sans espaces).
  Future<void> lookup(String digits) async {
    final already = ref
        .read(metersProvider)
        .any((m) => m.number.replaceAll(' ', '') == digits);
    if (already) {
      state = state.copyWith(
          clearResult: true, error: 'Ce compteur est déjà suivi.');
      return;
    }
    state = state.copyWith(
        isLookingUp: true, clearResult: true, clearError: true);
    try {
      final r = await _repo.lookup(digits);
      state = state.copyWith(isLookingUp: false, result: r);
    } on MeterLookupFailure catch (e) {
      state = state.copyWith(isLookingUp: false, error: e.message);
    }
  }

  /// Ajoute le compteur reconnu et le sélectionne. Renvoie son identifiant.
  String add(String name) {
    final meters = ref.read(metersProvider);
    final id = 'm${meters.length + 1}_${DateTime.now().millisecondsSinceEpoch}';
    final meter = _repo
        .create(
          state.result!,
          NewMeterInput(name: name, kind: state.kind),
          id,
        )
        // Le compteur appartient à l'utilisateur connecté.
        .copyWith(ownerId: ref.read(currentUserProvider)?.id);
    ref.read(metersProvider.notifier).add(meter);
    ref.read(selectedMeterIdProvider.notifier).state = id;
    return id;
  }
}

final addMeterControllerProvider =
    NotifierProvider.autoDispose<AddMeterController, AddMeterState>(
  AddMeterController.new,
);