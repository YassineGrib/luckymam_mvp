import 'package:flutter/foundation.dart';
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
  try {
    final children = await ref.watch(childrenProvider.future);
    if (children.isEmpty) return [];

    final summaries = <ChildSummary>[];

    for (final child in children) {
      VaccineGroupWithStatus? nextVaccine;
      try {
        // Use ref.read instead of ref.watch to avoid async gap tracking issues in Riverpod
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
        // Use ref.read instead of ref.watch to avoid async gap tracking issues in Riverpod
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
        // Sort by date and take last 10 (already sorted by service, but good to be sure)
        final sorted = List<Capsule>.from(capsules)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted.take(10).toList();
      }).value ??
      [];
});

/// Daily tips by status
const List<String> _tipsHope = [
  "Prenez soin de vous : une alimentation équilibrée prépare votre corps à accueillir la vie.",
  "Le stress peut influencer la fertilité. Accordez-vous des moments de sérénité.",
  "Tenez un journal de votre cycle — chaque donnée compte.",
  "L'acide folique est essentiel dès maintenant. Parlez-en à votre médecin.",
  "Votre chemin est unique. Célébrez chaque étape, aussi petite soit-elle.",
  "La patience est une force. Votre moment viendra 💜",
];

const List<String> _tipsPregnant = [
  "Parlez à votre bébé ! Il reconnaît déjà votre voix dès le 6ème mois.",
  "Une promenade quotidienne de 20 minutes est bénéfique pour vous deux.",
  "Hydratez-vous bien — votre corps travaille double en ce moment.",
  "Notez vos ressentis aujourd'hui. Ce journal sera précieux plus tard.",
  "Chaque coup de pied est un message d'amour 🩷",
  "Reposez-vous sans culpabilité. C'est du travail, accoucher !",
];

const List<String> _tipsMom = [
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

/// Provider for daily tip adapted to user status
final dailyTipProvider = Provider<String>((ref) {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;

  final profile = ref.watch(profileProvider).valueOrNull;
  final status = profile?.status ?? UserStatus.mom;

  switch (status) {
    case UserStatus.hope:
      return _tipsHope[dayOfYear % _tipsHope.length];
    case UserStatus.pregnant:
      return _tipsPregnant[dayOfYear % _tipsPregnant.length];
    case UserStatus.mom:
      return _tipsMom[dayOfYear % _tipsMom.length];
  }
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
