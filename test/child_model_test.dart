import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/extensions/profile_l10n_extension.dart';
import 'package:lukymam_mvp/core/theme/app_colors.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/l10n/app_localizations_ar.dart';
import 'package:lukymam_mvp/l10n/app_localizations_en.dart';
import 'package:lukymam_mvp/l10n/app_localizations_fr.dart';

Timestamp ts(int year, int month, int day) =>
    Timestamp.fromDate(DateTime(year, month, day));

Child _child({
  ChildGender gender = ChildGender.boy,
  ChildLifecycle lifecycle = ChildLifecycle.born,
  DateTime? birthDate,
  DateTime? expectedDate,
  String? pregnancyId,
  bool archived = false,
}) {
  return Child(
    id: 'test_id',
    name: 'Test',
    birthDate: birthDate ?? DateTime(2024, 1, 1),
    gender: gender,
    lifecycle: lifecycle,
    expectedDate: expectedDate,
    pregnancyId: pregnancyId,
    archived: archived,
  );
}

void main() {
  group('ChildGender defaults', () {
    test('legacy gender null falls back to unknown', () {
      final c = Child.fromFirestore(
        {'name': 'A', 'birthDate': ts(2024, 1, 1), 'gender': null},
        'id',
      );
      expect(c.gender, ChildGender.unknown);
      expect(c.lifecycle, ChildLifecycle.born);
    });

    test('legacy boy/girl still parse', () {
      final g = Child.fromFirestore(
        {'name': 'B', 'birthDate': ts(2024, 1, 1), 'gender': 'girl'},
        'id',
      );
      expect(g.gender, ChildGender.girl);

      final b = Child.fromFirestore(
        {'name': 'C', 'birthDate': ts(2024, 1, 1), 'gender': 'boy'},
        'id',
      );
      expect(b.gender, ChildGender.boy);
    });

    test('unknown gender string parses to unknown', () {
      final c = Child.fromFirestore(
        {'name': 'D', 'birthDate': ts(2024, 1, 1), 'gender': 'unknown'},
        'id',
      );
      expect(c.gender, ChildGender.unknown);
    });

    test('invalid gender string falls back to unknown (not boy)', () {
      final c = Child.fromFirestore(
        {'name': 'E', 'birthDate': ts(2024, 1, 1), 'gender': 'invalid_val'},
        'id',
      );
      expect(c.gender, ChildGender.unknown);
    });
  });

  group('ChildLifecycle — expected child', () {
    test('expected child uses expectedDate as birthDate and writes null birthDate', () {
      final c = Child.fromFirestore(
        {
          'name': 'Bébé',
          'birthDate': null,
          'expectedDate': ts(2027, 1, 10),
          'lifecycle': 'expected',
          'gender': 'unknown',
          'pregnancyId': 'p1',
        },
        'id',
      );
      expect(c.isExpected, isTrue);
      expect(c.isBorn, isFalse);
      expect(c.birthDate, DateTime(2027, 1, 10));
      expect(c.toFirestore()['birthDate'], isNull);
      expect(c.toFirestore()['lifecycle'], 'expected');
      expect(c.toFirestore()['expectedDate'], isA<Timestamp>());
      expect(c.pregnancyId, 'p1');
    });

    test('missing lifecycle defaults to born', () {
      final c = Child.fromFirestore(
        {'name': 'F', 'birthDate': ts(2024, 1, 1)},
        'id',
      );
      expect(c.lifecycle, ChildLifecycle.born);
      expect(c.isBorn, isTrue);
    });

    test('both birthDate and expectedDate null falls back to DateTime.now() defensively', () {
      final before = DateTime.now();
      final c = Child.fromFirestore(
        {'name': 'G', 'birthDate': null, 'lifecycle': 'expected'},
        'id',
      );
      final after = DateTime.now();
      expect(
        c.birthDate.isAtSameMomentAs(before) ||
            c.birthDate.isAfter(before) ||
            c.birthDate.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('born child with lifecycle field explicit', () {
      final c = Child.fromFirestore(
        {
          'name': 'H',
          'birthDate': ts(2024, 6, 1),
          'lifecycle': 'born',
          'gender': 'girl',
        },
        'id',
      );
      expect(c.lifecycle, ChildLifecycle.born);
      expect(c.gender, ChildGender.girl);
      expect(c.toFirestore()['lifecycle'], 'born');
    });
  });

  group('Child.themeColor — unknown gender', () {
    test('unknown gender gets goldenrod colour', () {
      final c = _child(gender: ChildGender.unknown);
      expect(c.themeColor, AppColors.goldenrod);
    });

    test('boy gets blue colour', () {
      final c = _child(gender: ChildGender.boy);
      expect(c.themeColor, const Color(0xFF00B0FF));
    });

    test('girl gets red colour', () {
      final c = _child(gender: ChildGender.girl);
      expect(c.themeColor, const Color(0xFFFF5252));
    });

    test('custom hex overrides gender colour for unknown', () {
      final c = _child(gender: ChildGender.unknown).copyWith(themeColorHex: '#FF0000');
      expect(c.themeColor, const Color(0xFFFF0000));
    });
  });

  group('Child.ageString — expected child (legacy French getter)', () {
    test('expected child shows weeks-until', () {
      final edd = DateTime.now().add(const Duration(days: 21));
      final c = _child(
        lifecycle: ChildLifecycle.expected,
        birthDate: edd,
        gender: ChildGender.unknown,
      );
      expect(c.ageString, contains('Naissance prévue'));
    });

    test('expected child due today shows today copy', () {
      final c = _child(
        lifecycle: ChildLifecycle.expected,
        birthDate: DateTime.now(),
        gender: ChildGender.unknown,
      );
      expect(c.ageString, contains('aujourd\'hui'));
    });

    test('born child ageString still works', () {
      final c = _child(
        birthDate: DateTime.now().subtract(const Duration(days: 60)),
      );
      // 2 months old — should contain "mois"
      expect(c.ageString, contains('mois'));
    });
  });

  group('Child.copyWith new fields', () {
    test('copyWith preserves new fields when not overridden', () {
      final original = _child(
        lifecycle: ChildLifecycle.expected,
        expectedDate: DateTime(2027, 3, 1),
        pregnancyId: 'p2',
        archived: false,
      );
      final copy = original.copyWith(name: 'Updated');
      expect(copy.lifecycle, ChildLifecycle.expected);
      expect(copy.expectedDate, DateTime(2027, 3, 1));
      expect(copy.pregnancyId, 'p2');
      expect(copy.archived, isFalse);
    });

    test('copyWith can change lifecycle', () {
      final c = _child(lifecycle: ChildLifecycle.expected).copyWith(
        lifecycle: ChildLifecycle.born,
      );
      expect(c.lifecycle, ChildLifecycle.born);
    });

    test('copyWith can set archived', () {
      final c = _child().copyWith(archived: true);
      expect(c.archived, isTrue);
    });
  });

  group('Child.toFirestore round-trip', () {
    test('toFirestore writes pregnancyId when present', () {
      final c = _child(pregnancyId: 'preg_abc');
      final map = c.toFirestore();
      expect(map['pregnancyId'], 'preg_abc');
    });

    test('toFirestore does not write pregnancyId when absent', () {
      final c = _child();
      final map = c.toFirestore();
      expect(map.containsKey('pregnancyId'), isFalse);
    });

    test('born child toFirestore has non-null birthDate', () {
      final c = _child(birthDate: DateTime(2024, 5, 5));
      final map = c.toFirestore();
      expect(map['birthDate'], isA<Timestamp>());
    });
  });

  group('Child.genderLabel legacy French getter', () {
    test('returns Garçon, Fille, Surprise', () {
      expect(_child(gender: ChildGender.boy).genderLabel, 'Garçon');
      expect(_child(gender: ChildGender.girl).genderLabel, 'Fille');
      expect(_child(gender: ChildGender.unknown).genderLabel, 'Surprise');
    });
  });

  group('profile_l10n_extension — localized gender label', () {
    final fr = AppLocalizationsFr();
    final ar = AppLocalizationsAr();
    final en = AppLocalizationsEn();

    test('childGenderLabel returns localized labels', () {
      expect(childGenderLabel(fr, ChildGender.unknown), 'Surprise');
      expect(childGenderLabel(ar, ChildGender.unknown), 'مفاجأة');
      expect(childGenderLabel(en, ChildGender.unknown), 'Surprise');

      expect(childGenderLabel(fr, ChildGender.boy), fr.profileBoy);
      expect(childGenderLabel(fr, ChildGender.girl), fr.profileGirl);
    });

    test('Child.localizedGenderLabel extension works across locales', () {
      final cUnknown = _child(gender: ChildGender.unknown);
      expect(cUnknown.localizedGenderLabel(fr), 'Surprise');
      expect(cUnknown.localizedGenderLabel(ar), 'مفاجأة');
      expect(cUnknown.localizedGenderLabel(en), 'Surprise');

      final cGirl = _child(gender: ChildGender.girl);
      expect(cGirl.localizedGenderLabel(fr), fr.profileGirl);
      expect(cGirl.localizedGenderLabel(ar), ar.profileGirl);
      expect(cGirl.localizedGenderLabel(en), en.profileGirl);
    });
  });

  group('profile_l10n_extension — localized age string', () {
    final fr = AppLocalizationsFr();
    final ar = AppLocalizationsAr();
    final en = AppLocalizationsEn();

    test('expected child due in weeks formats correctly in fr, ar, en', () {
      final edd = DateTime.now().add(const Duration(days: 21));
      final c = _child(
        lifecycle: ChildLifecycle.expected,
        birthDate: edd,
        gender: ChildGender.unknown,
      );

      expect(c.localizedAgeString(fr), contains('3 sem.'));
      expect(c.localizedAgeString(ar), contains('3 أسابيع'));
      expect(c.localizedAgeString(en), contains('3 weeks'));
    });

    test('expected child due today formats correctly in fr, ar, en', () {
      final today = DateTime.now();
      final c = _child(
        lifecycle: ChildLifecycle.expected,
        birthDate: today,
        gender: ChildGender.unknown,
      );

      expect(c.localizedAgeString(fr), "Naissance prévue aujourd'hui");
      expect(c.localizedAgeString(ar), "الولادة متوقعة اليوم");
      expect(c.localizedAgeString(en), "Due today");
    });

    test('born child localizedAgeString formats normally', () {
      final born = DateTime.now().subtract(const Duration(days: 60));
      final c = _child(
        lifecycle: ChildLifecycle.born,
        birthDate: born,
      );

      expect(c.localizedAgeString(fr), contains('mois'));
      expect(c.localizedAgeString(ar), contains('شهر'));
      expect(c.localizedAgeString(en), contains('months'));
    });

    test('childExpectedDefaultName exists across fr, ar, en', () {
      expect(fr.childExpectedDefaultName, 'Bébé');
      expect(ar.childExpectedDefaultName, 'بيبي');
      expect(en.childExpectedDefaultName, 'Baby');
    });
  });
}
