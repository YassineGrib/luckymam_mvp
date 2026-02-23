import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capsules/models/capsule.dart';
import '../../capsules/models/emotion.dart';
import '../../capsules/providers/capsule_providers.dart';

import '../../profile/providers/profile_providers.dart';
import '../models/album_suggestion.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FRENCH MONTH NAMES
// ═══════════════════════════════════════════════════════════════════════════

const _monthNamesFr = [
  '', // index 0 unused
  'Janvier', 'Février', 'Mars', 'Avril',
  'Mai', 'Juin', 'Juillet', 'Août',
  'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

// ═══════════════════════════════════════════════════════════════════════════
// ACCENT COLORS FOR ALBUM TYPES
// ═══════════════════════════════════════════════════════════════════════════

const _monthColors = [
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFE53935),
  Color(0xFFFF9800),
  Color(0xFF8E24AA),
  Color(0xFF00ACC1),
  Color(0xFFFDD835),
  Color(0xFF6D4C41),
  Color(0xFFD81B60),
  Color(0xFF3949AB),
  Color(0xFF00897B),
  Color(0xFFC62828),
];

final _emotionColors = {
  Emotion.happy: const Color(0xFFFBC02D),
  Emotion.love: const Color(0xFFE91E63),
  Emotion.tender: const Color(0xFFFF8A80),
  Emotion.sad: const Color(0xFF5C6BC0),
  Emotion.surprised: const Color(0xFF26A69A),
  Emotion.sleepy: const Color(0xFF7E57C2),
  Emotion.proud: const Color(0xFFFF6F00),
  Emotion.worried: const Color(0xFF78909C),
};

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Filter state for memory book (optional child filter).
final memoryBookChildFilterProvider = StateProvider<String?>((ref) => null);

/// Main provider: generates album suggestions from all capsules.
final albumSuggestionsProvider = Provider<AsyncValue<List<AlbumSuggestion>>>((
  ref,
) {
  final capsulesAsync = ref.watch(capsulesProvider);
  final childrenAsync = ref.watch(childrenProvider);
  final childFilter = ref.watch(memoryBookChildFilterProvider);

  return capsulesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (capsules) {
      final children = childrenAsync.valueOrNull ?? [];
      final childMap = {for (final c in children) c.id: c.name};

      // Apply child filter
      final filtered = childFilter == null
          ? capsules
          : capsules.where((c) => c.childId == childFilter).toList();

      final albums = <AlbumSuggestion>[];

      // 1) Monthly albums
      albums.addAll(_generateMonthlyAlbums(filtered, childMap));

      // 2) Emotion albums
      albums.addAll(_generateEmotionAlbums(filtered, childMap));

      // 3) Favorites album
      final favAlbum = _generateFavoritesAlbum(filtered);
      if (favAlbum != null) albums.add(favAlbum);

      // 4) First Moments per child
      albums.addAll(_generateFirstMomentsAlbums(filtered, childMap));

      // 5) All Memories per child
      albums.addAll(_generateAllMemoriesAlbums(filtered, childMap));

      return AsyncValue.data(albums);
    },
  );
});

/// Total album count for the dashboard badge.
final albumCountProvider = Provider<int>((ref) {
  final albums = ref.watch(albumSuggestionsProvider);
  return albums.valueOrNull?.length ?? 0;
});

// ═══════════════════════════════════════════════════════════════════════════
// ALBUM GENERATION LOGIC
// ═══════════════════════════════════════════════════════════════════════════

List<AlbumSuggestion> _generateMonthlyAlbums(
  List<Capsule> capsules,
  Map<String, String> childMap,
) {
  // Group by childId → year-month
  final grouped = <String, Map<String, List<Capsule>>>{};
  for (final c in capsules) {
    final key =
        '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}';
    grouped.putIfAbsent(c.childId, () => {});
    grouped[c.childId]!.putIfAbsent(key, () => []);
    grouped[c.childId]![key]!.add(c);
  }

  final albums = <AlbumSuggestion>[];
  for (final entry in grouped.entries) {
    final childId = entry.key;
    final childName = childMap[childId] ?? 'Enfant';
    for (final monthEntry in entry.value.entries) {
      final items = monthEntry.value;
      if (items.length < 2) continue; // min 2 capsules for monthly album

      final parts = monthEntry.key.split('-');
      final year = parts[0];
      final month = int.parse(parts[1]);
      final monthName = _monthNamesFr[month];
      final colorIndex = (month - 1) % _monthColors.length;

      albums.add(
        AlbumSuggestion(
          id: 'monthly_${childId}_${monthEntry.key}',
          title: '$monthName $year',
          subtitle: '$childName · ${items.length} souvenirs',
          type: AlbumType.monthly,
          childId: childId,
          childName: childName,
          capsules: items..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
          icon: AlbumType.monthly.icon,
          accentColor: _monthColors[colorIndex],
        ),
      );
    }
  }

  // Sort newest month first
  albums.sort(
    (a, b) => b.capsules.first.createdAt.compareTo(a.capsules.first.createdAt),
  );
  return albums;
}

