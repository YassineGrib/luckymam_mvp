import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'emotion.dart';

/// Life phase category for a capsule.
enum CapsuleCategory {
  preGestation,
  gestation,
  postPartum,
  enfance,
  adulte;

  IconData get icon {
    switch (this) {
      case CapsuleCategory.preGestation:
        return Icons.eco_rounded;
      case CapsuleCategory.gestation:
        return Icons.pregnant_woman_rounded;
      case CapsuleCategory.postPartum:
        return Icons.child_friendly_rounded;
      case CapsuleCategory.enfance:
        return Icons.child_care_rounded;
      case CapsuleCategory.adulte:
        return Icons.auto_awesome_rounded;
    }
  }

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

  String get labelAr {
    switch (this) {
      case CapsuleCategory.preGestation:
        return 'ما قبل الحمل';
      case CapsuleCategory.gestation:
        return 'الحمل';
      case CapsuleCategory.postPartum:
        return 'ما بعد الولادة';
      case CapsuleCategory.enfance:
        return 'الطفولة';
      case CapsuleCategory.adulte:
        return 'البلوغ';
    }
  }

  String getLabel(String locale) {
    if (locale == 'ar') return labelAr;
    if (locale == 'en') {
      switch (this) {
        case CapsuleCategory.preGestation:
          return 'Pre-gestation';
        case CapsuleCategory.gestation:
          return 'Pregnancy';
        case CapsuleCategory.postPartum:
          return 'Postpartum';
        case CapsuleCategory.enfance:
          return 'Childhood';
        case CapsuleCategory.adulte:
          return 'Adulthood';
      }
    }
    return labelFr;
  }

  static CapsuleCategory? fromString(String? value) {
    if (value == null) return null;
    return CapsuleCategory.values.where((e) => e.name == value).firstOrNull;
  }
}

/// Target space of a capsule determining where it is surfaced.
enum CapsuleSpace {
  child,
  mother,
  family;
}

/// Derives the target space for a capsule based on its subjects and pregnancy context.
///
/// Rule order:
/// 1. Pregnancy bump photo with mother and single expected child => [CapsuleSpace.mother]
/// 2. Two or more children featured together => [CapsuleSpace.family]
/// 3. Mother with at least one child => [CapsuleSpace.family]
/// 4. Mother alone => [CapsuleSpace.mother]
/// 5. Else => [CapsuleSpace.child]
CapsuleSpace deriveCapsuleSpace({
  required List<String> childIds,
  required bool withMother,
  String? pregnancyId,
}) {
  if (pregnancyId != null && withMother && childIds.length == 1) {
    return CapsuleSpace.mother;
  }
  if (childIds.length >= 2) {
    return CapsuleSpace.family;
  }
  if (withMother && childIds.isNotEmpty) {
    return CapsuleSpace.family;
  }
  if (withMother) {
    return CapsuleSpace.mother;
  }
  return CapsuleSpace.child;
}

/// Capsule model - a memory capture with photo, audio, and emotion.
class Capsule {
  final String id;
  final String userId;

  /// Legacy single child ID (kept non-null for backward compatibility).
  final String childId;

  /// Internal backing list for multi-child capsules.
  final List<String> _childIds;

  /// Whether the mother is featured in this memory.
  final bool withMother;

  /// Optional link to an active pregnancy journal entry.
  final String? pregnancyId;

  /// Pregnancy week number at the time this capsule was captured.
  final int? pregnancyWeek;

  final String? milestoneId;
  final String? vaccineGroupId;
  final String? albumId;
  final String? albumSlotId;

