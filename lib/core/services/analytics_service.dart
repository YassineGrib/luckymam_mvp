import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'safe_log.dart';

/// Service for logging analytical events to Firestore.
class AnalyticsService {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  AnalyticsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _customFirestore = firestore,
      _customAuth = auth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  /// Log a custom analytics event.
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    final user = _auth.currentUser;
    final timestamp = FieldValue.serverTimestamp();

    final safeParameters = Map<String, dynamic>.from(
      SafeLog.sanitize(parameters ?? {}) as Map,
    );
    safeDebugPrint('Analytics Event: $eventName | Params: $safeParameters');

    // Only write to Firestore when the user is authenticated to avoid permission errors
    if (user == null) return;

    try {
      await _firestore.collection('analytics_logs').add({
        'userId': user.uid,
        'eventName': eventName,
        'parameters': safeParameters,
        'timestamp': timestamp,
      });
    } catch (e) {
      safeDebugPrint('Analytics write failed: ${e.runtimeType}');
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
  /// Redacts potentially identifying diagnostic data before persistence.
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
    final params = technicalErrorParameters(
      errorType: errorType,
      step: step,
      errorCode: errorCode,
      rawMessage: rawMessage,
      extraContext: extraContext,
    );

    safeDebugPrint('Technical Error Trace: ${SafeLog.sanitize(params)}');
    await logEvent('technical_error', parameters: params);
  }

  /// Pure diagnostic boundary, also used by console and Firestore logging.
  static Map<String, dynamic> technicalErrorParameters({
    required String errorType,
    required String step,
    String? errorCode,
    String? rawMessage,
    Map<String, dynamic>? extraContext,
  }) => Map<String, dynamic>.from(
    SafeLog.sanitize({
          'errorType': errorType,
          'step': step,
          'platform': defaultTargetPlatform.name,
          if (errorCode != null) 'errorCode': errorCode,
          if (extraContext != null) 'context': extraContext,
        })
        as Map,
  );
}
