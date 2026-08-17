import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/reel_item.dart';

/// Manages the list of reels and favorites state.
class ReelsNotifier extends StateNotifier<List<ReelItem>> {
  ReelsNotifier() : super(const []) {
    _listenToReels();
  }

  StreamSubscription? _subscription;
  final List<String> _localFavorites = [];

  void _listenToReels() {
    _subscription = FirebaseFirestore.instance
        .collection('reels')
        .snapshots()
        .listen((snap) {
      state = snap.docs.map((doc) => _reelFromFirestore(doc)).toList();
    }, onError: (Object error, StackTrace stackTrace) {
      debugPrint('Error loading reels from Firestore: $error');
    });
  }

  ReelItem _reelFromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final categoryStr = data['category'] as String?;
    final category = ReelCategory.values.firstWhere(
      (c) => c.name == categoryStr,
      orElse: () => ReelCategory.vaccins,
    );
    final isFav = _localFavorites.contains(doc.id);
    final rawLikes = data['likeCount'] ?? data['likes'] ?? 0;

    return ReelItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      assetPath: data['assetPath'] as String? ?? '',
      author: data['author'] as String? ?? 'Luckymam',
      likeCount: rawLikes is num ? rawLikes.toInt() : 0,
      category: category,
      isFavorite: isFav,
      vaccineTags: List<String>.from(data['vaccineTags'] ?? []),
    );
  }

  Future<void> toggleFavorite(String reelId) async {
    final wasFavorite = _localFavorites.contains(reelId);
    if (wasFavorite) {
      _localFavorites.remove(reelId);
    } else {
      _localFavorites.add(reelId);
    }

    state = [
      for (final r in state)
        if (r.id == reelId)
          r.copyWith(
            isFavorite: !wasFavorite,
            likeCount: wasFavorite ? r.likeCount - 1 : r.likeCount + 1,
          )
        else
          r,
    ];

    try {
      final docRef = FirebaseFirestore.instance.collection('reels').doc(reelId);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({
          'likeCount': FieldValue.increment(wasFavorite ? -1 : 1),
          'likes': FieldValue.increment(wasFavorite ? -1 : 1),
        });
      }
    } catch (e) {
      debugPrint('Error updating reel likeCount: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final reelsProvider = StateNotifierProvider<ReelsNotifier, List<ReelItem>>(
  (ref) => ReelsNotifier(),
);

/// Tracks which reel is currently visible.
final currentReelIndexProvider = StateProvider<int>((ref) => 0);

/// Currently selected category filter (null = all)
final selectedReelCategoryProvider = StateProvider<ReelCategory?>(
  (ref) => null,
);

/// Vaccine codes to filter by when the reels screen is opened from a
/// vaccine's fiche (null = no vaccine filter applied).
final selectedVaccineTagsProvider = StateProvider<List<String>?>(
  (ref) => null,
);

/// Firestore id for the Luckymam app intro reel — pinned first in the feed.
const appReelId = 'reel_app';

/// Filtered reels based on selected category and, optionally, vaccine tags.
final filteredReelsProvider = Provider<List<ReelItem>>((ref) {
  final all = ref.watch(reelsProvider);
  final category = ref.watch(selectedReelCategoryProvider);
  final vaccineTags = ref.watch(selectedVaccineTagsProvider);

  var result = all.where((r) => r.assetPath.isNotEmpty).toList();
  if (category != null) {
    result = result.where((r) => r.category == category).toList();
  }
  if (vaccineTags != null && vaccineTags.isNotEmpty) {
    result = result
        .where((r) => r.vaccineTags.any(vaccineTags.contains))
        .toList();
  }

  // Pin the app intro reel first unless the user opened a vaccine-scoped feed.
  final pinAppReel = vaccineTags == null || vaccineTags.isEmpty;
  if (pinAppReel) {
    result = _withAppReelFirst(result);
  }
  return result;
});

List<ReelItem> _withAppReelFirst(List<ReelItem> reels) {
  final appReel = reels.where((r) => r.id == appReelId);
  if (appReel.isEmpty) return reels;
  return [
    ...appReel,
    ...reels.where((r) => r.id != appReelId),
  ];
}
