import 'package:cloud_firestore/cloud_firestore.dart';

import 'emotion.dart';

/// Life phase category for a capsule.
enum CapsuleCategory {
  preGestation,
  gestation,
  postPartum,
  enfance,
  adulte;

  String get labelFr {
    switch (this) {
      case CapsuleCategory.preGestation:
        return 'Pré-gestation';
      case CapsuleCategory.gestation:
        return 'Gestation';
      case CapsuleCategory.postPartum:
        return 'Post-partum';
      case CapsuleCategory.enfance:
        return 'Enfance';
      case CapsuleCategory.adulte:
        return 'Adulte';
    }
  }

  String get emoji {
    switch (this) {
      case CapsuleCategory.preGestation:
        return '🌱';
      case CapsuleCategory.gestation:
        return '🤰';
      case CapsuleCategory.postPartum:
        return '👶';
      case CapsuleCategory.enfance:
        return '🧒';
      case CapsuleCategory.adulte:
        return '🌟';
    }
  }

  static CapsuleCategory? fromString(String? value) {
    if (value == null) return null;
    return CapsuleCategory.values.where((e) => e.name == value).firstOrNull;
  }
}

/// Capsule model - a memory capture with photo, audio, and emotion.
class Capsule {
  final String id;
  final String userId;
  final String childId;
  final String? milestoneId;
  final String photoUrl;
  final String? audioUrl;
  final int? audioDuration; // seconds
  final Emotion emotion;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Actual date the photo/moment was captured (may differ from createdAt).
  final DateTime? capturedAt;

  /// Life phase category of this memory.
  final CapsuleCategory? category;

  const Capsule({
    required this.id,
    required this.userId,
    required this.childId,
    this.milestoneId,
    required this.photoUrl,
    this.audioUrl,
    this.audioDuration,
    required this.emotion,
    this.tags = const [],
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.capturedAt,
    this.category,
  });

  /// Create from Firestore document.
  factory Capsule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Capsule(
      id: doc.id,
      userId: data['userId'] ?? '',
      childId: data['childId'] ?? '',
      milestoneId: data['milestoneId'],
      photoUrl: data['photoUrl'] ?? '',
      audioUrl: data['audioUrl'],
      audioDuration: data['audioDuration'],
      emotion: Emotion.fromString(data['emotion']),
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      capturedAt: data['capturedAt'] != null
          ? (data['capturedAt'] as Timestamp).toDate()
          : null,
      category: CapsuleCategory.fromString(data['category'] as String?),
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'childId': childId,
      'milestoneId': milestoneId,
      'photoUrl': photoUrl,
      'audioUrl': audioUrl,
      'audioDuration': audioDuration,
      'emotion': emotion.name,
      'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'capturedAt': capturedAt != null ? Timestamp.fromDate(capturedAt!) : null,
      'category': category?.name,
    };
  }

  /// Check if capsule has audio.
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// Get formatted duration string.
  String get durationString {
    if (audioDuration == null) return '';
    final minutes = audioDuration! ~/ 60;
    final seconds = audioDuration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Capsule copyWith({
    String? id,
    String? userId,
    String? childId,
    String? milestoneId,
    String? photoUrl,
    String? audioUrl,
    int? audioDuration,
    Emotion? emotion,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? capturedAt,
    CapsuleCategory? category,
    bool clearCapturedAt = false,
    bool clearCategory = false,
  }) {
    return Capsule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childId: childId ?? this.childId,
      milestoneId: milestoneId ?? this.milestoneId,
      photoUrl: photoUrl ?? this.photoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      emotion: emotion ?? this.emotion,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      capturedAt: clearCapturedAt ? null : (capturedAt ?? this.capturedAt),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}
