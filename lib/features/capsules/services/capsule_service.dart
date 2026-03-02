import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/capsule.dart';
import '../models/emotion.dart';

/// Service for capsule CRUD operations and media upload.
class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  /// Get current user ID.
  String? get _userId => _auth.currentUser?.uid;

  /// Get capsules collection reference for current user.
  CollectionReference<Map<String, dynamic>> get _capsulesRef {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('capsules');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Watch all capsules for current user.
  Stream<List<Capsule>> watchCapsules() {
    if (_userId == null) return Stream.value([]);
    return _capsulesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Capsule.fromFirestore(doc)).toList(),
        );
  }

  /// Watch capsules for a specific child.
  Stream<List<Capsule>> watchCapsulesForChild(String childId) {
    if (_userId == null) return Stream.value([]);
    return _capsulesRef
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Capsule.fromFirestore(doc)).toList(),
        );
  }

  /// Get capsules count for quota check.
  Future<int> getCapsuleCount() async {
    if (_userId == null) return 0;
    final snapshot = await _capsulesRef.count().get();
    return snapshot.count ?? 0;
  }

  /// Create a new capsule with media upload.
  Future<Capsule> createCapsule({
    required String childId,
    required File photoFile,
    File? audioFile,
    int? audioDuration,
    required Emotion emotion,
    String? milestoneId,
    List<String> tags = const [],
    DateTime? capturedAt,
    CapsuleCategory? category,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final capsuleId = _uuid.v4();
    final now = DateTime.now();

    // Upload photo
    final photoUrl = await _uploadMedia(
      file: photoFile,
      capsuleId: capsuleId,
      type: 'photo',
    );

    // Upload audio if provided
    String? audioUrl;
    if (audioFile != null) {
      audioUrl = await _uploadMedia(
        file: audioFile,
        capsuleId: capsuleId,
        type: 'audio',
      );
    }

    // Create capsule document
    final capsule = Capsule(
      id: capsuleId,
      userId: _userId!,
      childId: childId,
      milestoneId: milestoneId,
      photoUrl: photoUrl,
      audioUrl: audioUrl,
      audioDuration: audioDuration,
      emotion: emotion,
      tags: tags,
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      capturedAt: capturedAt,
      category: category,
    );

    await _capsulesRef.doc(capsuleId).set(capsule.toFirestore());
    return capsule;
  }

  /// Toggle favorite status.
  Future<void> toggleFavorite(String capsuleId) async {
    final doc = await _capsulesRef.doc(capsuleId).get();
    if (!doc.exists) return;

    final current = doc.data()?['isFavorite'] ?? false;
    await _capsulesRef.doc(capsuleId).update({
      'isFavorite': !current,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a capsule and its media.
  Future<void> deleteCapsule(Capsule capsule) async {
    if (_userId == null) throw Exception('User not authenticated');

    // Delete media from storage
    await _deleteMedia(capsule.photoUrl);
    if (capsule.audioUrl != null) {
      await _deleteMedia(capsule.audioUrl!);
    }

    // Delete document
    await _capsulesRef.doc(capsule.id).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIA OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Upload media file to Firebase Storage.
  Future<String> _uploadMedia({
    required File file,
    required String capsuleId,
    required String type,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final extension = type == 'photo' ? 'jpg' : 'm4a';
    final path = 'users/$_userId/capsules/$capsuleId/$type.$extension';
    final ref = _storage.ref(path);

    final metadata = SettableMetadata(
      contentType: type == 'photo' ? 'image/jpeg' : 'audio/m4a',
    );

    final uploadTask = ref.putFile(file, metadata);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete media from Firebase Storage.
  Future<void> _deleteMedia(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore if already deleted
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FILTERING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get capsules with filters.
  Stream<List<Capsule>> watchFilteredCapsules({
    String? childId,
    Emotion? emotion,
    bool? favoritesOnly,
  }) {
    if (_userId == null) return Stream.value([]);

    // Start with base query - just orderBy (no where clause)
    // If no filters, use simple ordered query
    if (childId == null && emotion == null && favoritesOnly != true) {
      return _capsulesRef
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Capsule.fromFirestore(doc)).toList(),
          );
    }

    // For filtered queries, fetch all and filter client-side
    // This avoids composite index requirements
    return _capsulesRef.snapshots().map((snapshot) {
      var capsules = snapshot.docs
          .map((doc) => Capsule.fromFirestore(doc))
          .toList();

      // Apply filters
      if (childId != null) {
        capsules = capsules.where((c) => c.childId == childId).toList();
      }

      if (emotion != null) {
        capsules = capsules.where((c) => c.emotion == emotion).toList();
      }

      if (favoritesOnly == true) {
        capsules = capsules.where((c) => c.isFavorite).toList();
      }

      // Sort by createdAt descending
      capsules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return capsules;
    });
  }
}
