import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../profile/models/profile_models.dart';
import '../../timeline/services/timeline_service.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../../vaccines/providers/vaccine_providers.dart';

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
  final children = await ref.watch(childrenProvider.future);
  if (children.isEmpty) return [];

  final summaries = <ChildSummary>[];

  for (final child in children) {
    // 1. Get next vaccine
    final vaccines = await ref.watch(
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

    final nextVaccine = pendingVaccines.firstOrNull;

    // 2. Get next milestone
    final milestones = await ref.watch(
      upcomingMilestonesProvider(child.id).future,
    );
    // upcomingMilestonesProvider already sorts by date
    final nextMilestone = milestones.firstOrNull;

    summaries.add(
      ChildSummary(
        child: child,
        nextVaccine: nextVaccine,
        nextMilestone: nextMilestone,
      ),
    );
  }

  return summaries;
});

/// Provider for recent capsules (last 10)
final recentCapsulesProvider = Provider<List<Capsule>>((ref) {
  final capsulesAsync = ref.watch(capsulesProvider);
  return capsulesAsync.whenData((capsules) {
        // Sort by date and take last 10 (already sorted by service, but good to be sure)
        final sorted = List<Capsule>.from(capsules)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted.take(10).toList();
      }).value ??
      [];
});

/// Daily tips based on phase (static data)
const List<String> _dailyTips = [
  "Parlez à votre bébé ! Il reconnaît déjà votre voix.",
  "Prenez du temps pour vous. Une maman heureuse = un bébé heureux.",
  "Chaque moment est précieux. Capturez-le dans une capsule !",
  "La musique calme peut aider votre bébé à s'apaiser.",
  "Les câlins libèrent de l'ocytocine, l'hormone du bonheur.",
  "Votre bébé apprend en vous observant. Souriez souvent !",
  "N'oubliez pas de boire beaucoup d'eau.",
  "Faites des pauses. Le repos est essentiel.",
  "Célébrez chaque petit progrès de votre enfant.",
  "Respirez profondément. Vous êtes une super maman !",
];

/// Provider for daily tip (changes each day)
final dailyTipProvider = Provider<String>((ref) {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;

  return _dailyTips[dayOfYear % _dailyTips.length];
});

/// Greeting based on time of day
String getTimeBasedGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Bonjour';
  } else if (hour < 18) {
    return 'Bon après-midi';
  } else {
    return 'Bonsoir';
  }
}
