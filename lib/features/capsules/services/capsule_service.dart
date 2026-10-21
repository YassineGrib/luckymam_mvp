import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/analytics_service.dart';
import '../models/capsule.dart';
import '../models/emotion.dart';

/// Default schema version for capsule documents.
const int kCurrentCapsuleSchemaVersion = 2;

/// Resolves the effective child IDs from optional multi-child and legacy child parameters.
List<String> resolveEffectiveCapsuleChildIds({
  String? childId,
  List<String>? childIds,
}) {
  return childIds ??
      (childId != null && childId.isNotEmpty ? [childId] : <String>[]);
}

/// Validates that a capsule has at least one child or features the mother.
///
/// Throws [ArgumentError] if [childIds] is empty and [withMother] is false.
void validateCapsuleSubjects({
  required List<String> childIds,
  required bool withMother,
}) {
  if (childIds.isEmpty && !withMother) {
    throw ArgumentError('A capsule needs at least one child or the mother');
  }
}

/// Checks whether capsule schema needs migration.
bool needsCapsuleMigration(int? schemaVersion) {
  return (schemaVersion ?? 0) < kCurrentCapsuleSchemaVersion;
}

/// Computes the migration update payload for a raw capsule document map.
///
/// Returns null if the document already contains the `childIds` key.
/// Otherwise returns a map with `{childIds, withMother: false, space: 'child'}`
/// derived from the legacy `childId` field.
Map<String, dynamic>? computeCapsuleSubjectMigration(
    Map<dynamic, dynamic> rawData) {
  if (rawData.containsKey('childIds')) {
    return null;
  }
  final legacyChildId = rawData['childId'];
  final List<String> childIds;
  if (legacyChildId is String && legacyChildId.isNotEmpty) {
    childIds = [legacyChildId];
  } else {
    childIds = const <String>[];
  }
  return <String, dynamic>{
    'childIds': childIds,
    'withMother': false,
    'space': CapsuleSpace.child.name,
  };
}

