import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile status enumeration.
enum UserStatus {
  pregnant, // Enceinte
  mom, // Maman
}

/// Child gender enumeration.
enum ChildGender {
  boy, // Garçon
  girl, // Fille
}

/// Child data model.
class Child {
  final String id;
  final String name;
  final DateTime birthDate;
  final ChildGender gender;
  final String? photoUrl;

  const Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
  });

  /// Create from Firestore document.
  factory Child.fromFirestore(Map<String, dynamic> data, String id) {
    return Child(
      id: id,
      name: data['name'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      gender: ChildGender.values.firstWhere(
        (g) => g.name == data['gender'],
        orElse: () => ChildGender.boy,
      ),
      photoUrl: data['photoUrl'],
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender.name,
      'photoUrl': photoUrl,
    };
  }

  /// Display label for gender.
  String get genderLabel => gender == ChildGender.girl ? 'Fille' : 'Garçon';

  /// Calculate age string.
  String get ageString {
    final now = DateTime.now();
    final months =
        (now.year - birthDate.year) * 12 + now.month - birthDate.month;

    if (months < 12) {
      return '$months mois';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years an${years > 1 ? 's' : ''}';
      }
      return '$years an${years > 1 ? 's' : ''} $remainingMonths mois';
    }
  }

  Child copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    ChildGender? gender,
    String? photoUrl,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

/// Medical information model.
class MedicalInfo {
  final String? bloodType;
  final List<String> allergies;
  final List<String> conditions;
  final String? doctorName;
  final String? doctorPhone;

  const MedicalInfo({
    this.bloodType,
    this.allergies = const [],
    this.conditions = const [],
    this.doctorName,
    this.doctorPhone,
  });

  factory MedicalInfo.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const MedicalInfo();
    return MedicalInfo(
      bloodType: data['bloodType'],
      allergies: List<String>.from(data['allergies'] ?? []),
      conditions: List<String>.from(data['conditions'] ?? []),
      doctorName: data['doctorName'],
      doctorPhone: data['doctorPhone'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bloodType': bloodType,
      'allergies': allergies,
      'conditions': conditions,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
    };
  }

  MedicalInfo copyWith({
    String? bloodType,
    List<String>? allergies,
    List<String>? conditions,
    String? doctorName,
    String? doctorPhone,
  }) {
    return MedicalInfo(
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
    );
  }
}

/// Menstrual cycle information model.
class CycleInfo {
  final DateTime? lastPeriodDate;
  final int cycleLength;
  final int periodDuration;
  final bool isTracking;

  const CycleInfo({
    this.lastPeriodDate,
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.isTracking = false,
  });

  factory CycleInfo.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const CycleInfo();
    return CycleInfo(
      lastPeriodDate: data['lastPeriodDate'] != null
          ? (data['lastPeriodDate'] as Timestamp).toDate()
          : null,
      cycleLength: data['cycleLength'] ?? 28,
      periodDuration: data['periodDuration'] ?? 5,
      isTracking: data['isTracking'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lastPeriodDate': lastPeriodDate != null
          ? Timestamp.fromDate(lastPeriodDate!)
          : null,
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'isTracking': isTracking,
    };
  }

  /// Calculate current cycle day.
  int get currentDay {
    if (lastPeriodDate == null) return 0;
    return DateTime.now().difference(lastPeriodDate!).inDays % cycleLength + 1;
  }

  /// Get current phase of cycle.
  String get currentPhase {
    final day = currentDay;
    if (day <= periodDuration) return 'Règles';
    if (day <= 13) return 'Phase Folliculaire';
    if (day <= 16) return 'Phase Ovulatoire';
    return 'Phase Lutéale';
  }

  /// Calculate next period date.
  DateTime? get nextPeriodDate {
    if (lastPeriodDate == null) return null;
    final daysSinceLast = DateTime.now().difference(lastPeriodDate!).inDays;
    final daysUntilNext = cycleLength - (daysSinceLast % cycleLength);
    return DateTime.now().add(Duration(days: daysUntilNext));
  }

  CycleInfo copyWith({
    DateTime? lastPeriodDate,
    int? cycleLength,
    int? periodDuration,
    bool? isTracking,
  }) {
    return CycleInfo(
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

/// Main user profile model.
class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? wilaya;
  final UserStatus status;
  final DateTime? lastPregnancyDate;
  final MedicalInfo medicalInfo;
  final CycleInfo cycleInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.phone,
    this.photoUrl,
    this.birthDate,
    this.wilaya,
    this.status = UserStatus.mom,
    this.lastPregnancyDate,
    this.medicalInfo = const MedicalInfo(),
    this.cycleInfo = const CycleInfo(),
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'],
      email: data['email'],
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      wilaya: data['wilaya'],
      status: UserStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => UserStatus.mom,
      ),
      lastPregnancyDate: data['lastPregnancyDate'] != null
          ? (data['lastPregnancyDate'] as Timestamp).toDate()
          : null,
      medicalInfo: MedicalInfo.fromFirestore(data['medicalInfo']),
      cycleInfo: CycleInfo.fromFirestore(data['cycleInfo']),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'wilaya': wilaya,
      'status': status.name,
      'lastPregnancyDate': lastPregnancyDate != null
          ? Timestamp.fromDate(lastPregnancyDate!)
          : null,
      'medicalInfo': medicalInfo.toFirestore(),
      'cycleInfo': cycleInfo.toFirestore(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Status display label.
  String get statusLabel =>
      status == UserStatus.pregnant ? 'Enceinte' : 'Maman';

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? birthDate,
    String? wilaya,
    UserStatus? status,
    DateTime? lastPregnancyDate,
    MedicalInfo? medicalInfo,
    CycleInfo? cycleInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      wilaya: wilaya ?? this.wilaya,
      status: status ?? this.status,
      lastPregnancyDate: lastPregnancyDate ?? this.lastPregnancyDate,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      cycleInfo: cycleInfo ?? this.cycleInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
