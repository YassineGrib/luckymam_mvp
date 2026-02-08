import 'package:flutter/material.dart';

/// Emotion types for capsule memories.
enum Emotion {
  happy,
  love,
  tender,
  sad,
  surprised,
  sleepy,
  proud,
  worried;

  /// Get emoji for this emotion.
  String get emoji {
    switch (this) {
      case Emotion.happy:
        return '😊';
      case Emotion.love:
        return '❤️';
      case Emotion.tender:
        return '🥰';
      case Emotion.sad:
        return '😢';
      case Emotion.surprised:
        return '😯';
      case Emotion.sleepy:
        return '😴';
      case Emotion.proud:
        return '🤩';
      case Emotion.worried:
        return '😟';
    }
  }

  /// Get icon for this emotion.
  IconData get icon {
    switch (this) {
      case Emotion.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case Emotion.love:
        return Icons.favorite_rounded;
      case Emotion.tender:
        return Icons.volunteer_activism_rounded;
      case Emotion.sad:
        return Icons.sentiment_dissatisfied_rounded;
      case Emotion.surprised:
        return Icons.sentiment_neutral_rounded;
      case Emotion.sleepy:
        return Icons.bedtime_rounded;
      case Emotion.proud:
        return Icons.celebration_rounded;
      case Emotion.worried:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  /// Get French label for this emotion.
  String get labelFr {
    switch (this) {
      case Emotion.happy:
        return 'Heureux';
      case Emotion.love:
        return 'Amour';
      case Emotion.tender:
        return 'Tendresse';
      case Emotion.sad:
        return 'Triste';
      case Emotion.surprised:
        return 'Surpris';
      case Emotion.sleepy:
        return 'Fatigué';
      case Emotion.proud:
        return 'Fier';
      case Emotion.worried:
        return 'Inquiet';
    }
  }

  /// Get Arabic label for this emotion.
  String get labelAr {
    switch (this) {
      case Emotion.happy:
        return 'سعيد';
      case Emotion.love:
        return 'حب';
      case Emotion.tender:
        return 'حنان';
      case Emotion.sad:
        return 'حزين';
      case Emotion.surprised:
        return 'مندهش';
      case Emotion.sleepy:
        return 'نعسان';
      case Emotion.proud:
        return 'فخور';
      case Emotion.worried:
        return 'قلق';
    }
  }

  /// Parse from string with fallback.
  static Emotion fromString(String? value) {
    if (value == null) return Emotion.happy;
    return Emotion.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Emotion.happy,
    );
  }
}
