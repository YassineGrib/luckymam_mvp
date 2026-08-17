import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/cycle_notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

/// Provider for ProfileService instance.
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Stream provider for current user profile.
final profileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value(null);

  final service = ref.watch(profileServiceProvider);
  return service.watchProfile();
});

/// Stream provider for children list.
final childrenProvider = StreamProvider<List<Child>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

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
      return ProfileActionsNotifier(
        ref.watch(profileServiceProvider),
        ref.watch(cycleNotificationServiceProvider),
      );
    });

/// Snackbar success message keys resolved in the UI layer.
enum ProfileSnackMessage {
  personalInfoUpdated,
  photoUpdated,
  statusUpdated,
  medicalUpdated,
  cycleUpdated,
  periodLogged,
  pregnancyLmpSaved,
  childAdded,
  childUpdated,
  childDeleted,
}

extension ProfileSnackMessageL10n on ProfileSnackMessage {
  String localize(AppLocalizations l10n) {
    switch (this) {
      case ProfileSnackMessage.personalInfoUpdated:
        return l10n.profileSnackPersonalInfoUpdated;
      case ProfileSnackMessage.photoUpdated:
        return l10n.profileSnackPhotoUpdated;
      case ProfileSnackMessage.statusUpdated:
        return l10n.profileSnackStatusUpdated;
      case ProfileSnackMessage.medicalUpdated:
        return l10n.profileSnackMedicalUpdated;
      case ProfileSnackMessage.cycleUpdated:
        return l10n.profileSnackCycleUpdated;
      case ProfileSnackMessage.periodLogged:
        return l10n.profileSnackPeriodLogged;
      case ProfileSnackMessage.pregnancyLmpSaved:
        return l10n.profileSnackPregnancyLmpSaved;
      case ProfileSnackMessage.childAdded:
        return l10n.profileSnackChildAdded;
      case ProfileSnackMessage.childUpdated:
        return l10n.profileSnackChildUpdated;
      case ProfileSnackMessage.childDeleted:
        return l10n.profileSnackChildDeleted;
    }
  }
}

/// State for profile actions (loading, error handling).
class ProfileActionsState {
  final bool isLoading;
  final String? errorDetails;
  final ProfileSnackMessage? successMessage;

  const ProfileActionsState({
    this.isLoading = false,
    this.errorDetails,
    this.successMessage,
  });

  ProfileActionsState copyWith({
    bool? isLoading,
    String? errorDetails,
    ProfileSnackMessage? successMessage,
  }) {
    return ProfileActionsState(
      isLoading: isLoading ?? this.isLoading,
      errorDetails: errorDetails,
      successMessage: successMessage,
    );
  }
}

/// Notifier for profile actions.
class ProfileActionsNotifier extends StateNotifier<ProfileActionsState> {
  final ProfileService _service;
  final CycleNotificationService _cycleNotif;

  ProfileActionsNotifier(this._service, this._cycleNotif)
    : super(const ProfileActionsState());

  /// Clear messages.
  void clearMessages() {
    state = state.copyWith(errorDetails: null, successMessage: null);
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
        successMessage: ProfileSnackMessage.personalInfoUpdated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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
        successMessage: ProfileSnackMessage.photoUpdated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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
        successMessage: ProfileSnackMessage.statusUpdated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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
        successMessage: ProfileSnackMessage.medicalUpdated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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
        successMessage: ProfileSnackMessage.cycleUpdated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
      );
    }
  }

  /// Log period start.
  Future<void> logPeriodStart(DateTime date) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.logPeriodStart(date);

      // Re-schedule cycle reminders with the new period date
      final updatedProfile = await _service.getProfile();
      if (updatedProfile != null) {
        await _cycleNotif.scheduleReminders(updatedProfile.cycleInfo);
      }

      state = state.copyWith(
        isLoading: false,
        successMessage: ProfileSnackMessage.periodLogged,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
      );
    }
  }

  /// Save DDR for pregnancy DPA calculation.
  Future<void> savePregnancyLmp(DateTime lmpDate) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.savePregnancyLmp(lmpDate);
      state = state.copyWith(
        isLoading: false,
        successMessage: ProfileSnackMessage.pregnancyLmpSaved,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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

      state = state.copyWith(
        isLoading: false,
        successMessage: ProfileSnackMessage.childAdded,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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
        successMessage: ProfileSnackMessage.childUpdated,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
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
        successMessage: ProfileSnackMessage.childDeleted,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorDetails: e.toString(),
      );
    }
  }
}