/// Service for capsule CRUD operations and media upload.
class CapsuleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  final AnalyticsService _analytics = AnalyticsService();

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

  /// Private helper that reuses the ordered capsules stream and filters client-side.
  Stream<List<Capsule>> _watchWhere(bool Function(Capsule) test) {
    if (_userId == null) return Stream.value([]);
    return _capsulesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Capsule.fromFirestore(doc))
              .where(test)
              .toList(),
        );
  }

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
    return _watchWhere((c) => c.childIds.contains(childId));
  }

  /// Watch capsules where the mother is featured.
  Stream<List<Capsule>> watchMotherCapsules() {
    return _watchWhere((c) => c.withMother);
  }

  /// Watch capsules in the family space.
  Stream<List<Capsule>> watchFamilyCapsules() {
    return _watchWhere((c) => c.space == CapsuleSpace.family);
  }

  /// Get capsules count for quota check.
  Future<int> getCapsuleCount() async {
    if (_userId == null) return 0;
    final snapshot = await _capsulesRef.count().get();
    return snapshot.count ?? 0;
  }

  /// Create a new capsule with media upload.
  Future<Capsule> createCapsule({
    String? childId,
    List<String>? childIds,
    bool withMother = false,
    String? pregnancyId,
    int? pregnancyWeek,
    required File photoFile,
    File? audioFile,
    int? audioDuration,
    required Emotion emotion,
    String? milestoneId,
    String? vaccineGroupId,
    String? albumId,
    String? albumSlotId,
    String? albumType,
    List<String> tags = const [],
    DateTime? capturedAt,
    CapsuleCategory? category,
  }) async {
    final effectiveChildIds = resolveEffectiveCapsuleChildIds(
      childId: childId,
      childIds: childIds,
    );
    validateCapsuleSubjects(
      childIds: effectiveChildIds,
      withMother: withMother,
    );

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
      childId: effectiveChildIds.isNotEmpty ? effectiveChildIds.first : '',
      childIds: effectiveChildIds,
      withMother: withMother,
      pregnancyId: pregnancyId,
      pregnancyWeek: pregnancyWeek,
      milestoneId: milestoneId,
      vaccineGroupId: vaccineGroupId,
      albumId: albumId,
      albumSlotId: albumSlotId,
      albumType: albumType,
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

    // If tied to a vaccine group, update the vaccine status
    if (vaccineGroupId != null && effectiveChildIds.isNotEmpty) {
      final vaxChildId = effectiveChildIds.first;
      try {
        final vaccineStatusRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('children')
            .doc(vaxChildId)
            .collection('vaccinations')
            .doc(vaccineGroupId);

        final doc = await vaccineStatusRef.get();
        if (doc.exists) {
          final data = doc.data();
          final hasCompletedAt = data != null && data['completedAt'] != null;
          if (hasCompletedAt) {
            await vaccineStatusRef.update({
              'capsuleId': capsuleId,
            });
          } else {
            await vaccineStatusRef.update({
              'capsuleId': capsuleId,
              'completedAt': Timestamp.fromDate(now),
            });
          }
        } else {
          await vaccineStatusRef.set({
            'capsuleId': capsuleId,
            'completedAt': Timestamp.fromDate(now),
          });
        }
      } catch (e) {
        debugPrint('Error updating vaccine status with capsuleId: $e');
      }

      // Log analytical event for vaccine capsule creation
      await _analytics.logEvent(
        'vax_capsule_created',
        parameters: {
          'childId': vaxChildId,
          'vaccineGroupId': vaccineGroupId,
          'capsuleId': capsuleId,
        },
      );
    }

    // If tied to a predefined-album event slot, attach it
    if (albumId != null && albumSlotId != null && albumType == 'predefined') {
      try {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('predefinedAlbums')
            .doc(albumId)
            .update({'slotCapsules.$albumSlotId': capsuleId});

        await _analytics.logEvent(
          'album_event_slot_filled',
          parameters: {
            'albumId': albumId,
            'slotId': albumSlotId,
            'method': 'new',
          },
        );
      } catch (e) {
        debugPrint('Error attaching capsule to album slot: $e');
      }
    }

    // If tied to a standard-album page, attach it
    if (albumId != null && albumSlotId != null && albumType == 'standard') {
      try {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('standardAlbums')
            .doc(albumId)
            .update({
              'pageCapsules.$albumSlotId': capsuleId,
              'updatedAt': Timestamp.fromDate(now),
            });

        await _analytics.logEvent(
          'album_slot_added',
          parameters: {
            'albumId': albumId,
            'pageIndex': albumSlotId,
            'method': 'new',
          },
        );
      } catch (e) {
        debugPrint('Error attaching capsule to album page: $e');
      }
    }

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

  /// Migrates legacy capsules without `childIds` to the multi-subject schema.
  ///
  /// Reads `users/{uid}`. If `capsuleSchemaVersion >= 2`, returns 0 immediately.
  /// Otherwise, fetches all capsules for the user and for every doc lacking `childIds`,
  /// updates `{childIds, withMother: false, space: 'child'}` in batches of at most 450.
  /// After all batches succeed, sets `capsuleSchemaVersion: 2` on the user doc (merge).
  /// Returns the number of docs updated.
  Future<int> migrateCapsuleSubjects() async {
    final uid = _userId;
    if (uid == null) return 0;

    final userRef = _firestore.collection('users').doc(uid);
    final userDoc = await userRef.get();
    final userData = userDoc.data();
    final schemaVersion =
        (userData?['capsuleSchemaVersion'] as num?)?.toInt();
    if (!needsCapsuleMigration(schemaVersion)) {
      return 0;
    }

    final querySnapshot = await _capsulesRef.get();
    final docsToUpdate = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('childIds')) {
        docsToUpdate.add(doc);
      }
    }

    if (docsToUpdate.isEmpty) {
      await userRef.set(
        {'capsuleSchemaVersion': kCurrentCapsuleSchemaVersion},
        SetOptions(merge: true),
      );
      return 0;
    }

    const batchSize = 450;
    for (var i = 0; i < docsToUpdate.length; i += batchSize) {
      final end = (i + batchSize < docsToUpdate.length)
          ? i + batchSize
          : docsToUpdate.length;
      final chunk = docsToUpdate.sublist(i, end);
      final batch = _firestore.batch();
      for (final doc in chunk) {
        final update = computeCapsuleSubjectMigration(doc.data());
        if (update != null) {
          batch.update(doc.reference, update);
        }
      }
      await batch.commit();
    }

    await userRef.set(
      {'capsuleSchemaVersion': kCurrentCapsuleSchemaVersion},
      SetOptions(merge: true),
    );

    return docsToUpdate.length;
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
        capsules =
            capsules.where((c) => c.childIds.contains(childId)).toList();
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
