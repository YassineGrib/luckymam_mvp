import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// User profile status enumeration.
enum UserStatus {
  pregnant, // Enceinte
  mom,      // Maman
  hope,     // Souhaite être enceinte
}

/// Child gender enumeration.
enum ChildGender {
  boy, // Garçon
  girl, // Fille
  unknown, // Surprise / genre non connu
}

/// Child lifecycle enumeration.
enum ChildLifecycle {
  expected, // À naître -- birthDate holds the EDD
  born,     // Né(e)
}

/// Child data model.
class Child {
  final String id;
  final String name;

  /// For born children: the date of birth.
  /// For expected children: the expected delivery date (EDD); Firestore stores
  /// birthDate: null + expectedDate for these.
  final DateTime birthDate;
  final ChildGender gender;
  final ChildLifecycle lifecycle;
  final DateTime? expectedDate;
  final String? pregnancyId;
  final bool archived;
  final String? photoUrl;
  final String? bloodType;
  final String? themeColorHex;
  final String? notes;

  const Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.lifecycle = ChildLifecycle.born,
    this.expectedDate,
    this.pregnancyId,
    this.archived = false,
    this.photoUrl,
    this.bloodType,
    this.themeColorHex,
    this.notes,
  });

  bool get isExpected => lifecycle == ChildLifecycle.expected;
  bool get isBorn => lifecycle == ChildLifecycle.born;

  /// Create from Firestore document.
  factory Child.fromFirestore(Map<String, dynamic> data, String id) {
    final lifecycle = ChildLifecycle.values.firstWhere(
      (l) => l.name == data['lifecycle'],
      orElse: () => ChildLifecycle.born,
    );

    final DateTime birthDate;
    if (data['birthDate'] != null) {
      birthDate = (data['birthDate'] as Timestamp).toDate();
    } else if (data['expectedDate'] != null) {
      birthDate = (data['expectedDate'] as Timestamp).toDate();
    } else {
      birthDate = DateTime.now();
    }

    final DateTime? expectedDate = data['expectedDate'] != null
        ? (data['expectedDate'] as Timestamp).toDate()
        : (lifecycle == ChildLifecycle.expected && data['birthDate'] != null
            ? birthDate
            : null);

    return Child(
      id: id,
      name: data['name'] ?? '',
      birthDate: birthDate,
      gender: ChildGender.values.firstWhere(
        (g) => g.name == data['gender'],
        orElse: () => ChildGender.unknown,
      ),
      lifecycle: lifecycle,
      expectedDate: expectedDate,
      pregnancyId: data['pregnancyId'] as String?,
      archived: (data['archived'] as bool?) ?? false,
      photoUrl: data['photoUrl'],
      bloodType: data['bloodType'] as String?,
      themeColorHex: data['themeColorHex'] as String?,
      notes: data['notes'] as String?,
    );
  }

  /// Convert to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'birthDate': isExpected ? null : Timestamp.fromDate(birthDate),
      'gender': gender.name,
      'lifecycle': lifecycle.name,
      if (expectedDate != null || isExpected)
        'expectedDate': Timestamp.fromDate(expectedDate ?? birthDate),
      if (pregnancyId != null) 'pregnancyId': pregnancyId,
      'archived': archived,
      'photoUrl': photoUrl,
      if (bloodType != null) 'bloodType': bloodType,
      if (themeColorHex != null) 'themeColorHex': themeColorHex,
      if (notes != null) 'notes': notes,
    };
  }

  /// Display label for gender (legacy French getter).
  String get genderLabel {
    switch (gender) {
      case ChildGender.girl:
        return 'Fille';
      case ChildGender.boy:
        return 'Garçon';
      case ChildGender.unknown:
        return 'Surprise';
    }
  }

  /// Calculate age string (legacy French getter — the one allowed hardcoded exception).
  String get ageString {
    if (isExpected) {
      final now = DateTime.now();
      final days = birthDate.difference(now).inDays;
      final weeks = (days / 7).ceil().clamp(0, 999);
      if (weeks == 0) {
        return "Naissance prévue aujourd'hui";
      }
      return 'Naissance prévue dans $weeks sem.';
    }
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

  /// Resolves the child's customized theme color or falls back to gender defaults.
  Color get themeColor {
    if (themeColorHex != null && themeColorHex!.isNotEmpty) {
      try {
        final clean = themeColorHex!.replaceAll('#', '').trim();
        if (clean.length == 6) {
          return Color(int.parse('FF$clean', radix: 16));
        } else if (clean.length == 8) {
          return Color(int.parse(clean, radix: 16));
        }
      } catch (_) {}
    }
    switch (gender) {
      case ChildGender.boy:
        return const Color(0xFF00B0FF);
      case ChildGender.girl:
        return const Color(0xFFFF5252);
      case ChildGender.unknown:
        return AppColors.goldenrod;
    }
  }

  Child copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    ChildGender? gender,
    ChildLifecycle? lifecycle,
    DateTime? expectedDate,
    String? pregnancyId,
    bool? archived,
    String? photoUrl,
    String? bloodType,
    String? themeColorHex,
    String? notes,
  }) {
    return Child(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      lifecycle: lifecycle ?? this.lifecycle,
      expectedDate: expectedDate ?? this.expectedDate,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      archived: archived ?? this.archived,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodType: bloodType ?? this.bloodType,
      themeColorHex: themeColorHex ?? this.themeColorHex,
      notes: notes ?? this.notes,
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
  final bool? consent1807;
  final DateTime? consent1807Timestamp;
  final String? consent1807TextVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool tryingToConceive;
  final int schemaVersion;

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
    this.consent1807,
    this.consent1807Timestamp,
    this.consent1807TextVersion,
    required this.createdAt,
    required this.updatedAt,
    this.tryingToConceive = false,
    this.schemaVersion = 1,
  });

  /// Create from Firestore document.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return fromMap(data, doc.id);
  }

  /// Create from raw data map and uid.
  static UserProfile fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
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
      consent1807: data['consent1807'] as bool?,
      consent1807Timestamp: data['consent1807Timestamp'] != null
          ? (data['consent1807Timestamp'] as Timestamp).toDate()
          : null,
      consent1807TextVersion: data['consent1807TextVersion'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      tryingToConceive: (data['tryingToConceive'] as bool?) ?? false,
      schemaVersion: (data['schemaVersion'] as int?) ?? 1,
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
      'consent1807': consent1807,
      'consent1807Timestamp': consent1807Timestamp != null
          ? Timestamp.fromDate(consent1807Timestamp!)
          : null,
      'consent1807TextVersion': consent1807TextVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'tryingToConceive': tryingToConceive,
      'schemaVersion': schemaVersion,
    };
  }

  /// Status display label.
  String get statusLabel {
    switch (status) {
      case UserStatus.pregnant:
        return 'Enceinte';
      case UserStatus.hope:
        return 'En espoir';
      case UserStatus.mom:
        return 'Maman';
    }
  }

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
    bool? consent1807,
    DateTime? consent1807Timestamp,
    String? consent1807TextVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? tryingToConceive,
    int? schemaVersion,
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
      consent1807: consent1807 ?? this.consent1807,
      consent1807Timestamp: consent1807Timestamp ?? this.consent1807Timestamp,
      consent1807TextVersion: consent1807TextVersion ?? this.consent1807TextVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tryingToConceive: tryingToConceive ?? this.tryingToConceive,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }
}
