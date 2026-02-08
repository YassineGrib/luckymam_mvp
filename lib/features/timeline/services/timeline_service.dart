import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/milestones_data.dart';
import '../models/milestone.dart';
import '../models/phase.dart';

/// Provider for TimelineService
final timelineServiceProvider = Provider<TimelineService>((ref) {
  return TimelineService(FirebaseFirestore.instance);
});

/// Provider for filtered milestones based on selected child
final childMilestonesProvider =
    FutureProvider.family<List<MilestoneWithDueDate>, String>((
      ref,
      childId,
    ) async {
      final service = ref.watch(timelineServiceProvider);
      final children = await ref.watch(childrenProvider.future);

      final child = children.firstWhere(
        (c) => c.id == childId,
        orElse: () => throw Exception('Child not found'),
      );

      return service.getMilestonesForChild(child);
    });

/// Provider for today's milestones
final todayMilestonesProvider =
    FutureProvider.family<List<MilestoneWithDueDate>, String>((
      ref,
      childId,
    ) async {
      final milestones = await ref.watch(
        childMilestonesProvider(childId).future,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return milestones.where((m) {
        if (m.dueDate == null) return false;
        final due = DateTime(m.dueDate!.year, m.dueDate!.month, m.dueDate!.day);
        // Show if due within the past 7 days or today
        return due.isAfter(today.subtract(const Duration(days: 7))) &&
            due.isBefore(today.add(const Duration(days: 1)));
      }).toList();
    });

/// Provider for upcoming milestones (next 30 days)
final upcomingMilestonesProvider =
    FutureProvider.family<List<MilestoneWithDueDate>, String>((
      ref,
      childId,
    ) async {
      final milestones = await ref.watch(
        childMilestonesProvider(childId).future,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final upcoming = today.add(const Duration(days: 30));

      return milestones.where((m) {
        if (m.dueDate == null) return false;
        final due = DateTime(m.dueDate!.year, m.dueDate!.month, m.dueDate!.day);
        // Show if due in the next 30 days (not today)
        return due.isAfter(today) && due.isBefore(upcoming);
      }).toList()..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    });

/// Provider for milestones by phase
final phasesMilestonesProvider =
    FutureProvider.family<Map<Phase, List<MilestoneWithDueDate>>, String>((
      ref,
      childId,
    ) async {
      final milestones = await ref.watch(
        childMilestonesProvider(childId).future,
      );

      final Map<Phase, List<MilestoneWithDueDate>> result = {};
      for (final phase in Phase.values) {
        result[phase] = milestones
            .where((m) => m.milestone.phase == phase)
            .toList();
      }
      return result;
    });

/// Provider for current phase based on child's age
final currentPhaseProvider = Provider.family<Phase, Child>((ref, child) {
  return TimelineService.determineCurrentPhase(child);
});

/// Milestone with calculated due date
class MilestoneWithDueDate {
  final Milestone milestone;
  final DateTime? dueDate;
  final bool isCompleted;
  final String? capsuleId;

  const MilestoneWithDueDate({
    required this.milestone,
    this.dueDate,
    this.isCompleted = false,
    this.capsuleId,
  });

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now()) && !isCompleted;
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }
}

/// Service for timeline-related operations
class TimelineService {
  final FirebaseFirestore _firestore;

  TimelineService(this._firestore);

  /// Get all milestones for a child with calculated due dates
  List<MilestoneWithDueDate> getMilestonesForChild(Child child) {
    final referenceDate = _getReferenceDate(child);

    return allMilestones.map((milestone) {
      DateTime? dueDate;

      if (milestone.phase == Phase.preGestation) {
        // Pre-gestation milestones have no specific due date
        dueDate = null;
      } else if (milestone.daysFromReference != null && referenceDate != null) {
        dueDate = referenceDate.add(
          Duration(days: milestone.daysFromReference!),
        );
      } else if (milestone.monthsFromReference != null &&
          referenceDate != null) {
        // For gestation: reference is pregnancy start
        // For post-partum/enfance: reference is birth date
        dueDate = _addMonths(referenceDate, milestone.monthsFromReference!);
      }

      return MilestoneWithDueDate(milestone: milestone, dueDate: dueDate);
    }).toList();
  }

  /// Get reference date based on child's phase
  DateTime? _getReferenceDate(Child child) {
    // If child has birth date, use it for post-partum and beyond
    // Child.birthDate is always available
    return child.birthDate;
  }

  /// Add months to a date
  DateTime _addMonths(DateTime date, int months) {
    return DateTime(
      date.year + ((date.month + months - 1) ~/ 12),
      ((date.month + months - 1) % 12) + 1,
      date.day,
    );
  }

  /// Determine current phase based on child's age
  static Phase determineCurrentPhase(Child child) {
    final now = DateTime.now();
    final birth = child.birthDate;
    final ageInDays = now.difference(birth).inDays;

    if (ageInDays < 0) {
      // Future birth date = gestation
      return Phase.gestation;
    } else if (ageInDays <= 365) {
      // 0-12 months = post-partum
      return Phase.postPartum;
    } else if (ageInDays <= 6570) {
      // 1-18 years = enfance
      return Phase.enfance;
    } else {
      // 18+ = adulte
      return Phase.adulte;
    }
  }

  /// Save milestone progress to Firestore
  Future<void> saveMilestoneProgress(MilestoneProgress progress) async {
    await _firestore
        .collection('users')
        .doc(progress.userId)
        .collection('milestoneProgress')
        .doc(progress.id)
        .set(progress.toJson());
  }

  /// Get milestone progress for a child
  Stream<List<MilestoneProgress>> watchMilestoneProgress(
    String userId,
    String childId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('milestoneProgress')
        .where('childId', isEqualTo: childId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MilestoneProgress.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Mark milestone as completed
  Future<void> completeMilestone({
    required String userId,
    required String childId,
    required String milestoneId,
    String? capsuleId,
    String? notes,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('milestoneProgress')
        .doc();

    final progress = MilestoneProgress(
      id: docRef.id,
      milestoneId: milestoneId,
      userId: userId,
      childId: childId,
      status: MilestoneStatus.completed,
      completedAt: DateTime.now(),
      capsuleId: capsuleId,
      notes: notes,
    );

    await docRef.set(progress.toJson());
  }

  /// Skip a milestone
  Future<void> skipMilestone({
    required String userId,
    required String childId,
    required String milestoneId,
    String? notes,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('milestoneProgress')
        .doc();

    final progress = MilestoneProgress(
      id: docRef.id,
      milestoneId: milestoneId,
      userId: userId,
      childId: childId,
      status: MilestoneStatus.skipped,
      completedAt: DateTime.now(),
      notes: notes,
    );

    await docRef.set(progress.toJson());
  }
}
