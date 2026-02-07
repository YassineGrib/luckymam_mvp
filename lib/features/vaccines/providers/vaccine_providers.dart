import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vaccine.dart';
import '../models/vaccine_status.dart';
import '../services/vaccine_service.dart';

/// Provider for VaccineService instance.
final vaccineServiceProvider = Provider<VaccineService>((ref) {
  return VaccineService();
});

/// Provider for the vaccine calendar data.
final vaccineCalendarProvider = FutureProvider<VaccineCalendar>((ref) async {
  final service = ref.watch(vaccineServiceProvider);
  return service.loadVaccineCalendar();
});

/// Provider for vaccination statuses of a specific child.
final childVaccinationStatusesProvider =
    StreamProvider.family<List<VaccineStatus>, String>((ref, childId) {
      final service = ref.watch(vaccineServiceProvider);
      return service.watchVaccinationStatuses(childId);
    });

/// Combined data for displaying vaccine calendar with status.
class VaccineGroupWithStatus {
  VaccineGroupWithStatus({
    required this.group,
    required this.status,
    required this.statusType,
    required this.expectedDate,
    required this.daysUntilDue,
  });

  final VaccineGroup group;
  final VaccineStatus? status;
  final VaccineStatusType statusType;
  final DateTime expectedDate;
  final int daysUntilDue;

  bool get isCompleted => status?.isCompleted ?? false;
}

/// Provider for vaccine groups with status for a child.
final vaccineGroupsWithStatusProvider =
    FutureProvider.family<
      List<VaccineGroupWithStatus>,
      ({String childId, DateTime birthDate})
    >((ref, params) async {
      final calendar = await ref.watch(vaccineCalendarProvider.future);
      final statuses = await ref.watch(
        childVaccinationStatusesProvider(params.childId).future,
      );

      final statusMap = {for (final s in statuses) s.vaccineGroupId: s};

      final now = DateTime.now();
      final result = <VaccineGroupWithStatus>[];

      for (final group in calendar.groups) {
        final status = statusMap[group.id];
        final expectedDate = group.getExpectedDate(params.birthDate);
        final daysUntilDue = expectedDate.difference(now).inDays;
        final statusType = VaccineStatus.calculateStatus(
          birthDate: params.birthDate,
          ageMonths: group.ageMonths,
          isCompleted: status?.isCompleted ?? false,
        );

        result.add(
          VaccineGroupWithStatus(
            group: group,
            status: status,
            statusType: statusType,
            expectedDate: expectedDate,
            daysUntilDue: daysUntilDue,
          ),
        );
      }

      return result;
    });

/// Notifier for vaccine actions.
class VaccineActionsNotifier extends StateNotifier<AsyncValue<void>> {
  VaccineActionsNotifier(this._service) : super(const AsyncValue.data(null));

  final VaccineService _service;

  Future<void> markCompleted({
    required String childId,
    required String vaccineGroupId,
    required DateTime completedAt,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.markVaccineCompleted(
        childId: childId,
        vaccineGroupId: vaccineGroupId,
        completedAt: completedAt,
        notes: notes,
      );
    });
  }

  Future<void> markIncomplete({
    required String childId,
    required String vaccineGroupId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.markVaccineIncomplete(
        childId: childId,
        vaccineGroupId: vaccineGroupId,
      );
    });
  }
}

/// Provider for vaccine actions.
final vaccineActionsProvider =
    StateNotifierProvider<VaccineActionsNotifier, AsyncValue<void>>((ref) {
      final service = ref.watch(vaccineServiceProvider);
      return VaccineActionsNotifier(service);
    });
