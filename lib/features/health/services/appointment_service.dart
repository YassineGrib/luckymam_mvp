import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/appointment.dart';

/// Firestore + Storage CRUD for Appointment documents.
///
/// Firestore: users/{uid}/children/{childId}/appointments/{apptId}
/// Storage:   users/{uid}/children/{childId}/appointments/{apptId}/{filename}
class AppointmentService {
  AppointmentService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _collection(String childId) => _db
      .collection('users')
      .doc(_uid)
      .collection('children')
      .doc(childId)
      .collection('appointments');

  // ─── Streams ─────────────────────────────────────────────────────────────

  Stream<List<Appointment>> watchAppointments(String childId) =>
      _collection(childId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(Appointment.fromFirestore).toList());

  // ─── Write ───────────────────────────────────────────────────────────────

  Future<Appointment> addAppointment({
    required String childId,
    required DateTime date,
    required String doctorName,
    required AppointmentType type,
    String? notes,
    List<File> files = const [],
  }) async {
    final ref = _collection(childId).doc();

    // Upload files first
    final urls = <String>[];
    for (final file in files) {
      final url = await _uploadFile(
        childId: childId,
        apptId: ref.id,
        file: file,
      );
      urls.add(url);
    }

    final appt = Appointment(
      id: ref.id,
      childId: childId,
      date: date,
      doctorName: doctorName,
      type: type,
      notes: notes,
      fileUrls: urls,
      createdAt: DateTime.now(),
    );

    await ref.set(appt.toFirestore());
    debugPrint('[Appointment] added ${ref.id} for child $childId');
    return appt;
  }

  Future<void> deleteAppointment({
    required String childId,
    required Appointment appointment,
  }) async {
    // Delete files from Storage
    for (final url in appointment.fileUrls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (e) {
        debugPrint('[Appointment] failed to delete file: $e');
      }
    }
    await _collection(childId).doc(appointment.id).delete();
    debugPrint('[Appointment] deleted ${appointment.id}');
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<String> _uploadFile({
    required String childId,
    required String apptId,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final filename = '${_uuid.v4()}.$ext';
    final ref = _storage.ref(
      'users/$_uid/children/$childId/appointments/$apptId/$filename',
    );
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
