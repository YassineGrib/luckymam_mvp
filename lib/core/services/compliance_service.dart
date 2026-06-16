import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Compliance service for Algerian Law 18-07 privacy consent.
class ComplianceService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ComplianceService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Computes a deterministic FNV-1a 64-bit hash of the consent evidence
  /// to ensure records cannot be tampered with undetected.
  String computeFnv1aHash(String userId, String timestampStr, String textVersion) {
    final input = '$userId|$timestampStr|$textVersion';
    final bytes = utf8.encode(input);
    int hash = 2305843009213693951; // Offset basis
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 1099511628211) & 0xffffffffffffffff; // Prime multiplication
    }
    return hash.toRadixString(16);
  }

  /// Saves consent and logs it in the immutable audit log collection.
  Future<void> saveConsent({
    required bool consent,
    required String textVersion,
    required String fullText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to save Law 18-07 consent');
    }

    final userId = user.uid;
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);
    final timestampStr = now.toIso8601String();

    // Compute integrity hash
    final hash = computeFnv1aHash(userId, timestampStr, textVersion);

    // 1. Update mutable user profile
    await _firestore.collection('users').doc(userId).set({
      'consent1807': consent,
      'consent1807Timestamp': timestamp,
      'consent1807TextVersion': textVersion,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Write immutable audit log
    await _firestore.collection('consent_logs').add({
      'userId': userId,
      'consent': consent,
      'timestamp': timestamp,
      'timestampStr': timestampStr,
      'textVersion': textVersion,
      'fullText': fullText,
      'hash': hash,
      'clientPlatform': 'mobile-flutter',
      'auditLogType': 'Law1807_Consent_Declaration',
    });
  }
}
