import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/vaccine.dart';
import '../models/vaccine_status.dart';

/// Service for loading vaccine data and managing vaccination status.
class VaccineService {
  VaccineService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VaccineCalendar? _cachedCalendar;

  /// Load the vaccine calendar from JSON asset.
  Future<VaccineCalendar> loadVaccineCalendar() async {
    if (_cachedCalendar != null) return _cachedCalendar!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/vaccines_dz.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      _cachedCalendar = VaccineCalendar.fromJson(jsonData);
      return _cachedCalendar!;
    } catch (e) {
      debugPrint('Error loading vaccine calendar: $e');
      rethrow;
    }
  }

  /// Get the Firestore collection for a child's vaccinations.
  CollectionReference<Map<String, dynamic>>? _vaccinationsCollection(
    String childId,
  ) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('children')
        .doc(childId)
        .collection('vaccinations');
  }

  /// Stream all vaccination statuses for a child.
  Stream<List<VaccineStatus>> watchVaccinationStatuses(String childId) {
    final collection = _vaccinationsCollection(childId);
    if (collection == null) {
      return Stream.value([]);
    }

    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => VaccineStatus.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get all vaccination statuses for a child (one-time fetch).
  Future<List<VaccineStatus>> getVaccinationStatuses(String childId) async {
    final collection = _vaccinationsCollection(childId);
    if (collection == null) return [];

    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => VaccineStatus.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Mark a vaccine group as completed for a child.
  Future<void> markVaccineCompleted({
    required String childId,
    required String vaccineGroupId,
    required DateTime completedAt,
    String? notes,
  }) async {
    final collection = _vaccinationsCollection(childId);
    if (collection == null) throw Exception('User not authenticated');

    final status = VaccineStatus(
      vaccineGroupId: vaccineGroupId,
      completedAt: completedAt,
      notes: notes,
    );

    await collection.doc(vaccineGroupId).set(status.toFirestore());
  }

  /// Remove completion status for a vaccine group.
  Future<void> markVaccineIncomplete({
    required String childId,
    required String vaccineGroupId,
  }) async {
    final collection = _vaccinationsCollection(childId);
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(vaccineGroupId).delete();
  }

  /// Update notes for a completed vaccine.
  Future<void> updateVaccineNotes({
    required String childId,
    required String vaccineGroupId,
    required String notes,
  }) async {
    final collection = _vaccinationsCollection(childId);
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(vaccineGroupId).update({'notes': notes});
  }
}
