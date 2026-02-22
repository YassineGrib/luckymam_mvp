import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../../profile/models/profile_models.dart';
import '../services/timeline_service.dart';

/// Provider for MilestoneNotificationService.
final milestoneNotificationServiceProvider =
    Provider<MilestoneNotificationService>((ref) {
      return MilestoneNotificationService(
        ref.watch(notificationServiceProvider),
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
}
