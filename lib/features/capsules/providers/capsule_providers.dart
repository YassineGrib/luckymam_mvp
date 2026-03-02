import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final service = ref.watch(capsuleServiceProvider);
  return service.watchCapsules();
});

/// Stream provider for capsules by child.
final capsulesByChildProvider = StreamProvider.family<List<Capsule>, String?>((
  ref,
  childId,
) {
  final service = ref.watch(capsuleServiceProvider);
  if (childId == null) {
    return service.watchCapsules();
  }
  return service.watchCapsulesForChild(childId);
});

/// Provider for capsule count (quota check).
final capsuleCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(capsuleServiceProvider);
  return service.getCapsuleCount();
});

/// Quota limits by tier.
const int freemiumCapsuleLimit = 25;

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
    required String childId,
    required File photoFile,
    File? audioFile,
    int? audioDuration,
    required Emotion emotion,
    String? milestoneId,
    List<String> tags = const [],
    DateTime? capturedAt,
    CapsuleCategory? category,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final capsule = await _service.createCapsule(
        childId: childId,
        photoFile: photoFile,
        audioFile: audioFile,
        audioDuration: audioDuration,
        emotion: emotion,
        milestoneId: milestoneId,
        tags: tags,
        capturedAt: capturedAt,
        category: category,
      );

      // If tied to a milestone, mark it as completed
      if (milestoneId != null) {
        try {
          final timelineService = _ref.read(timelineServiceProvider);
          await timelineService.completeMilestone(
            userId: capsule.userId,
            childId: childId,
            milestoneId: milestoneId,
            capsuleId: capsule.id,
          );
        } catch (e) {
          // Log error but don't fail the whole operation
          // debugPrint('Failed to complete milestone: $e');
        }
      }
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
