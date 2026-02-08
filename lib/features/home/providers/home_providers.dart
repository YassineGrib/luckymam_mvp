import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../capsules/models/capsule.dart';
import '../../capsules/providers/capsule_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../timeline/services/timeline_service.dart';
import '../../vaccines/models/vaccine_status.dart';
import '../../vaccines/providers/vaccine_providers.dart';

/// Provider for the first (most urgent) milestone today
final heroMilestoneProvider = Provider<MilestoneWithDueDate?>((ref) {
  final selectedChildAsync = ref.watch(selectedChildProvider);

  return selectedChildAsync.when(
    data: (child) {
      if (child == null) return null;

      final milestonesAsync = ref.watch(todayMilestonesProvider(child.id));
      return milestonesAsync.whenData((milestones) {
        if (milestones.isEmpty) return null;
        // Return the first (most urgent) milestone
        return milestones.first;
      }).value;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for this week's milestones (next 7 days)
final weekMilestonesProvider = Provider<List<MilestoneWithDueDate>>((ref) {
  final selectedChildAsync = ref.watch(selectedChildProvider);

  return selectedChildAsync.when(
    data: (child) {
      if (child == null) return [];

      final milestonesAsync = ref.watch(upcomingMilestonesProvider(child.id));
      return milestonesAsync.whenData((milestones) {
            final now = DateTime.now();
            final weekEnd = now.add(const Duration(days: 7));

            return milestones
                .where((m) {
                  if (m.dueDate == null) return false;
                  return m.dueDate!.isBefore(weekEnd);
                })
                .take(5)
                .toList();
          }).value ??
          [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for recent capsules (last 5)
final recentCapsulesProvider = Provider<List<Capsule>>((ref) {
  final selectedChildAsync = ref.watch(selectedChildProvider);

  return selectedChildAsync.when(
    data: (child) {
      if (child == null) return [];

      final capsulesAsync = ref.watch(capsulesByChildProvider(child.id));
      return capsulesAsync.whenData((capsules) {
            // Sort by date and take last 5
            final sorted = List<Capsule>.from(capsules)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return sorted.take(5).toList();
          }).value ??
          [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for next upcoming vaccine
final nextVaccineProvider = Provider<VaccineGroupWithStatus?>((ref) {
  final selectedChildAsync = ref.watch(selectedChildProvider);

  return selectedChildAsync.when(
    data: (child) {
      if (child == null) return null;

      final vaccinesAsync = ref.watch(
        vaccineGroupsWithStatusProvider((
          childId: child.id,
          birthDate: child.birthDate,
        )),
      );

      return vaccinesAsync.whenData((vaccines) {
        // Find next pending vaccine
        final pending = vaccines
            .where(
              (v) =>
                  v.statusType == VaccineStatusType.upcoming ||
                  v.statusType == VaccineStatusType.dueSoon,
            )
            .toList();

        if (pending.isEmpty) return null;

        pending.sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
        return pending.first;
      }).value;
    },
    loading: () => null,
    error: (_, __) => null,
  );
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
