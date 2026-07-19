import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/reel_item.dart';

/// Hardcoded local reels enriched with categories (will be replaced with Firestore later).
final _initialReels = <ReelItem>[
  const ReelItem(
    id: 'reel_1',
    title: 'Soins de bébé',
    description:
        'Les gestes essentiels pour prendre soin de votre nouveau-né au quotidien 👶',
    assetPath: 'assets/videos/reels/reel_baby_care_tips.mp4',
    author: 'Dr. Amina',
    likeCount: 234,
    category: ReelCategory.soinsQuotidiens,
  ),
  const ReelItem(
    id: 'reel_2',
    title: 'Guide Nutrition',
    description:
        "Alimentation équilibrée pour maman et bébé — conseils d'une nutritionniste 🥗",
    assetPath: 'assets/videos/reels/reel_nutrition_guide.mp4',
    author: 'Nadia K.',
    likeCount: 189,
    category: ReelCategory.nutrition,
  ),
  const ReelItem(
    id: 'reel_3',
    title: 'Premiers Pas',
    description:
        "Comment accompagner votre enfant dans l'apprentissage de la marche 🚶‍♂️",
    assetPath: 'assets/videos/reels/reel_first_steps.mp4',
    author: 'Meriem B.',
    likeCount: 312,
    category: ReelCategory.soutienEnfants,
  ),
  const ReelItem(
    id: 'reel_4',
    title: 'Vaccins : le calendrier',
    description:
        'Tout savoir sur le calendrier vaccinal de votre bébé — ne ratez aucun vaccin 🔬',
    assetPath: 'assets/videos/reels/reel_baby_care_tips.mp4',
    author: 'Dr. Youcef',
    likeCount: 421,
    category: ReelCategory.vaccins,
    // General calendar overview — relevant to every vaccine in the national calendar.
    vaccineTags: [
      'BCG',
      'HBV',
      'DTCaVPI-Hib-HBV',
      'VPOb',
      'VPC',
      'ROR',
      'DTCa-VPI',
      'dT',
    ],
  ),
  const ReelItem(
    id: 'reel_5',
    title: 'Grossesse & HTA',
    description:
        "Comprendre et gerer l'hypertension arterielle pendant la grossesse",
    assetPath: 'assets/videos/reels/reel_nutrition_guide.mp4',
    author: 'Dr. Fatima',
    likeCount: 198,
    category: ReelCategory.grossessehta,
  ),

  const ReelItem(
    id: 'reel_6',
    title: 'Diabète gestationnel',
    description:
        'Conseils pratiques pour gérer le diabète pendant votre grossesse 🩸',
    assetPath: 'assets/videos/reels/reel_first_steps.mp4',
    author: 'Dr. Karima',
    likeCount: 267,
    category: ReelCategory.grossessediabete,
  ),
];

/// Manages the list of reels and favorites state.
class ReelsNotifier extends StateNotifier<List<ReelItem>> {
  ReelsNotifier() : super(_initialReels) {
    _listenToReels();
  }

  StreamSubscription? _subscription;
  final List<String> _localFavorites = [];

  void _listenToReels() {
    _subscription = FirebaseFirestore.instance
        .collection('reels')
        .snapshots()
        .listen((snap) {
      if (snap.docs.isEmpty) {
        // Fallback to local mock data if firestore is empty
        state = _initialReels.map((r) {
          return r.copyWith(isFavorite: _localFavorites.contains(r.id));
        }).toList();
        return;
      }
      state = snap.docs.map((doc) {
        final data = doc.data();
        final categoryStr = data['category'] as String?;
        final category = ReelCategory.values.firstWhere(
          (c) => c.name == categoryStr,
          orElse: () => ReelCategory.vaccins,
        );
        final isFav = _localFavorites.contains(doc.id);
        return ReelItem(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          assetPath: data['assetPath'] ?? '',
          author: data['author'] ?? 'Luckymam',
          likeCount: data['likeCount'] ?? 0,
          category: category,
          isFavorite: isFav,
          vaccineTags: List<String>.from(data['vaccineTags'] ?? []),
        );
      }).toList();
    });
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
          r
    ];

    try {
      final docRef = FirebaseFirestore.instance.collection('reels').doc(reelId);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        await docRef.update({
          'likeCount': FieldValue.increment(wasFavorite ? -1 : 1),
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

/// Filtered reels based on selected category and, optionally, vaccine tags.
final filteredReelsProvider = Provider<List<ReelItem>>((ref) {
  final all = ref.watch(reelsProvider);
  final category = ref.watch(selectedReelCategoryProvider);
  final vaccineTags = ref.watch(selectedVaccineTagsProvider);

  var result = all;
  if (category != null) {
    result = result.where((r) => r.category == category).toList();
  }
  if (vaccineTags != null && vaccineTags.isNotEmpty) {
    result = result
        .where((r) => r.vaccineTags.any(vaccineTags.contains))
        .toList();
  }
  return result;
});
