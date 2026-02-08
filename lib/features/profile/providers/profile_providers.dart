import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

/// Provider for ProfileService instance.
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Stream provider for current user profile.
final profileProvider = StreamProvider<UserProfile?>((ref) {
  final service = ref.watch(profileServiceProvider);
  return service.watchProfile();
});

/// Stream provider for children list.
final childrenProvider = StreamProvider<List<Child>>((ref) {
  final service = ref.watch(profileServiceProvider);
  return service.watchChildren();
});

/// State provider for selected child ID
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

/// Provider for the currently selected child (or first child if none selected)
final selectedChildProvider = Provider<AsyncValue<Child?>>((ref) {
  final childrenAsync = ref.watch(childrenProvider);
  final selectedId = ref.watch(selectedChildIdProvider);

  return childrenAsync.when(
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
    data: (children) {
      if (children.isEmpty) return const AsyncData(null);

      if (selectedId != null) {
        final selected = children.where((c) => c.id == selectedId).firstOrNull;
        if (selected != null) return AsyncData(selected);
      }

      // Default to first child
      return AsyncData(children.first);
    },
  );
});

/// Provider for profile loading state notifier.
final profileActionsProvider =
    StateNotifierProvider<ProfileActionsNotifier, ProfileActionsState>((ref) {
      return ProfileActionsNotifier(ref.watch(profileServiceProvider));
    });

/// State for profile actions (loading, error handling).
class ProfileActionsState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileActionsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileActionsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Notifier for profile actions.
class ProfileActionsNotifier extends StateNotifier<ProfileActionsState> {
  final ProfileService _service;

  ProfileActionsNotifier(this._service) : super(const ProfileActionsState());

  /// Clear messages.
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  /// Update personal info.
  Future<void> updatePersonalInfo({
    String? displayName,
    String? phone,
    DateTime? birthDate,
    String? wilaya,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updatePersonalInfo(
        displayName: displayName,
        phone: phone,
        birthDate: birthDate,
        wilaya: wilaya,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Informations mises à jour',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Update profile photo.
  Future<void> updateProfilePhoto(File file) async {
    state = state.copyWith(isLoading: true);
    try {
      final photoUrl = await _service.uploadUserProfilePhoto(file);
      await _service.updatePersonalInfo(photoUrl: photoUrl);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Photo de profil mise à jour',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Update user status.
  Future<void> updateStatus(
    UserStatus status, {
    DateTime? pregnancyDate,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateStatus(status, pregnancyDate: pregnancyDate);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Statut mis à jour',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Update medical info.
  Future<void> updateMedicalInfo(MedicalInfo info) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateMedicalInfo(info);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Informations médicales mises à jour',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Update cycle info.
  Future<void> updateCycleInfo(CycleInfo info) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateCycleInfo(info);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cycle mis à jour',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Log period start.
  Future<void> logPeriodStart(DateTime date) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.logPeriodStart(date);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Règles enregistrées',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Add child.
  Future<void> addChild(Child child, {File? imageFile}) async {
    state = state.copyWith(isLoading: true);
    try {
      String? photoUrl;

      // If image file provided, upload it first
      if (imageFile != null) {
        // We need a child ID for the path, so we create the doc first or use a temp ID.
        // The service's addChild returns the ID.
        final childId = await _service.addChild(child);
        photoUrl = await _service.uploadChildPhoto(childId, imageFile);

        // Update the child with the new photo URL
        await _service.updateChild(
          child.copyWith(id: childId, photoUrl: photoUrl),
        );
      } else {
        await _service.addChild(child);
      }

      state = state.copyWith(isLoading: false, successMessage: 'Enfant ajouté');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Update child.
  Future<void> updateChild(Child child, {File? imageFile}) async {
    state = state.copyWith(isLoading: true);
    try {
      String? photoUrl = child.photoUrl;

      if (imageFile != null) {
        photoUrl = await _service.uploadChildPhoto(child.id, imageFile);
      }

      await _service.updateChild(child.copyWith(photoUrl: photoUrl));
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Enfant mis à jour',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  /// Delete child.
  Future<void> deleteChild(String childId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteChild(childId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Enfant supprimé',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }
}
