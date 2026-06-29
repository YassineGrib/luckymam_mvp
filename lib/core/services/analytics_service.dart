import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for logging analytical events to Firestore.
class AnalyticsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AnalyticsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Log a custom analytics event.
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    final user = _auth.currentUser;
    final timestamp = FieldValue.serverTimestamp();

    debugPrint('Analytics Event: $eventName | User: ${user?.uid ?? 'anonymous'} | Params: $parameters');

    // Only write to Firestore when the user is authenticated to avoid permission errors
    if (user == null) return;

    try {
      await _firestore.collection('analytics_logs').add({
        'userId': user.uid,
        'eventName': eventName,
        'parameters': parameters ?? {},
        'timestamp': timestamp,
      });
    } catch (e) {
      debugPrint('Error writing analytics event to Firestore: $e');
    }
  }

  /// Event: Splash screen shown.
  Future<void> logSplashShown() async {
    await logEvent('splash_shown');
  }

  /// Event: User selected a profile status.
  Future<void> logStatusSelected(String status) async {
    await logEvent('status_selected', parameters: {'status': status});
  }

  /// Event: Law 18-07 consent screen viewed.
  Future<void> logLaw1807Viewed() async {
    await logEvent('law1807_viewed');
  }

  /// Event: Law 18-07 consent accepted.
  Future<void> logLaw1807Accepted() async {
    await logEvent('law1807_accepted');
  }

  /// Event: User blocked from continuing due to not accepting the law.
  Future<void> logLaw1807Blocked() async {
    await logEvent('law1807_blocked');
  }
}