List<AlbumSuggestion> _generateEmotionAlbums(
  List<Capsule> capsules,
  Map<String, String> childMap,
) {
  // Group by emotion across all children
  final grouped = <Emotion, List<Capsule>>{};
  for (final c in capsules) {
    grouped.putIfAbsent(c.emotion, () => []);
    grouped[c.emotion]!.add(c);
  }

  final albums = <AlbumSuggestion>[];
  for (final entry in grouped.entries) {
    final items = entry.value;
    if (items.length < 3) continue; // min 3 capsules for emotion album

    final emotion = entry.key;
    albums.add(
      AlbumSuggestion(
        id: 'emotion_${emotion.name}',
        title: 'Moments de ${emotion.labelFr.toLowerCase()}',
        subtitle: '${items.length} capsules',
        type: AlbumType.emotion,
        capsules: items..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        icon: emotion.icon,
        accentColor: _emotionColors[emotion] ?? const Color(0xFF1E88E5),
      ),
    );
  }

  // Sort by capsule count descending
  albums.sort((a, b) => b.count.compareTo(a.count));
  return albums;
}

AlbumSuggestion? _generateFavoritesAlbum(List<Capsule> capsules) {
  final favorites = capsules.where((c) => c.isFavorite).toList();
  if (favorites.isEmpty) return null;

  return AlbumSuggestion(
    id: 'favorites',
    title: 'Mes Favoris',
    subtitle: '${favorites.length} souvenirs',
    type: AlbumType.favorites,
    capsules: favorites..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    icon: AlbumType.favorites.icon,
    accentColor: const Color(0xFFE91E63),
  );
}

List<AlbumSuggestion> _generateFirstMomentsAlbums(
  List<Capsule> capsules,
  Map<String, String> childMap,
) {
  // Group by child, take first 5
  final grouped = <String, List<Capsule>>{};
  for (final c in capsules) {
    grouped.putIfAbsent(c.childId, () => []);
    grouped[c.childId]!.add(c);
  }

  final albums = <AlbumSuggestion>[];
  for (final entry in grouped.entries) {
    final items = entry.value
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (items.isEmpty) continue;

    final firstFive = items.take(5).toList();
    final childName = childMap[entry.key] ?? 'Enfant';

    albums.add(
      AlbumSuggestion(
        id: 'first_moments_${entry.key}',
        title: 'Premiers moments',
        subtitle: '$childName · ${firstFive.length} souvenirs',
        type: AlbumType.firstMoments,
        childId: entry.key,
        childName: childName,
        capsules: firstFive,
        icon: AlbumType.firstMoments.icon,
        accentColor: const Color(0xFFFF6F00),
      ),
    );
  }

  return albums;
}

List<AlbumSuggestion> _generateAllMemoriesAlbums(
  List<Capsule> capsules,
  Map<String, String> childMap,
) {
  final grouped = <String, List<Capsule>>{};
  for (final c in capsules) {
    grouped.putIfAbsent(c.childId, () => []);
    grouped[c.childId]!.add(c);
  }

  return grouped.entries.map((entry) {
    final childName = childMap[entry.key] ?? 'Enfant';
    final items = entry.value
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return AlbumSuggestion(
      id: 'all_${entry.key}',
      title: 'Tous les souvenirs',
      subtitle: '$childName · ${items.length} capsules',
      type: AlbumType.allMemories,
      childId: entry.key,
      childName: childName,
      capsules: items,
      icon: AlbumType.allMemories.icon,
      accentColor: const Color(0xFF1565C0),
    );
  }).toList();
}
