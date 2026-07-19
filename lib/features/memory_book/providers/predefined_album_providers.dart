import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../models/predefined_album.dart';
import '../services/predefined_album_service.dart';

/// Provider for PredefinedAlbumService instance.
final predefinedAlbumServiceProvider = Provider<PredefinedAlbumService>((ref) {
  return PredefinedAlbumService();
});

/// Stream provider for a child's predefined albums.
final predefinedAlbumsForChildProvider =
    StreamProvider.family<List<PredefinedAlbum>, String>((ref, childId) {
      final uid = ref.watch(userIdProvider);
      if (uid == null) return Stream.value([]);
      final service = ref.watch(predefinedAlbumServiceProvider);
      return service.watchAlbumsForChild(childId);
    });

/// Stream provider for a single predefined album.
final predefinedAlbumProvider =
    StreamProvider.family<PredefinedAlbum?, String>((ref, albumId) {
      final service = ref.watch(predefinedAlbumServiceProvider);
      return service.watchAlbum(albumId);
    });

/// Actions notifier for predefined-album operations.
class PredefinedAlbumActionsNotifier extends StateNotifier<AsyncValue<void>> {
  PredefinedAlbumActionsNotifier(this._service)
    : super(const AsyncValue.data(null));

  final PredefinedAlbumService _service;

  Future<PredefinedAlbum?> createAlbum({
    required String childId,
    required String templateId,
  }) async {
    state = const AsyncValue.loading();
    PredefinedAlbum? created;
    state = await AsyncValue.guard(() async {
      created = await _service.createAlbum(
        childId: childId,
        templateId: templateId,
      );
      AnalyticsService().logEvent(
        'album_template_selected',
        parameters: {'templateId': templateId, 'childId': childId},
      );
    });
    return created;
  }

  Future<void> attachCapsuleToSlot({
    required String albumId,
    required String slotId,
    required String capsuleId,
    required String templateId,
    required String method,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.attachCapsuleToSlot(
        albumId: albumId,
        slotId: slotId,
        capsuleId: capsuleId,
      );
      AnalyticsService().logEvent(
        'album_event_slot_filled',
        parameters: {
          'albumId': albumId,
          'templateId': templateId,
          'slotId': slotId,
          'method': method, // 'existing' | 'new'
        },
      );
    });
  }

  Future<void> clearSlot({
    required String albumId,
    required String slotId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.clearSlot(albumId: albumId, slotId: slotId),
    );
  }

  Future<void> deleteAlbum(String albumId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.deleteAlbum(albumId));
  }
}

final predefinedAlbumActionsProvider =
    StateNotifierProvider<PredefinedAlbumActionsNotifier, AsyncValue<void>>((
      ref,
    ) {
      return PredefinedAlbumActionsNotifier(
        ref.watch(predefinedAlbumServiceProvider),
      );
    });
