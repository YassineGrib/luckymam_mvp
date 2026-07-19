import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../models/standard_album.dart';
import '../services/standard_album_service.dart';

/// Provider for StandardAlbumService instance.
final standardAlbumServiceProvider = Provider<StandardAlbumService>((ref) {
  return StandardAlbumService();
});

/// Stream provider for a child's standard albums.
final standardAlbumsForChildProvider =
    StreamProvider.family<List<StandardAlbum>, String>((ref, childId) {
      final uid = ref.watch(userIdProvider);
      if (uid == null) return Stream.value([]);
      final service = ref.watch(standardAlbumServiceProvider);
      return service.watchAlbumsForChild(childId);
    });

/// Stream provider for a single standard album.
final standardAlbumProvider = StreamProvider.family<StandardAlbum?, String>((
  ref,
  albumId,
) {
  final service = ref.watch(standardAlbumServiceProvider);
  return service.watchAlbum(albumId);
});

/// Actions notifier for standard-album operations.
class StandardAlbumActionsNotifier extends StateNotifier<AsyncValue<void>> {
  StandardAlbumActionsNotifier(this._service)
    : super(const AsyncValue.data(null));

  final StandardAlbumService _service;

  Future<StandardAlbum?> createAlbum({
    required String childId,
    required String title,
  }) async {
    state = const AsyncValue.loading();
    StandardAlbum? created;
    state = await AsyncValue.guard(() async {
      created = await _service.createAlbum(childId: childId, title: title);
      AnalyticsService().logEvent(
        'album_standard_created',
        parameters: {'childId': childId, 'albumId': created!.id},
      );
    });
    return created;
  }

  Future<void> addCapsuleToPage({
    required String albumId,
    required int pageIndex,
    required String capsuleId,
    required String method,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.addCapsuleToPage(
        albumId: albumId,
        pageIndex: pageIndex,
        capsuleId: capsuleId,
      );
      AnalyticsService().logEvent(
        'album_slot_added',
        parameters: {
          'albumId': albumId,
          'pageIndex': pageIndex,
          'method': method, // 'existing' | 'new'
        },
      );
    });
  }

  Future<void> clearPage({
    required String albumId,
    required int pageIndex,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.clearPage(albumId: albumId, pageIndex: pageIndex),
    );
  }

  Future<void> addPage(String albumId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.addPage(albumId));
  }

  Future<void> updateTitle({
    required String albumId,
    required String title,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.updateTitle(albumId: albumId, title: title),
    );
  }

  Future<void> deleteAlbum(String albumId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.deleteAlbum(albumId));
  }

  /// Logs that the draft's current state was preserved when the user
  /// left the album (all writes are already persisted to Firestore
  /// immediately, so this simply marks the checkpoint for analytics).
  void logDraftSaved(String albumId) {
    AnalyticsService().logEvent(
      'album_draft_saved',
      parameters: {'albumId': albumId},
    );
  }
}

final standardAlbumActionsProvider =
    StateNotifierProvider<StandardAlbumActionsNotifier, AsyncValue<void>>((
      ref,
    ) {
      return StandardAlbumActionsNotifier(
        ref.watch(standardAlbumServiceProvider),
      );
    });
