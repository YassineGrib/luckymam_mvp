import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentType {
  generaliste,
  pediatre,
  dentiste,
  ophtalmologue,
  cardiologue,
  autre;

  String get labelFr => switch (this) {
    AppointmentType.generaliste => 'Médecin généraliste',
    AppointmentType.pediatre => 'Pédiatre',
    AppointmentType.dentiste => 'Dentiste',
    AppointmentType.ophtalmologue => 'Ophtalmologue',
    AppointmentType.cardiologue => 'Cardiologue',
    AppointmentType.autre => 'Autre spécialiste',
  };
}

/// A medical appointment record with optional attached files.
class Appointment {
  const Appointment({
    required this.id,
    required this.childId,
    required this.date,
    required this.doctorName,
    required this.type,
    this.notes,
    this.fileUrls = const [],
    required this.createdAt,
  });

  final String id;
  final String childId;
  final DateTime date;
  final String doctorName;
  final AppointmentType type;
  final String? notes;

  /// Firebase Storage download URLs for attached files (images / PDFs).
  final List<String> fileUrls;

  final DateTime createdAt;

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      childId: data['childId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      doctorName: data['doctorName'] as String,
      type: AppointmentType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AppointmentType.autre,
      ),
      notes: data['notes'] as String?,
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'childId': childId,
    'date': Timestamp.fromDate(date),
    'doctorName': doctorName,
    'type': type.name,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'fileUrls': fileUrls,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Appointment copyWith({
    String? doctorName,
    AppointmentType? type,
    String? notes,
    List<String>? fileUrls,
  }) => Appointment(
    id: id,
    childId: childId,
    date: date,
    doctorName: doctorName ?? this.doctorName,
    type: type ?? this.type,
    notes: notes ?? this.notes,
    fileUrls: fileUrls ?? this.fileUrls,
    createdAt: createdAt,
  );
}
