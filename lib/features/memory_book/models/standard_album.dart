import 'package:cloud_firestore/cloud_firestore.dart';

/// A free-form album: blank numbered pages the mother fills at her own pace,
/// as opposed to [PredefinedAlbum] which has fixed named life events.
class StandardAlbum {
  final String id;
  final String userId;
  final String childId;
  final String title;
  final int pageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Maps page index (as string, e.g. "0") -> capsule id for filled pages.
  final Map<String, String> pageCapsules;

  static const int defaultPageCount = 6;

  const StandardAlbum({
    required this.id,
    required this.userId,
    required this.childId,
    required this.title,
    required this.pageCount,
    required this.createdAt,
    required this.updatedAt,
    this.pageCapsules = const {},
  });

  factory StandardAlbum.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StandardAlbum(
      id: doc.id,
      userId: data['userId'] ?? '',
      childId: data['childId'] ?? '',
      title: data['title'] ?? 'Album',
      pageCount: data['pageCount'] ?? defaultPageCount,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      pageCapsules: Map<String, String>.from(data['pageCapsules'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'childId': childId,
      'title': title,
      'pageCount': pageCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'pageCapsules': pageCapsules,
    };
  }

  int get filledCount => pageCapsules.length;

  bool isPageFilled(int index) => pageCapsules.containsKey('$index');

  /// Cover photo capsule id — the first filled page, if any.
  String? get coverCapsuleId {
    for (var i = 0; i < pageCount; i++) {
      final id = pageCapsules['$i'];
      if (id != null) return id;
    }
    return null;
  }
}
