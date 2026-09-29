import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../models/app_notification.dart';

/// In-memory notification cache for immediate display and resilient fallback
List<AppNotification> _inMemoryNotifications = [];
String? _lastLanguageCode;

/// Broadcast stream for instant local UI reactions (reads, deletes, test pushes)
final StreamController<List<AppNotification>> _localUpdatesController =
    StreamController<List<AppNotification>>.broadcast();

void _emitLocalUpdate() {
  if (!_localUpdatesController.isClosed) {
    _localUpdatesController.add(List<AppNotification>.from(_inMemoryNotifications));
  }
}

/// Real-time stream provider for the current user's notifications.
/// Highly resilient: never fails or crashes the UI even if Firestore rules or offline errors occur.
final notificationsStreamProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) async* {
  final lang = ref.watch(localeProvider).languageCode;
  final uid = ref.watch(userIdProvider) ?? FirebaseAuth.instance.currentUser?.uid;

  // Initialize or update starter notifications if empty or if language changed
  if (_inMemoryNotifications.isEmpty || _lastLanguageCode != lang) {
    _lastLanguageCode = lang;
    _inMemoryNotifications = _getStarterNotifications(lang);
  }

  // 1. Instantly yield current cache so there is 0ms loading blankness
  yield List<AppNotification>.from(_inMemoryNotifications);

  if (uid == null) {
    // If not authenticated, keep streaming local actions
    await for (final localList in _localUpdatesController.stream) {
      yield localList;
    }
    return;
  }

  // 2. Stream from Firestore with safe fallback
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? firestoreSub;
  final mergedController = StreamController<List<AppNotification>>();

  // Forward local actions immediately
  final localSub = _localUpdatesController.stream.listen((list) {
    if (!mergedController.isClosed) {
      mergedController.add(list);
    }
  });

  try {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    firestoreSub = collection.snapshots().listen(
      (snapshot) {
        if (snapshot.docs.isEmpty) {
          // Attempt to seed starter notifications to Firestore in background
          _seedDefaultNotifications(uid, lang);
          if (!mergedController.isClosed) {
            mergedController.add(List<AppNotification>.from(_inMemoryNotifications));
          }
        } else {
          final items = snapshot.docs.map(AppNotification.fromFirestore).toList();
          _inMemoryNotifications = items;
          if (!mergedController.isClosed) {
            mergedController.add(List<AppNotification>.from(_inMemoryNotifications));
          }
        }
      },
      onError: (error) {
        debugPrint(
          '[Notifications Stream] Firestore error ($error). Gracefully falling back to local notifications.',
        );
        if (!mergedController.isClosed) {
          mergedController.add(List<AppNotification>.from(_inMemoryNotifications));
        }
      },
    );
  } catch (e) {
    debugPrint('[Notifications Stream Init Catch] $e');
    if (!mergedController.isClosed) {
      mergedController.add(List<AppNotification>.from(_inMemoryNotifications));
    }
  }

  ref.onDispose(() {
    firestoreSub?.cancel();
    localSub.cancel();
    mergedController.close();
  });

  yield* mergedController.stream;
});

/// Count of unread notifications for badge indicators across the app.
final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notifsAsync = ref.watch(notificationsStreamProvider);
  return notifsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => _inMemoryNotifications.where((n) => !n.isRead).length,
  );
});

/// Controller for notification actions (mark read, delete, clear).
final notificationActionsProvider =
    Provider.autoDispose<NotificationActions>((ref) {
  return NotificationActions();
});

