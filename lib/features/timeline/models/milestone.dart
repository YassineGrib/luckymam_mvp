import 'phase.dart';

/// Represents a milestone/event in the child's life journey
class Milestone {
  final String id;
  final String titleFr;
  final String titleAr;
  final String descriptionFr;
  final String descriptionAr;
  final MilestoneCategory category;
  final Phase phase;
  final String ageRange; // e.g., "M1", "2 mois", "6-10 mois"
  final String actionType; // "capsule" | "medical" | "celebration"
  final int orderInPhase;

  /// For calculating when milestone is due
  /// Relative to: pregnancy start (gestation), birth date (post-partum/enfance)
  final int? daysFromReference; // Optional: exact days from reference date
  final int? monthsFromReference; // Optional: months from reference

  const Milestone({
    required this.id,
    required this.titleFr,
    required this.titleAr,
    required this.descriptionFr,
    required this.descriptionAr,
    required this.category,
    required this.phase,
    required this.ageRange,
    required this.actionType,
    required this.orderInPhase,
    this.daysFromReference,
    this.monthsFromReference,
  });

  /// Get localized title
  String getTitle(String locale) => locale == 'ar' ? titleAr : titleFr;

  /// Get localized description
  String getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : titleFr;

  /// Check if this milestone is medical-related
  bool get isMedical => category == MilestoneCategory.sante;

  /// Check if this milestone can have a capsule
  bool get canHaveCapsule =>
      actionType == 'capsule' || actionType == 'celebration';
}

/// User's progress on a specific milestone
class MilestoneProgress {
  final String id;
  final String milestoneId;
  final String userId;
  final String childId;
  final MilestoneStatus status;
  final DateTime? completedAt;
  final String? capsuleId;
  final String? notes;

  const MilestoneProgress({
    required this.id,
    required this.milestoneId,
    required this.userId,
    required this.childId,
    required this.status,
    this.completedAt,
    this.capsuleId,
    this.notes,
  });

  factory MilestoneProgress.fromJson(Map<String, dynamic> json, String id) {
    return MilestoneProgress(
      id: id,
      milestoneId: json['milestoneId'] as String,
      userId: json['userId'] as String,
      childId: json['childId'] as String,
      status: MilestoneStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MilestoneStatus.pending,
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      capsuleId: json['capsuleId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'milestoneId': milestoneId,
    'userId': userId,
    'childId': childId,
    'status': status.name,
    'completedAt': completedAt?.toIso8601String(),
    'capsuleId': capsuleId,
    'notes': notes,
  };
}

/// Status of a milestone for a user
enum MilestoneStatus { pending, completed, skipped }
