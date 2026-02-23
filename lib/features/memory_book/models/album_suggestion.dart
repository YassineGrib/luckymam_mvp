import 'package:flutter/material.dart';

import '../../capsules/models/capsule.dart';

/// Types of auto-generated album suggestions.
enum AlbumType {
  monthly,
  emotion,
  favorites,
  firstMoments,
  allMemories;

  String get labelFr {
    switch (this) {
      case AlbumType.monthly:
        return 'Mensuel';
      case AlbumType.emotion:
        return 'Émotion';
      case AlbumType.favorites:
        return 'Favoris';
      case AlbumType.firstMoments:
        return 'Premiers moments';
      case AlbumType.allMemories:
        return 'Tous les souvenirs';
    }
  }

  IconData get icon {
    switch (this) {
      case AlbumType.monthly:
        return Icons.calendar_month_rounded;
      case AlbumType.emotion:
        return Icons.mood_rounded;
      case AlbumType.favorites:
        return Icons.favorite_rounded;
      case AlbumType.firstMoments:
        return Icons.auto_awesome_rounded;
      case AlbumType.allMemories:
        return Icons.photo_library_rounded;
    }
  }
}

/// Represents a suggested album auto-generated from existing capsules.
class AlbumSuggestion {
  final String id;
  final String title;
  final String subtitle;
  final AlbumType type;
  final String? childId;
  final String? childName;
  final List<Capsule> capsules;
  final IconData icon;
  final Color accentColor;

  const AlbumSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.childId,
    this.childName,
    required this.capsules,
    required this.icon,
    required this.accentColor,
  });

  /// Cover photo URL from the first capsule.
  String? get coverUrl => capsules.isNotEmpty ? capsules.first.photoUrl : null;

  /// Number of capsules in this album.
  int get count => capsules.length;

  /// Whether album has audio capsules.
  bool get hasAudio => capsules.any((c) => c.hasAudio);
}
