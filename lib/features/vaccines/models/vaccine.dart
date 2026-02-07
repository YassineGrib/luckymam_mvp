import 'package:flutter/foundation.dart';

/// Represents a single vaccine in the Algerian national calendar.
@immutable
class Vaccine {
  const Vaccine({
    required this.code,
    required this.nameFr,
    required this.nameAr,
    required this.protectsFr,
    required this.protectsAr,
  });

  final String code;
  final String nameFr;
  final String nameAr;
  final String protectsFr;
  final String protectsAr;

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      code: json['code'] as String,
      nameFr: json['nameFr'] as String,
      nameAr: json['nameAr'] as String? ?? '',
      protectsFr: json['protectsFr'] as String,
      protectsAr: json['protectsAr'] as String? ?? '',
    );
  }

  /// Get localized name based on locale
  String getName(String locale) => locale == 'ar' ? nameAr : nameFr;

  /// Get localized protection info based on locale
  String getProtects(String locale) => locale == 'ar' ? protectsAr : protectsFr;
}

/// Represents a group of vaccines to be administered at a specific age.
@immutable
class VaccineGroup {
  const VaccineGroup({
    required this.id,
    required this.ageKey,
    required this.ageFr,
    required this.ageAr,
    required this.ageMonths,
    required this.vaccines,
    this.isRecurring = false,
    this.recurringIntervalMonths,
  });

  final String id;
  final String ageKey;
  final String ageFr;
  final String ageAr;
  final int ageMonths;
  final List<Vaccine> vaccines;
  final bool isRecurring;
  final int? recurringIntervalMonths;

  factory VaccineGroup.fromJson(Map<String, dynamic> json) {
    return VaccineGroup(
      id: json['id'] as String,
      ageKey: json['ageKey'] as String,
      ageFr: json['ageFr'] as String,
      ageAr: json['ageAr'] as String? ?? '',
      ageMonths: json['ageMonths'] as int,
      vaccines: (json['vaccines'] as List<dynamic>)
          .map((v) => Vaccine.fromJson(v as Map<String, dynamic>))
          .toList(),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringIntervalMonths: json['recurringIntervalMonths'] as int?,
    );
  }

  /// Get localized age label based on locale
  String getAgeLabel(String locale) => locale == 'ar' ? ageAr : ageFr;

  /// Get combined vaccine codes as a short label
  String get vaccineCodesLabel => vaccines.map((v) => v.code).join(' + ');

  /// Calculate the expected date for this vaccine group based on birth date
  DateTime getExpectedDate(DateTime birthDate) {
    return DateTime(birthDate.year, birthDate.month + ageMonths, birthDate.day);
  }
}

/// Container for the entire vaccine calendar data.
@immutable
class VaccineCalendar {
  const VaccineCalendar({
    required this.version,
    required this.country,
    required this.language,
    required this.groups,
  });

  final String version;
  final String country;
  final String language;
  final List<VaccineGroup> groups;

  factory VaccineCalendar.fromJson(Map<String, dynamic> json) {
    return VaccineCalendar(
      version: json['version'] as String? ?? '1.0',
      country: json['country'] as String? ?? 'DZ',
      language: json['language'] as String? ?? 'fr',
      groups: (json['vaccines'] as List<dynamic>)
          .map((g) => VaccineGroup.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }
}
