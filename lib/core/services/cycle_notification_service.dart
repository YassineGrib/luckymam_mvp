import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';
import '../../features/profile/models/profile_models.dart';

/// Provider for CycleNotificationService.
final cycleNotificationServiceProvider = Provider<CycleNotificationService>((
  ref,
) {
  return CycleNotificationService(ref.watch(notificationServiceProvider));
});

/// Schedules menstrual cycle phase reminders.
///
/// Schedules two notifications per cycle:
///   1. "Règles dans 2 jours" — 2 days before the next period at 08:00.
///   2. "Phase Ovulatoire demain" — on day 12 of the cycle at 08:00.
class CycleNotificationService {
  final NotificationService _notifications;

  const CycleNotificationService(this._notifications);

  /// Schedule (or re-schedule) both cycle reminders based on [cycleInfo].
  ///
  /// Safe to call every time the user logs a new period — previous reminders
  /// are cancelled first inside [NotificationService.scheduleCycleReminders].
  Future<void> scheduleReminders(CycleInfo cycleInfo) async {
    if (!cycleInfo.isTracking) return;
    if (cycleInfo.lastPeriodDate == null) return;
    if (cycleInfo.nextPeriodDate == null) return;

    await _notifications.scheduleCycleReminders(
      lastPeriodDate: cycleInfo.lastPeriodDate!,
      nextPeriodDate: cycleInfo.nextPeriodDate!,
    );

    debugPrint(
      '[CycleNotif] reminders scheduled — '
      'next period: ${cycleInfo.nextPeriodDate}',
    );
  }

  /// Cancel all cycle notifications.
  Future<void> cancelReminders() async {
    await _notifications.cancelNotification(cycleNextPeriodId);
    await _notifications.cancelNotification(cycleOvulationId);
  }
}
