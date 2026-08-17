import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../../timeline/services/timeline_service.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../../vaccines/providers/vaccine_providers.dart';
import '../data/home_tips_data.dart';

/// Summary data for a child card
class ChildSummary {
  final Child child;
  final VaccineGroupWithStatus? nextVaccine;
  final MilestoneWithDueDate? nextMilestone;

  const ChildSummary({
    required this.child,
    this.nextVaccine,
    this.nextMilestone,
  });
}

/// Provider for all children summaries
final childrenSummaryProvider = FutureProvider<List<ChildSummary>>((ref) async {
  try {
    final children = await ref.watch(childrenProvider.future);
    if (children.isEmpty) return [];

    final summaries = <ChildSummary>[];

    for (final child in children) {
      VaccineGroupWithStatus? nextVaccine;
      try {
        final vaccines = await ref.read(
          vaccineGroupsWithStatusProvider((
            childId: child.id,
            birthDate: child.birthDate,
          )).future,
        );

        final pendingVaccines =
            vaccines
                .where(
                  (v) =>
                      v.statusType == VaccineStatusType.upcoming ||
                      v.statusType == VaccineStatusType.dueSoon ||
                      v.statusType == VaccineStatusType.overdue,
                )
                .toList()
              ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

        nextVaccine = pendingVaccines.firstOrNull;
      } catch (e, stack) {
        debugPrint('Error getting vaccines for child ${child.id}: $e\n$stack');
      }

      MilestoneWithDueDate? nextMilestone;
      try {
        final milestones = await ref.read(
          upcomingMilestonesProvider(child.id).future,
        );
        nextMilestone = milestones.firstOrNull;
      } catch (e, stack) {
        debugPrint('Error getting milestones for child ${child.id}: $e\n$stack');
      }

      summaries.add(
        ChildSummary(
          child: child,
          nextVaccine: nextVaccine,
          nextMilestone: nextMilestone,
        ),
      );
    }

    return summaries;
  } catch (e, stack) {
    debugPrint('Error in childrenSummaryProvider: $e\n$stack');
    rethrow;
  }
});

/// Provider for recent capsules (last 10)
final recentCapsulesProvider = Provider<List<Capsule>>((ref) {
  final capsulesAsync = ref.watch(capsulesProvider);
  return capsulesAsync.whenData((capsules) {
        final sorted = List<Capsule>.from(capsules)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted.take(10).toList();
      }).value ??
      [];
});

/// Provider for daily tip adapted to user status and locale
final dailyTipProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider).languageCode;
  final profile = ref.watch(profileProvider).valueOrNull;
  final status = profile?.status ?? UserStatus.mom;
  return HomeTipsData.tipFor(locale, status);
});

/// Greeting based on time of day and locale
String getTimeBasedGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return l10n.greetingMorning;
  } else if (hour < 18) {
    return l10n.greetingAfternoon;
  } else {
    return l10n.greetingEvening;
  }
}
