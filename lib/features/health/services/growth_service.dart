import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/growth_entry.dart';

/// Firestore CRUD for GrowthEntry documents.
///
/// Path: users/{uid}/children/{childId}/growth/{entryId}
class GrowthService {
  GrowthService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _collection(String childId) => _db
      .collection('users')
      .doc(_uid)
      .collection('children')
      .doc(childId)
      .collection('growth');

  // ─── Streams ─────────────────────────────────────────────────────────────

  Stream<List<GrowthEntry>> watchEntries(String childId) => _collection(childId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(GrowthEntry.fromFirestore).toList());

  // ─── Write ───────────────────────────────────────────────────────────────

  Future<GrowthEntry> addEntry({
    required String childId,
    required DateTime date,
    double? weightKg,
    double? heightCm,
    String? notes,
  }) async {
    final ref = _collection(childId).doc();
    final entry = GrowthEntry(
      id: ref.id,
      childId: childId,
      date: date,
      weightKg: weightKg,
      heightCm: heightCm,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await ref.set(entry.toFirestore());
    debugPrint('[Growth] added entry ${ref.id} for child $childId');
    return entry;
  }

  Future<void> deleteEntry({
    required String childId,
    required String entryId,
  }) async {
    await _collection(childId).doc(entryId).delete();
    debugPrint('[Growth] deleted entry $entryId');
  }
}
