import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/predefined_album.dart';

/// Service for predefined-album CRUD and event-slot management.
class PredefinedAlbumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _albumsRef {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('predefinedAlbums');
  }

  /// Watch all predefined albums for a specific child.
  Stream<List<PredefinedAlbum>> watchAlbumsForChild(String childId) {
    if (_userId == null) return Stream.value([]);
    return _albumsRef
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(PredefinedAlbum.fromFirestore).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  /// Watch a single predefined album by id.
  Stream<PredefinedAlbum?> watchAlbum(String albumId) {
    return _albumsRef
        .doc(albumId)
        .snapshots()
        .map((doc) => doc.exists ? PredefinedAlbum.fromFirestore(doc) : null);
  }

  /// Create a new album instance from a template for a given child.
  Future<PredefinedAlbum> createAlbum({
    required String childId,
    required String templateId,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final docRef = _albumsRef.doc();
    final album = PredefinedAlbum(
      id: docRef.id,
      userId: _userId!,
      childId: childId,
      templateId: templateId,
      createdAt: DateTime.now(),
    );
    await docRef.set(album.toFirestore());
    return album;
  }

  /// Attach a capsule to an event slot.
  Future<void> attachCapsuleToSlot({
    required String albumId,
    required String slotId,
    required String capsuleId,
  }) async {
    await _albumsRef.doc(albumId).update({
      'slotCapsules.$slotId': capsuleId,
    });
  }

  /// Remove a capsule from an event slot.
  Future<void> clearSlot({
    required String albumId,
    required String slotId,
  }) async {
    await _albumsRef.doc(albumId).update({
      'slotCapsules.$slotId': FieldValue.delete(),
    });
  }

  /// Delete an entire predefined album.
  Future<void> deleteAlbum(String albumId) async {
    await _albumsRef.doc(albumId).delete();
  }
}
