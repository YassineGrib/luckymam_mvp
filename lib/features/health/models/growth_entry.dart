import 'package:cloud_firestore/cloud_firestore.dart';

/// A single weight / height measurement for a child.
class GrowthEntry {
  const GrowthEntry({
    required this.id,
    required this.childId,
    required this.date,
    this.weightKg,
    this.heightCm,
    this.notes,
    required this.createdAt,
  }) : assert(
         weightKg != null || heightCm != null,
         'At least one measurement is required',
       );

  final String id;
  final String childId;
  final DateTime date;

  /// Weight in kilograms (nullable — can log height only).
  final double? weightKg;

  /// Height in centimetres (nullable — can log weight only).
  final double? heightCm;

  final String? notes;
  final DateTime createdAt;

  factory GrowthEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GrowthEntry(
      id: doc.id,
      childId: data['childId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'childId': childId,
    'date': Timestamp.fromDate(date),
    if (weightKg != null) 'weightKg': weightKg,
    if (heightCm != null) 'heightCm': heightCm,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  GrowthEntry copyWith({double? weightKg, double? heightCm, String? notes}) =>
      GrowthEntry(
        id: id,
        childId: childId,
        date: date,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
