import 'package:cloud_firestore/cloud_firestore.dart';

/// A user's instantiated predefined album — a template applied to a
/// specific child, with each event slot optionally filled by a capsule.
class PredefinedAlbum {
  final String id;
  final String userId;
  final String childId;
  final String templateId;
  final DateTime createdAt;

  /// Maps slot id -> capsule id for filled slots.
  final Map<String, String> slotCapsules;

  const PredefinedAlbum({
    required this.id,
    required this.userId,
    required this.childId,
    required this.templateId,
    required this.createdAt,
    this.slotCapsules = const {},
  });

  factory PredefinedAlbum.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PredefinedAlbum(
      id: doc.id,
      userId: data['userId'] ?? '',
      childId: data['childId'] ?? '',
      templateId: data['templateId'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      slotCapsules: Map<String, String>.from(data['slotCapsules'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'childId': childId,
      'templateId': templateId,
      'createdAt': Timestamp.fromDate(createdAt),
      'slotCapsules': slotCapsules,
    };
  }

  int get filledCount => slotCapsules.length;

  bool isSlotFilled(String slotId) => slotCapsules.containsKey(slotId);

  PredefinedAlbum copyWith({Map<String, String>? slotCapsules}) {
    return PredefinedAlbum(
      id: id,
      userId: userId,
      childId: childId,
      templateId: templateId,
      createdAt: createdAt,
      slotCapsules: slotCapsules ?? this.slotCapsules,
    );
  }
}
