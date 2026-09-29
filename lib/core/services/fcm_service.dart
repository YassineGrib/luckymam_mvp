import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/notifications/models/app_notification.dart';
import '../../features/notifications/providers/notifications_providers.dart';

/// Top-level background message handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Handling message: ${message.messageId} - ${message.notification?.title}');
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const String _defaultChannelId = 'luckymam_general_channel';
  static const String _defaultChannelName = 'تنبيهات لاكي مام';
  static const String _defaultChannelDesc =
      'تذكيرات اللقاحات، كبسولات الذكريات، وتحديثات طفلكِ الهامة';

  bool _isInitialized = false;

  /// Stream/notifier for notification tap payloads for deep linking
  static final ValueNotifier<Map<String, dynamic>?> onPushTapped =
      ValueNotifier<Map<String, dynamic>?>(null);

  /// Initializes FCM permissions, channels, token sync, and foreground/background listeners.
  Future<void> init() async {
    if (kIsWeb || _isInitialized) return;

    try {
      // 1. Request User Notification Permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      // 2. Set presentation options for foreground
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Create Android High Importance Channel
      final androidChannel = const AndroidNotificationChannel(
        _defaultChannelId,
        _defaultChannelName,
        description: _defaultChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // 4. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 5. Sync and save FCM Token
      await syncFcmToken();

      // 6. Listen for Token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM] Token refreshed: $newToken');
        _saveTokenToFirestore(newToken);
      });

      // 7. Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground] Received: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // 8. Notification opened app from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM Tap] App opened from message: ${message.data}');
        onPushTapped.value = message.data;
      });

      // 9. Notification opened app from terminated
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM Initial] App launched via message: ${initialMessage.data}');
        onPushTapped.value = initialMessage.data;
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('[FCM Init Error] $e');
    }
  }

  /// Retrieves and syncs current device FCM token with logged-in user in Firestore
  Future<String?> syncFcmToken() async {
    try {
      final token = await _fcm.getToken();
      debugPrint('[FCM] Current Device Token: $token');
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
      return token;
    } catch (e) {
      debugPrint('[FCM Token Sync Error] $e');
      return null;
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userRef.set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[FCM] Token successfully bound to user: ${user.uid}');
    } catch (e) {
      debugPrint('[FCM Save Token Error] $e');
    }
  }

  /// Handles incoming messages in the foreground:
  /// 1. Shows heads-up Android notification banner
  /// 2. Saves notification item to Firestore so it appears in the Inbox
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'LuckyMam';
    final body = notification?.body ?? message.data['body'] ?? '';
    final typeStr = message.data['type'] ?? 'system';

    // Show local heads-up notification
    const androidDetails = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFFFF5252),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotif.show(
      notifId,
      title,
      body,
      notifDetails,
      payload: jsonEncode(message.data),
    );

    // Save into Firestore Inbox
    await saveNotificationToInbox(
      title: title,
      body: body,
      type: NotificationType.fromString(typeStr),
      payload: message.data,
    );
  }

  /// Saves a notification entry into the current user's Firestore notifications collection
  Future<void> saveNotificationToInbox({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic> payload = const {},
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final notifRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc();

      final appNotif = AppNotification(
        id: notifRef.id,
        title: title,
        body: body,
        createdAt: DateTime.now(),
        type: type,
        isRead: false,
        payload: payload,
      );

      // Optimistically insert into local feed immediately
      NotificationActions.insertLocalNotification(appNotif);

      await notifRef.set(appNotif.toFirestore());
      debugPrint('[FCM Inbox] Notification saved to Firestore: ${notifRef.id}');
    } catch (e) {
      debugPrint('[FCM Inbox Save Error] $e');
    }
  }

  /// Convenience test method to simulate an incoming push notification
  Future<void> sendTestLocalNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.system,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFFFF5252),
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotif.show(notifId, title, body, notifDetails);

    await saveNotificationToInbox(
      title: title,
      body: body,
      type: type,
    );
  }
}
