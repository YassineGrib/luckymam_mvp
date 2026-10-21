import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a pregnancy.
enum PregnancyStatus {
  active,
  delivered,
  ended,
}

/// Source of the estimated due date calculation.
enum EddSource {
  lmp,
  ultrasound,
  doctor,
}

/// Pregnancy model representing an active, delivered, or ended pregnancy.
class Pregnancy {
  final String id;
  final DateTime lmpDate;
  final DateTime eddDate;
  final EddSource eddSource;
  final int babyCount;
  final List<String> childIds;
  final PregnancyStatus status;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Pregnancy({
    required this.id,
    required this.lmpDate,
    required this.eddDate,
    this.eddSource = EddSource.lmp,
    this.babyCount = 1,
    this.childIds = const [],
    this.status = PregnancyStatus.active,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computes the estimated due date (EDD) from the last menstrual period (LMP)
  /// by adding 280 calendar days, returning a date-only DateTime.
  static DateTime eddFromLmp(DateTime lmp) {
    return DateTime(lmp.year, lmp.month, lmp.day + 280);
  }

  /// Calculates the integer number of calendar days between two dates.
  static int _calendarDaysBetween(DateTime from, DateTime to) {
    final fromUtc = DateTime.utc(from.year, from.month, from.day);
    final toUtc = DateTime.utc(to.year, to.month, to.day);
    return toUtc.difference(fromUtc).inDays;
  }

  /// Completed weeks since LMP, clamped to 0..42.
  int gestationalWeek(DateTime now) {
    final diffDays = _calendarDaysBetween(lmpDate, now);
    if (diffDays <= 0) return 0;
    final weeks = diffDays ~/ 7;
    return weeks.clamp(0, 42);
  }

  /// Day within current gestational week (0..6).
  int gestationalDay(DateTime now) {
    final diffDays = _calendarDaysBetween(lmpDate, now);
    if (diffDays <= 0) return 0;
    return diffDays % 7;
  }

  /// Days until the estimated due date (can be negative if overdue).
  int daysUntilDue(DateTime now) {
    return _calendarDaysBetween(now, eddDate);
  }

  /// Current trimester: 1 (weeks 0–13), 2 (14–27), 3 (28+).
  int trimester(DateTime now) {
    final week = gestationalWeek(now);
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  /// Whether the pregnancy is currently active.
  bool get isActive => status == PregnancyStatus.active;

  /// Creates a Pregnancy instance from Firestore document data.
  factory Pregnancy.fromFirestore(Map<String, dynamic> data, String id) {
    final lmp = data['lmpDate'] is Timestamp
        ? (data['lmpDate'] as Timestamp).toDate()
        : (data['lmpDate'] is DateTime
            ? data['lmpDate'] as DateTime
            : DateTime.now());

    final edd = data['eddDate'] is Timestamp
        ? (data['eddDate'] as Timestamp).toDate()
        : (data['eddDate'] is DateTime
            ? data['eddDate'] as DateTime
            : Pregnancy.eddFromLmp(lmp));

    final eddSource = EddSource.values.firstWhere(
      (e) => e.name == data['eddSource'],
      orElse: () => EddSource.lmp,
    );

    final babyCount = (data['babyCount'] as num?)?.toInt() ?? 1;

    final childIds = (data['childIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    final status = PregnancyStatus.values.firstWhere(
      (s) => s.name == data['status'],
      orElse: () => PregnancyStatus.active,
    );

    final endedAt = data['endedAt'] is Timestamp
        ? (data['endedAt'] as Timestamp).toDate()
        : (data['endedAt'] is DateTime ? data['endedAt'] as DateTime : null);

    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : (data['createdAt'] is DateTime
            ? data['createdAt'] as DateTime
            : DateTime.now());

    final updatedAt = data['updatedAt'] is Timestamp
        ? (data['updatedAt'] as Timestamp).toDate()
        : (data['updatedAt'] is DateTime
            ? data['updatedAt'] as DateTime
            : DateTime.now());

    return Pregnancy(
      id: id,
      lmpDate: lmp,
      eddDate: edd,
      eddSource: eddSource,
      babyCount: babyCount,
      childIds: childIds,
      status: status,
      endedAt: endedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts this Pregnancy instance into a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'lmpDate': Timestamp.fromDate(lmpDate),
      'eddDate': Timestamp.fromDate(eddDate),
      'eddSource': eddSource.name,
      'babyCount': babyCount,
      'childIds': childIds,
      'status': status.name,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy with the given fields replaced.
  Pregnancy copyWith({
    String? id,
    DateTime? lmpDate,
    DateTime? eddDate,
    EddSource? eddSource,
    int? babyCount,
    List<String>? childIds,
    PregnancyStatus? status,
    DateTime? endedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pregnancy(
      id: id ?? this.id,
      lmpDate: lmpDate ?? this.lmpDate,
      eddDate: eddDate ?? this.eddDate,
      eddSource: eddSource ?? this.eddSource,
      babyCount: babyCount ?? this.babyCount,
      childIds: childIds ?? this.childIds,
      status: status ?? this.status,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pregnancy &&
        other.id == id &&
        other.lmpDate == lmpDate &&
        other.eddDate == eddDate &&
        other.eddSource == eddSource &&
        other.babyCount == babyCount &&
        _listEquals(other.childIds, childIds) &&
        other.status == status &&
        other.endedAt == endedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        lmpDate,
        eddDate,
        eddSource,
        babyCount,
        Object.hashAll(childIds),
        status,
        endedAt,
        createdAt,
        updatedAt,
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
