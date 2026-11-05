import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for logging analytical events to Firestore.
class AnalyticsService {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  AnalyticsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  FirebaseFirestore get _firestore => _customFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

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

  /// LM-CROSS-003: Log technical non-sensitive error events for traceability.
  /// Complies strictly with Algerian privacy law 18-07:
  /// NEVER logs photos, audio bytes, phone numbers, or raw personal data.
  Future<void> logTechnicalError({
    required String errorType,
    required String step,
    String? errorCode,
    String? rawMessage,
    String? profileId,
    String? childId,
    String? entityId,
    Map<String, dynamic>? extraContext,
  }) async {
    final sanitizedMessage = _sanitizeErrorMessage(rawMessage);
    final params = <String, dynamic>{
      'errorType': errorType,
      'step': step,
      'platform': defaultTargetPlatform.name,
      if (errorCode != null) 'errorCode': errorCode,
      if (sanitizedMessage != null) 'message': sanitizedMessage,
      if (profileId != null) 'profileId': profileId,
      if (childId != null) 'childId': childId,
      if (entityId != null) 'entityId': entityId,
      if (extraContext != null) 'context': extraContext,
    };

    debugPrint('Technical Error Trace: $errorType at $step | $params');
    await logEvent('technical_error', parameters: params);
  }

  /// Strips potential email addresses, phone numbers, and URLs to preserve privacy.
  String? _sanitizeErrorMessage(String? message) {
    if (message == null) return null;
    return message
        .replaceAll(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), '[REDACTED_EMAIL]')
        .replaceAll(RegExp(r'https?://\S+'), '[REDACTED_URL]')
        .replaceAll(RegExp(r'0[5-7][0-9]{8}'), '[REDACTED_PHONE]');
  }
}