class NotificationActions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  /// Adds a notification to the local feed and syncs with Firestore
  static void insertLocalNotification(AppNotification notif) {
    _inMemoryNotifications.removeWhere((n) => n.id == notif.id);
    _inMemoryNotifications.insert(0, notif);
    _emitLocalUpdate();
  }

  /// Mark a specific notification as read (optimistic + remote)
  Future<void> markAsRead(String notificationId) async {
    final idx = _inMemoryNotifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _inMemoryNotifications[idx] =
          _inMemoryNotifications[idx].copyWith(isRead: true);
      _emitLocalUpdate();
    }

    try {
      await _collection?.doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint('[Notif Action Warning] markAsRead Firestore sync: $e');
    }
  }

  /// Mark all notifications as read (optimistic + remote)
  Future<void> markAllAsRead() async {
    _inMemoryNotifications = _inMemoryNotifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _emitLocalUpdate();

    try {
      final col = _collection;
      if (col == null) return;
      final unreadDocs = await col.where('isRead', isEqualTo: false).get();
      if (unreadDocs.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[Notif Action Warning] markAllAsRead Firestore sync: $e');
    }
  }

  /// Delete a notification (optimistic + remote)
  Future<void> deleteNotification(String notificationId) async {
    _inMemoryNotifications.removeWhere((n) => n.id == notificationId);
    _emitLocalUpdate();

    try {
      await _collection?.doc(notificationId).delete();
    } catch (e) {
      debugPrint('[Notif Action Warning] deleteNotification Firestore sync: $e');
    }
  }

  /// Clear all notifications (optimistic + remote)
  Future<void> clearAll() async {
    _inMemoryNotifications.clear();
    _emitLocalUpdate();

    try {
      final col = _collection;
      if (col == null) return;
      final allDocs = await col.get();
      if (allDocs.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in allDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[Notif Action Warning] clearAll Firestore sync: $e');
    }
  }
}

/// Generates localized starter notifications so the inbox always feels alive and helpful.
List<AppNotification> _getStarterNotifications(String lang) {
  final now = DateTime.now();

  if (lang == 'ar') {
    return [
      AppNotification(
        id: 'starter_ar_1',
        title: 'تذكير اللقاح: موعد تطعيم الشهر الثاني غداً 🩺',
        body: 'حان موعد تطعيم الخماسي وشلل الأطفال لطفلكِ، احرصي على قياس الحرارة وتوفير الراحة التامة.',
        createdAt: now.subtract(const Duration(minutes: 25)),
        type: NotificationType.vaccine,
        isRead: false,
        payload: {'route': 'vaccines'},
      ),
      AppNotification(
        id: 'starter_ar_2',
        title: 'ألبوم الذكريات السنوي الفاخر بانتظاركِ 👑',
        body: 'اشتراككِ الـ VIP يمنحكِ ألبوماً ورقياً مطبوعاً فاخراً مجاناً! اجمعي لحظات السنة الأولى واطلبيه لمنزلكِ.',
        createdAt: now.subtract(const Duration(hours: 3)),
        type: NotificationType.album,
        isRead: false,
        payload: {'route': 'album'},
      ),
      AppNotification(
        id: 'starter_ar_3',
        title: 'لحظة جديدة تستحق التوثيق 📸',
        body: 'التقطي صورة لابتسامة طفلكِ اليوم وأضيفيها لكبسولة الذكريات لتخليد هذه اللحظة الدافئة.',
        createdAt: now.subtract(const Duration(hours: 18)),
        type: NotificationType.capsule,
        isRead: true,
        payload: {'route': 'capsule'},
      ),
      AppNotification(
        id: 'starter_ar_4',
        title: 'نصيحة اليوم لصحة الأم والطفل 🌸',
        body: 'شرب كميات كافية من الماء والنوم عند نوم الرضيع يساعدكِ على تجديد طاقتكِ اليومية وراحتكِ.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        type: NotificationType.system,
        isRead: true,
        payload: {'route': 'tips'},
      ),
    ];
  } else if (lang == 'fr') {
    return [
      AppNotification(
        id: 'starter_fr_1',
        title: 'Rappel Vaccin : Visite des 2 mois demain 🩺',
        body: 'C\'est le moment pour les vaccins pentavalent et polio. Veillez au repos de bébé et surveillez sa température.',
        createdAt: now.subtract(const Duration(minutes: 25)),
        type: NotificationType.vaccine,
        isRead: false,
        payload: {'route': 'vaccines'},
      ),
      AppNotification(
        id: 'starter_fr_2',
        title: 'Votre Livre Photo Annuel vous Attend 👑',
        body: 'Votre abonnement VIP vous offre un album imprimé de luxe gratuit ! Immortalisez cette première année.',
        createdAt: now.subtract(const Duration(hours: 3)),
        type: NotificationType.album,
        isRead: false,
        payload: {'route': 'album'},
      ),
      AppNotification(
        id: 'starter_fr_3',
        title: 'Un moment précieux à capturer 📸',
        body: 'Prenez une photo du sourire de votre bébé aujourd\'hui et conservez-la dans votre capsule temporelle.',
        createdAt: now.subtract(const Duration(hours: 18)),
        type: NotificationType.capsule,
        isRead: true,
        payload: {'route': 'capsule'},
      ),
      AppNotification(
        id: 'starter_fr_4',
        title: 'Conseil du Jour : Maman & Bébé 🌸',
        body: 'Une bonne hydratation et des siestes synchronisées avec bébé aident à préserver votre énergie.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        type: NotificationType.system,
        isRead: true,
        payload: {'route': 'tips'},
      ),
    ];
  } else {
    // English default
    return [
      AppNotification(
        id: 'starter_en_1',
        title: 'Vaccine Reminder: 2nd Month Vaccines Due Tomorrow 🩺',
        body: 'It\'s time for the Pentavalent and Polio vaccination. Remember to monitor baby\'s temperature and provide rest.',
        createdAt: now.subtract(const Duration(minutes: 25)),
        type: NotificationType.vaccine,
        isRead: false,
        payload: {'route': 'vaccines'},
      ),
      AppNotification(
        id: 'starter_en_2',
        title: 'Your Annual Memory Album is Waiting 👑',
        body: 'Your VIP membership includes a luxury printed photo album for free! Curate year one memories and order it directly to your door.',
        createdAt: now.subtract(const Duration(hours: 3)),
        type: NotificationType.album,
        isRead: false,
        payload: {'route': 'album'},
      ),
      AppNotification(
        id: 'starter_en_3',
        title: 'A New Precious Moment to Capture 📸',
        body: 'Capture your baby\'s smile today and add it to your Memory Capsule to cherish forever.',
        createdAt: now.subtract(const Duration(hours: 18)),
        type: NotificationType.capsule,
        isRead: true,
        payload: {'route': 'capsule'},
      ),
      AppNotification(
        id: 'starter_en_4',
        title: 'Daily Tip for Mom & Baby 🌸',
        body: 'Staying hydrated and resting when your baby sleeps will help restore your daily energy and peace.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        type: NotificationType.system,
        isRead: true,
        payload: {'route': 'tips'},
      ),
    ];
  }
}

/// Seeds friendly starter notifications to Firestore in background
bool _seedingInProgress = false;
Future<void> _seedDefaultNotifications(String uid, String lang) async {
  if (_seedingInProgress) return;
  _seedingInProgress = true;

  try {
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');

    final existing = await col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final starterList = _getStarterNotifications(lang);

    for (final notif in starterList) {
      final docRef = col.doc();
      final item = notif.copyWith(id: docRef.id);
      batch.set(docRef, item.toFirestore());
    }

    await batch.commit();
  } catch (e) {
    debugPrint('[Seed Warning] Could not write seed notifications to Firestore: $e');
  } finally {
    _seedingInProgress = false;
  }
}
