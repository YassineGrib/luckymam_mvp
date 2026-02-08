import 'package:cloud_firestore/cloud_firestore.dart';

import 'emotion.dart';

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
    );
  }
}