  /// 'predefined' | 'standard' — which album collection [albumId] refers to.
  final String? albumType;
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
    List<String> childIds = const [],
    this.withMother = false,
    this.pregnancyId,
    this.pregnancyWeek,
    this.milestoneId,
    this.vaccineGroupId,
    this.albumId,
    this.albumSlotId,
    this.albumType,
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
  }) : _childIds = childIds;

  /// Effective list of children featured in this memory.
  ///
  /// Backfills from [childId] when [childIds] is empty.
  List<String> get childIds =>
      _childIds.isNotEmpty ? _childIds : (childId.isNotEmpty ? [childId] : const []);

  /// Target space of this capsule derived from its subjects.
  CapsuleSpace get space => deriveCapsuleSpace(
        childIds: childIds,
        withMother: withMother,
        pregnancyId: pregnancyId,
      );

  /// Create from map and document ID.
  static Capsule fromMap(Map<String, dynamic> data, [String id = '']) {
    final rawChildIds = data['childIds'];
    final rawChildId = data['childId'] as String? ?? '';
    final List<String> childIds;
    if (rawChildIds is List) {
      childIds = List<String>.from(rawChildIds.map((e) => e.toString()));
    } else if (rawChildId.isNotEmpty) {
      childIds = [rawChildId];
    } else {
      childIds = const [];
    }
    final effectiveChildId =
        rawChildId.isNotEmpty ? rawChildId : (childIds.isNotEmpty ? childIds.first : '');

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Capsule(
      id: id.isNotEmpty ? id : (data['id'] as String? ?? ''),
      userId: data['userId'] as String? ?? '',
      childId: effectiveChildId,
      childIds: childIds,
      withMother: data['withMother'] as bool? ?? false,
      pregnancyId: data['pregnancyId'] as String?,
      pregnancyWeek: (data['pregnancyWeek'] as num?)?.toInt(),
      milestoneId: data['milestoneId'] as String?,
      vaccineGroupId: data['vaccineGroupId'] as String?,
      albumId: data['albumId'] as String?,
      albumSlotId: data['albumSlotId'] as String?,
      albumType: data['albumType'] as String?,
      photoUrl: data['photoUrl'] as String? ?? '',
      audioUrl: data['audioUrl'] as String?,
      audioDuration: (data['audioDuration'] as num?)?.toInt(),
      emotion: Emotion.fromString(data['emotion'] as String?),
      tags: List<String>.from(data['tags'] as List? ?? const []),
      isFavorite: data['isFavorite'] as bool? ?? false,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      capturedAt: parseNullableDate(data['capturedAt']),
      category: CapsuleCategory.fromString(data['category'] as String?),
    );
  }

  /// Create from Firestore document.
  factory Capsule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Capsule.fromMap(data, doc.id);
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    final effectiveChildIds = childIds;
    return {
      'userId': userId,
      'childId': effectiveChildIds.isNotEmpty ? effectiveChildIds.first : childId,
      'childIds': effectiveChildIds,
      'withMother': withMother,
      'space': space.name,
      'pregnancyId': pregnancyId,
      'pregnancyWeek': pregnancyWeek,
      'milestoneId': milestoneId,
      'vaccineGroupId': vaccineGroupId,
      'albumId': albumId,
      'albumSlotId': albumSlotId,
      'albumType': albumType,
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
    List<String>? childIds,
    bool? withMother,
    String? pregnancyId,
    int? pregnancyWeek,
    String? milestoneId,
    String? vaccineGroupId,
    String? albumId,
    String? albumSlotId,
    String? albumType,
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
    bool clearPregnancyId = false,
    bool clearPregnancyWeek = false,
  }) {
    final resolvedChildIds = childIds ??
        (childId != null
            ? (childId.isNotEmpty ? [childId] : const <String>[])
            : _childIds);
    final resolvedChildId = childId ??
        (childIds != null && childIds.isNotEmpty ? childIds.first : this.childId);

    return Capsule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childId: resolvedChildId,
      childIds: resolvedChildIds,
      withMother: withMother ?? this.withMother,
      pregnancyId: clearPregnancyId ? null : (pregnancyId ?? this.pregnancyId),
      pregnancyWeek:
          clearPregnancyWeek ? null : (pregnancyWeek ?? this.pregnancyWeek),
      milestoneId: milestoneId ?? this.milestoneId,
      vaccineGroupId: vaccineGroupId ?? this.vaccineGroupId,
      albumId: albumId ?? this.albumId,
      albumSlotId: albumSlotId ?? this.albumSlotId,
      albumType: albumType ?? this.albumType,
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
