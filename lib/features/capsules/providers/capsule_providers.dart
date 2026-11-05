import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../models/capsule.dart';
import '../models/emotion.dart';
import '../services/capsule_service.dart';
import '../../timeline/services/timeline_service.dart';
import '../../subscription/providers/subscription_providers.dart';

/// Provider for CapsuleService instance.
final capsuleServiceProvider = Provider<CapsuleService>((ref) {
  return CapsuleService();
});

/// Stream provider for all capsules.
final capsulesProvider = StreamProvider<List<Capsule>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(capsuleServiceProvider);
  return service.watchCapsules();
});

/// Stream provider for capsules by child.
final capsulesByChildProvider = StreamProvider.family<List<Capsule>, String?>((
  ref,
  childId,
) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(capsuleServiceProvider);
  if (childId == null) {
    return service.watchCapsules();
  }
  return service.watchCapsulesForChild(childId);
});

/// Stream provider for capsules featuring the mother.
final motherCapsulesProvider = StreamProvider<List<Capsule>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(capsuleServiceProvider);
  return service.watchMotherCapsules();
});

/// Stream provider for family space capsules.
final familyCapsulesProvider = StreamProvider<List<Capsule>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(capsuleServiceProvider);
  return service.watchFamilyCapsules();
});

/// Provider for capsule count (quota check).
final capsuleCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(capsuleServiceProvider);
  return service.getCapsuleCount();
});

/// Quota limits by tier (Free tier allows up to 38 capsules max as per LM-SUB-002).
const int freemiumCapsuleLimit = 38;

/// Provider to check if user can create more capsules (tier-aware).
final canCreateCapsuleProvider = FutureProvider<bool>((ref) async {
  final count = await ref.watch(capsuleCountProvider.future);
  final limit = ref.watch(tierCapsuleLimitProvider);
  // -1 means unlimited (Premium/VIP)
  if (limit == -1) return true;
  return count < limit;
});

/// Provider for remaining capsule quota (tier-aware).
final remainingCapsuleQuotaProvider = FutureProvider<int>((ref) async {
  final count = await ref.watch(capsuleCountProvider.future);
  final limit = ref.watch(tierCapsuleLimitProvider);
  if (limit == -1) return 999; // Unlimited
  return (limit - count).clamp(0, limit);
});

/// Filter state for capsules gallery.
class CapsuleFilterState {
  final String? childId;
  final Emotion? emotion;
  final bool favoritesOnly;

  const CapsuleFilterState({
    this.childId,
    this.emotion,
    this.favoritesOnly = false,
  });

