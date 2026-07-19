import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notification_service.dart';
import '../../profile/models/profile_models.dart';
import '../services/timeline_service.dart';

const _kCustomReminderPrefix = 'milestone_custom_reminder_';

/// Provider for MilestoneNotificationService.
final milestoneNotificationServiceProvider =
    Provider<MilestoneNotificationService>((ref) {
      return MilestoneNotificationService(
        ref.watch(notificationServiceProvider),
      );
    });

/// Whether — and when — a custom reminder is scheduled for a given
/// child + milestone. Invalidate after scheduling/cancelling to refresh.
final milestoneReminderProvider =
    FutureProvider.family<DateTime?, ({String childId, String milestoneId})>((
      ref,
      params,
    ) {
      final service = ref.watch(milestoneNotificationServiceProvider);
      return service.getCustomReminder(
        childId: params.childId,
        milestoneId: params.milestoneId,
      );
    });

/// Schedules and cancels milestone reminder notifications for a child.
class MilestoneNotificationService {
  final NotificationService _notifications;

  const MilestoneNotificationService(this._notifications);

  /// Schedules reminders for all upcoming, non-completed milestones.
  ///
  /// Fires a notification 7 days before each milestone's [dueDate].
  /// Milestones without a due date or already completed are ignored.
  Future<void> scheduleAllReminders({
    required Child child,
    required List<MilestoneWithDueDate> milestones,
  }) async {
    final now = DateTime.now();

    for (final m in milestones) {
      if (m.dueDate == null) continue;
      if (m.isCompleted) continue;

      // Only schedule if the reminder date (7 days before) is still in the future
      final reminderDate = m.dueDate!.subtract(const Duration(days: 7));
      if (reminderDate.isBefore(now)) continue;

      final id = _stableId(child.id, m.milestone.id);

      await _notifications.scheduleMilestoneReminder(
        id: id,
        childName: child.name,
        milestoneTitle: m.milestone.titleFr,
        dueDate: m.dueDate!,
      );
    }

    debugPrint(
      '[MilestoneNotif] scheduled reminders for ${child.name} '
      '(${milestones.length} milestones checked)',
    );
  }

  /// Cancels all milestone reminders for [childId].
  ///
  /// Since IDs are hash-based, we cancel by iterating known milestones.
  Future<void> cancelAllReminders({
    required String childId,
    required List<MilestoneWithDueDate> milestones,
  }) async {
    for (final m in milestones) {
      final id = _stableId(childId, m.milestone.id);
      await _notifications.cancelNotification(id);
    }
  }

  /// Generates a stable, unique notification ID from child + milestone.
  int _stableId(String childId, String milestoneId) =>
      (childId + milestoneId).hashCode.abs();

  /// Schedules a user-picked reminder for a specific milestone.
  ///
  /// Uses a distinct notification ID (suffix `_manual`) so it never collides
  /// with the automatic 7-day-before reminder. Scheduling again for the same
  /// child + milestone replaces the previous custom reminder — this is the
  /// rate-limiting measure: a milestone can only ever have one pending
  /// custom reminder at a time.
  Future<void> scheduleCustomReminder({
    required Child child,
    required MilestoneWithDueDate milestone,
    required DateTime scheduledFor,
  }) async {
    final id = _stableId(child.id, '${milestone.milestone.id}_manual');

    await _notifications.scheduleMilestoneCustomReminder(
      id: id,
      childId: child.id,
      milestoneId: milestone.milestone.id,
      childName: child.name,
      milestoneTitle: milestone.milestone.titleFr,
      scheduledFor: scheduledFor,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_kCustomReminderPrefix${child.id}_${milestone.milestone.id}',
      scheduledFor.toIso8601String(),
    );
  }

  /// Returns the scheduled date/time of a custom reminder, if one is set.
  Future<DateTime?> getCustomReminder({
    required String childId,
    required String milestoneId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(
      '$_kCustomReminderPrefix${childId}_$milestoneId',
    );
    if (stored == null) return null;
    return DateTime.tryParse(stored);
  }

  /// Cancels a previously scheduled custom reminder.
  Future<void> cancelCustomReminder({
    required String childId,
    required String milestoneId,
  }) async {
    final id = _stableId(childId, '${milestoneId}_manual');
    await _notifications.cancelNotification(id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kCustomReminderPrefix${childId}_$milestoneId');
  }
}
