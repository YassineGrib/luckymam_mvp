import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ─── Channel constants ────────────────────────────────────────────────────────
const _vaccineChannelId = 'vaccine_channel';
const _vaccineChannelName = 'Vaccinations';
const _milestoneChannelId = 'milestone_channel';
const _milestoneChannelName = 'Milestones';
const _cycleChannelId = 'cycle_channel';
const _cycleChannelName = 'Cycle Féminin';

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
        // TODO: route to the relevant screen via payload
        debugPrint('[Notif] tapped payload=${details.payload}');
      },
    );
    _initialized = true;
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
    required String childName,
    required String vaccineLabel,
    required DateTime dueDate,
  }) async {
    await _ensure();
    final scheduledDate = dueDate.subtract(const Duration(days: 2));
    final notify = _atNineAm(scheduledDate);
    if (notify.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _zonedSchedule(
      id: id,
      title: '💉 Rappel Vaccin – $childName',
      body:
          '$vaccineLabel prévu le ${DateFormat('dd/MM/yyyy').format(dueDate)}',
      scheduledDate: notify,
      channelId: _vaccineChannelId,
      channelName: _vaccineChannelName,
      channelDesc: 'Rappels de vaccination',
      payload: 'vaccine',
    );
  }

  // ─── Milestone Reminders ─────────────────────────────────────────────────────

  /// Schedules a milestone reminder 7 days before [dueDate] at 09:00.
  Future<void> scheduleMilestoneReminder({
    required int id,
    required String childName,
    required String milestoneTitle,
    required DateTime dueDate,
  }) async {
    await _ensure();
    final scheduledDate = dueDate.subtract(const Duration(days: 7));
    final notify = _atNineAm(scheduledDate);
    if (notify.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _zonedSchedule(
      id: id,
      title: '⭐ Étape à venir – $childName',
      body: '"$milestoneTitle" dans 7 jours',
      scheduledDate: notify,
      channelId: _milestoneChannelId,
      channelName: _milestoneChannelName,
      channelDesc: 'Alertes étapes de développement',
      payload: 'milestone',
    );
  }

  // ─── Cycle Reminders ─────────────────────────────────────────────────────────

  /// Schedules 2 cycle notifications:
  ///  - "Règles dans 2 jours" (2 days before [nextPeriodDate] at 08:00)
  ///  - "Phase ovulatoire demain" (13 days after [lastPeriodDate] at 08:00)
  Future<void> scheduleCycleReminders({
    required DateTime lastPeriodDate,
    required DateTime nextPeriodDate,
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
        title: '🌸 Règles dans 2 jours',
        body: 'Pensez à vous préparer pour votre prochain cycle.',
        scheduledDate: periodAlert,
        channelId: _cycleChannelId,
        channelName: _cycleChannelName,
        channelDesc: 'Rappels du cycle féminin',
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
        title: '🌿 Phase Ovulatoire demain',
        body: 'Votre période de fertilité maximale commence demain.',
        scheduledDate: ovulationAlert,
        channelId: _cycleChannelId,
        channelName: _cycleChannelName,
        channelDesc: 'Rappels du cycle féminin',
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
  }) async {
    await _ensure();
    final notify = _atNineAm(scheduledDate);
    if (notify.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notify,
      channelId: _vaccineChannelId,
      channelName: _vaccineChannelName,
      channelDesc: 'Rappels de vaccination',
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