  CapsuleFilterState copyWith({
    String? childId,
    Emotion? emotion,
    bool? favoritesOnly,
    bool clearChildId = false,
    bool clearEmotion = false,
  }) {
    return CapsuleFilterState(
      childId: clearChildId ? null : (childId ?? this.childId),
      emotion: clearEmotion ? null : (emotion ?? this.emotion),
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  bool get hasFilters => childId != null || emotion != null || favoritesOnly;
}

/// Filter state notifier.
final capsuleFilterProvider =
    StateNotifierProvider<CapsuleFilterNotifier, CapsuleFilterState>((ref) {
      return CapsuleFilterNotifier();
    });

class CapsuleFilterNotifier extends StateNotifier<CapsuleFilterState> {
  CapsuleFilterNotifier() : super(const CapsuleFilterState());

  void setChildId(String? childId) {
    state = state.copyWith(childId: childId, clearChildId: childId == null);
  }

  void setEmotion(Emotion? emotion) {
    state = state.copyWith(emotion: emotion, clearEmotion: emotion == null);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(favoritesOnly: !state.favoritesOnly);
  }

  void clearFilters() {
    state = const CapsuleFilterState();
  }
}

/// Filtered capsules based on filter state.
final filteredCapsulesProvider = StreamProvider<List<Capsule>>((ref) {
  final uid = ref.watch(userIdProvider);
  if (uid == null) return Stream.value([]);

  final service = ref.watch(capsuleServiceProvider);
  final filters = ref.watch(capsuleFilterProvider);

  return service.watchFilteredCapsules(
    childId: filters.childId,
    emotion: filters.emotion,
    favoritesOnly: filters.favoritesOnly,
  );
});

/// Actions notifier for capsule operations.
class CapsuleActionsState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CapsuleActionsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  CapsuleActionsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return CapsuleActionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

final capsuleActionsProvider =
    StateNotifierProvider<CapsuleActionsNotifier, CapsuleActionsState>((ref) {
      return CapsuleActionsNotifier(ref.watch(capsuleServiceProvider), ref);
    });

class CapsuleActionsNotifier extends StateNotifier<CapsuleActionsState> {
  final CapsuleService _service;
  final Ref _ref;

  CapsuleActionsNotifier(this._service, this._ref)
    : super(const CapsuleActionsState());

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  /// Create new capsule.
  Future<Capsule?> createCapsule({
    String? childId,
    List<String>? childIds,
    bool withMother = false,
    String? pregnancyId,
    int? pregnancyWeek,
    required File photoFile,
    File? audioFile,
    int? audioDuration,
    required Emotion emotion,
    List<Emotion> secondaryEmotions = const [],
    String? milestoneId,
    String? vaccineGroupId,
    String? albumId,
    String? albumSlotId,
    String? albumType,
    List<String> tags = const [],
    DateTime? capturedAt,
    CapsuleCategory? category,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final capsule = await _service.createCapsule(
        childId: childId,
        childIds: childIds,
        withMother: withMother,
        pregnancyId: pregnancyId,
        pregnancyWeek: pregnancyWeek,
        photoFile: photoFile,
        audioFile: audioFile,
        audioDuration: audioDuration,
        emotion: emotion,
        secondaryEmotions: secondaryEmotions,
        milestoneId: milestoneId,
        vaccineGroupId: vaccineGroupId,
        albumId: albumId,
        albumSlotId: albumSlotId,
        albumType: albumType,
        tags: tags,
        capturedAt: capturedAt,
        category: category,
      );

      // If tied to a milestone, mark it as completed
      final effectiveChildId = capsule.childId.isNotEmpty
          ? capsule.childId
          : (capsule.childIds.isNotEmpty ? capsule.childIds.first : '');
      if (milestoneId != null && effectiveChildId.isNotEmpty) {
        try {
          final timelineService = _ref.read(timelineServiceProvider);
          await timelineService.completeMilestone(
            userId: capsule.userId,
            childId: effectiveChildId,
            milestoneId: milestoneId,
            capsuleId: capsule.id,
            completedAt: capsule.capturedAt ?? capsule.createdAt,
          );
          AnalyticsService().logEvent('milestone_capsule_created', parameters: {
            'milestone_id': milestoneId,
            'capsule_id': capsule.id,
          });
        } catch (e) {
          // Log error but don't fail the whole operation
        }
        _ref.invalidate(childMilestonesProvider(effectiveChildId));
        _ref.invalidate(milestoneProgressStreamProvider(effectiveChildId));
      }
      _ref.invalidate(capsulesProvider);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Capsule créée avec succès',
      );
      return capsule;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
      return null;
    }
  }

  /// Update an existing capsule.
  Future<Capsule?> updateCapsule({
    required String capsuleId,
    String? childId,
    List<String>? childIds,
    bool withMother = false,
    File? newPhotoFile,
    File? newAudioFile,
    bool removeAudio = false,
    int? audioDuration,
    required Emotion emotion,
    List<Emotion> secondaryEmotions = const [],
    String? milestoneId,
    String? oldMilestoneId,
    List<String> tags = const [],
    DateTime? capturedAt,
    CapsuleCategory? category,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedCapsule = await _service.updateCapsule(
        capsuleId: capsuleId,
        childId: childId,
        childIds: childIds,
        withMother: withMother,
        newPhotoFile: newPhotoFile,
        newAudioFile: newAudioFile,
        removeAudio: removeAudio,
        audioDuration: audioDuration,
        emotion: emotion,
        secondaryEmotions: secondaryEmotions,
        milestoneId: milestoneId,
        oldMilestoneId: oldMilestoneId,
        tags: tags,
        capturedAt: capturedAt,
        category: category,
      );

      final effectiveChildId = updatedCapsule.childId.isNotEmpty
          ? updatedCapsule.childId
          : (updatedCapsule.childIds.isNotEmpty ? updatedCapsule.childIds.first : '');

      if (effectiveChildId.isNotEmpty) {
        _ref.invalidate(childMilestonesProvider(effectiveChildId));
        _ref.invalidate(milestoneProgressStreamProvider(effectiveChildId));
        _ref.invalidate(capsulesByChildProvider(effectiveChildId));
      }
      _ref.invalidate(capsulesProvider);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Capsule modifiée avec succès',
      );
      return updatedCapsule;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
      return null;
    }
  }

  /// Toggle favorite.
  Future<void> toggleFavorite(String capsuleId) async {
    try {
      await _service.toggleFavorite(capsuleId);
    } catch (e) {
      state = state.copyWith(error: 'Erreur: ${e.toString()}');
    }
  }

  /// Delete capsule.
  Future<void> deleteCapsule(Capsule capsule) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteCapsule(capsule);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Capsule supprimée',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }
}
