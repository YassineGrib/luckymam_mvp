import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Status of a vaccine group for a specific child.
enum VaccineStatusType {
  /// Not yet due based on child's age
  upcoming,

  /// Due within the next 30 days
  dueSoon,

  /// Past due date but not completed
  overdue,

  /// Completed and recorded
  completed,
}

/// Represents the completion status of a vaccine group for a child.
@immutable
class VaccineStatus {
  const VaccineStatus({
    required this.vaccineGroupId,
    this.completedAt,
    this.notes,
  });

  final String vaccineGroupId;
  final DateTime? completedAt;
  final String? notes;

  bool get isCompleted => completedAt != null;

  factory VaccineStatus.fromFirestore(Map<String, dynamic> data, String id) {
    return VaccineStatus(
      vaccineGroupId: id,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'notes': notes,
    };
  }

  VaccineStatus copyWith({DateTime? completedAt, String? notes}) {
    return VaccineStatus(
      vaccineGroupId: vaccineGroupId,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Calculate the status type based on child's birth date and expected age
  static VaccineStatusType calculateStatus({
    required DateTime birthDate,
    required int ageMonths,
    required bool isCompleted,
  }) {
    if (isCompleted) return VaccineStatusType.completed;

    final now = DateTime.now();
    final expectedDate = DateTime(
      birthDate.year,
      birthDate.month + ageMonths,
      birthDate.day,
    );

    final daysUntilDue = expectedDate.difference(now).inDays;

    if (daysUntilDue < 0) {
      return VaccineStatusType.overdue;
    } else if (daysUntilDue <= 30) {
      return VaccineStatusType.dueSoon;
    } else {
      return VaccineStatusType.upcoming;
    }
  }
}
