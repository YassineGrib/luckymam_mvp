import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  ReelsNotifier() : super(_initialReels);

  void toggleFavorite(String reelId) {
    state = [
      for (final reel in state)
        if (reel.id == reelId)
          reel.copyWith(
            isFavorite: !reel.isFavorite,
            likeCount: reel.isFavorite
                ? reel.likeCount - 1
                : reel.likeCount + 1,
          )
        else
          reel,
    ];
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

/// Filtered reels based on selected category
final filteredReelsProvider = Provider<List<ReelItem>>((ref) {
  final all = ref.watch(reelsProvider);
  final category = ref.watch(selectedReelCategoryProvider);
  if (category == null) return all;
  return all.where((r) => r.category == category).toList();
});
