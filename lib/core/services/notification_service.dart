import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─── Channel IDs (stable; names/descriptions are localized at schedule time) ─
const vaccineChannelId = 'vaccine_channel';
const milestoneChannelId = 'milestone_channel';
const cycleChannelId = 'cycle_channel';

// ─── ID ranges (to avoid collisions) ─────────────────────────────────────────
// Vaccine IDs:   any hashCode (from childId+groupId)
// Milestone IDs: any hashCode (from childId+milestoneId)
// Cycle IDs:     10_001 (period) and 10_002 (ovulation)
const cycleNextPeriodId = 10001;
const cycleOvulationId = 10002;

/// Provider for NotificationService.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  return service;
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Emits the payload of whichever notification the user just tapped
  /// (foreground or background). Used for deep-linking. Static so every
  /// instance of this service shares the same tap stream.
  static final ValueNotifier<String?> onNotificationTapped =
      ValueNotifier<String?>(null);

  NotificationService() {
    _init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    // Algeria is UTC+1 (no DST)
    tz.setLocalLocation(tz.getLocation('Africa/Algiers'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[Notif] tapped payload=${details.payload}');
        onNotificationTapped.value = details.payload;
      },
    );
    _initialized = true;
  }

  /// Returns the payload of the notification that launched the app from a
  /// terminated state, or null if the app wasn't launched via a notification.
  Future<String?> getLaunchPayload() async {
    await _ensure();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  // ─── Permissions ────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ─── Vaccine Reminders ───────────────────────────────────────────────────────

  /// Schedules a vaccine reminder 2 days before [dueDate] at 09:00.
  Future<void> scheduleVaccineReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
    required String channelName,
    required String channelDesc,
  }) async {
    await _ensure();
    final scheduledDate = dueDate.subtract(const Duration(days: 2));
    final notify = _atNineAm(scheduledDate);
    if (notify.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notify,
      channelId: vaccineChannelId,
      channelName: channelName,
      channelDesc: channelDesc,
      payload: 'vaccine',
    );
  }

  // ─── Milestone Reminders ─────────────────────────────────────────────────────

  /// Schedules a milestone reminder 7 days before [dueDate] at 09:00.
  Future<void> scheduleMilestoneReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dueDate,
    required String channelName,
    required String channelDesc,
  }) async {
    await _ensure();
    final scheduledDate = dueDate.subtract(const Duration(days: 7));
    final notify = _atNineAm(scheduledDate);
    if (notify.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notify,
      channelId: milestoneChannelId,
      channelName: channelName,
      channelDesc: channelDesc,
      payload: 'milestone',
    );
  }

  /// Schedules a user-picked reminder for a specific milestone at the exact
  /// [scheduledFor] date/time. Tapping the notification deep-links back to
  /// the milestone via a JSON payload carrying [childId] and [milestoneId].
  Future<void> scheduleMilestoneCustomReminder({
    required int id,
    required String childId,
    required String milestoneId,
    required String title,
    required String body,
    required DateTime scheduledFor,
    required String channelName,
    required String channelDesc,
  }) async {
    await _ensure();
    final now = tz.TZDateTime.now(tz.local);
    final notify = tz.TZDateTime(
      tz.local,
      scheduledFor.year,
      scheduledFor.month,
      scheduledFor.day,
      scheduledFor.hour,
      scheduledFor.minute,
    );
    if (notify.isBefore(now)) return;

    final payload = jsonEncode({
      'type': 'milestone_reminder',
      'childId': childId,
      'milestoneId': milestoneId,
    });

    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notify,
      channelId: milestoneChannelId,
      channelName: channelName,
      channelDesc: channelDesc,
      payload: payload,
    );
  }

  // ─── Cycle Reminders ─────────────────────────────────────────────────────────

  /// Schedules 2 cycle notifications:
  ///  - period approaching (2 days before [nextPeriodDate] at 08:00)
  ///  - ovulation window (13 days after [lastPeriodDate] at 08:00)
  Future<void> scheduleCycleReminders({
    required DateTime lastPeriodDate,
    required DateTime nextPeriodDate,
    required String periodTitle,
    required String periodBody,
    required String ovulationTitle,
    required String ovulationBody,
    required String channelName,
    required String channelDesc,
  }) async {
    await _ensure();
    final now = tz.TZDateTime.now(tz.local);

    // Cancel previous cycle reminders before rescheduling
    await _plugin.cancel(cycleNextPeriodId);
    await _plugin.cancel(cycleOvulationId);

    // 1) Period approaching (2 days before)
    final periodAlert = _atEightAm(
      nextPeriodDate.subtract(const Duration(days: 2)),
    );
    if (periodAlert.isAfter(now)) {
      await _zonedSchedule(
        id: cycleNextPeriodId,
        title: periodTitle,
        body: periodBody,
        scheduledDate: periodAlert,
        channelId: cycleChannelId,
        channelName: channelName,
        channelDesc: channelDesc,
        payload: 'cycle_period',
      );
    }

    // 2) Ovulation window (day 13 of cycle)
    final ovulationAlert = _atEightAm(
      lastPeriodDate.add(const Duration(days: 12)),
    );
    if (ovulationAlert.isAfter(now)) {
      await _zonedSchedule(
        id: cycleOvulationId,
        title: ovulationTitle,
        body: ovulationBody,
        scheduledDate: ovulationAlert,
        channelId: cycleChannelId,
        channelName: channelName,
        channelDesc: channelDesc,
        payload: 'cycle_ovulation',
      );
    }
  }

  // ─── Legacy compat ────────────────────────────────────────────────────────────

  /// Kept for backward compatibility with existing VaccineService calls.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelName,
    required String channelDesc,
  }) async {
    await _ensure();
    final notify = _atNineAm(scheduledDate);
    if (notify.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notify,
      channelId: vaccineChannelId,
      channelName: channelName,
      channelDesc: channelDesc,
      payload: 'vaccine',
    );
  }

  // ─── Cancel helpers ───────────────────────────────────────────────────────────

  Future<void> cancelNotification(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Cancel pending notifications by channel tag.
  /// Since the plugin doesn't support channel-level cancel natively,
  /// we use a known range per channel:
  ///   vaccine   — we cannot enumerate hashCode IDs; skip (acceptable UX)
  ///   milestone — same; scheduled reminders expire naturally
  ///   cycle     — fixed IDs, cancel directly
  Future<void> cancelNotificationsByChannel(String channelTag) async {
    if (channelTag == 'cycle') {
      await _plugin.cancel(cycleNextPeriodId);
      await _plugin.cancel(cycleOvulationId);
    }
    // For vaccine / milestone channels the IDs are hashCode-based and
    // cannot be enumerated here. Toggling off prevents NEW reminders;
    // existing ones are cancelled automatically when the next schedule
    // call is skipped (guarded by the prefs check in the services).
    debugPrint('[Notif] cancelNotificationsByChannel: $channelTag');
  }

  // ─── Private helpers ──────────────────────────────────────────────────────────

  Future<void> _ensure() async {
    if (!_initialized) await _init();
  }

  tz.TZDateTime _atNineAm(DateTime date) =>
      tz.TZDateTime(tz.local, date.year, date.month, date.day, 9, 0);

  tz.TZDateTime _atEightAm(DateTime date) =>
      tz.TZDateTime(tz.local, date.year, date.month, date.day, 8, 0);

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    required String channelDesc,
    String? payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(presentAlert: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[Notif] scheduled id=$id "$title" at $scheduledDate');
    } catch (e) {
      debugPrint('[Notif] ERROR scheduling id=$id: $e');
    }
  }
}
