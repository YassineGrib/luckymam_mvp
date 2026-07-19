import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/standard_album.dart';

/// Service for standard (free-form) album CRUD and page management.
class StandardAlbumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _albumsRef {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('standardAlbums');
  }

  /// Watch all standard albums for a specific child.
  Stream<List<StandardAlbum>> watchAlbumsForChild(String childId) {
    if (_userId == null) return Stream.value([]);
    return _albumsRef
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(StandardAlbum.fromFirestore).toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
        );
  }

  /// Watch a single standard album by id.
  Stream<StandardAlbum?> watchAlbum(String albumId) {
    return _albumsRef
        .doc(albumId)
        .snapshots()
        .map((doc) => doc.exists ? StandardAlbum.fromFirestore(doc) : null);
  }

  /// Create a new blank album for a child.
  Future<StandardAlbum> createAlbum({
    required String childId,
    required String title,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final docRef = _albumsRef.doc();
    final now = DateTime.now();
    final album = StandardAlbum(
      id: docRef.id,
      userId: _userId!,
      childId: childId,
      title: title,
      pageCount: StandardAlbum.defaultPageCount,
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(album.toFirestore());
    return album;
  }

  /// Attach a capsule to a page.
  Future<void> addCapsuleToPage({
    required String albumId,
    required int pageIndex,
    required String capsuleId,
  }) async {
    await _albumsRef.doc(albumId).update({
      'pageCapsules.$pageIndex': capsuleId,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Remove a capsule from a page.
  Future<void> clearPage({
    required String albumId,
    required int pageIndex,
  }) async {
    await _albumsRef.doc(albumId).update({
      'pageCapsules.$pageIndex': FieldValue.delete(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Append one more blank page to the album.
  Future<void> addPage(String albumId) async {
    await _albumsRef.doc(albumId).update({
      'pageCount': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Rename the album.
  Future<void> updateTitle({
    required String albumId,
    required String title,
  }) async {
    await _albumsRef.doc(albumId).update({
      'title': title,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Delete an entire standard album.
  Future<void> deleteAlbum(String albumId) async {
    await _albumsRef.doc(albumId).delete();
  }
}
