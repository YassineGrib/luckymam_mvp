import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';

void main() {
  group('MotherStage derivation (Spec §1.1)', () {
    test('A: exploring — 0 born children, no active pregnancy, not TTC', () {
      final s = deriveMotherStage(
        bornChildren: 0,
        hasActivePregnancy: false,
        tryingToConceive: false,
      );
      expect(s, MotherStage.exploring);
      expect(s.isPregnant, isFalse);
      expect(s.hasChildren, isFalse);
      expect(s.tracksCycle, isFalse);
      expect(s.legacyStatus, UserStatus.hope);
    });

    test('B: hope — 0 born children, no active pregnancy, TTC', () {
      final s = deriveMotherStage(
        bornChildren: 0,
        hasActivePregnancy: false,
        tryingToConceive: true,
      );
      expect(s, MotherStage.hope);
      expect(s.isPregnant, isFalse);
      expect(s.hasChildren, isFalse);
      expect(s.tracksCycle, isTrue);
      expect(s.legacyStatus, UserStatus.hope);
    });

    test('C: pregnantFirst — 0 born children, active pregnancy, TTC ignored', () {
      final sFalse = deriveMotherStage(
        bornChildren: 0,
        hasActivePregnancy: true,
        tryingToConceive: false,
      );
      expect(sFalse, MotherStage.pregnantFirst);
      expect(sFalse.isPregnant, isTrue);
      expect(sFalse.hasChildren, isFalse);
      expect(sFalse.tracksCycle, isFalse);
      expect(sFalse.legacyStatus, UserStatus.pregnant);

      final sTrue = deriveMotherStage(
        bornChildren: 0,
        hasActivePregnancy: true,
        tryingToConceive: true,
      );
      expect(sTrue, MotherStage.pregnantFirst);
    });

    test('D: pregnant with children — ≥1 born children, active pregnancy', () {
      final s = deriveMotherStage(
        bornChildren: 2,
        hasActivePregnancy: true,
        tryingToConceive: true,
      );
      expect(s, MotherStage.pregnantWithChildren);
      expect(s.isPregnant, isTrue);
      expect(s.hasChildren, isTrue);
      expect(s.tracksCycle, isFalse);
      expect(s.legacyStatus, UserStatus.pregnant);

      final sNotTtc = deriveMotherStage(
        bornChildren: 1,
        hasActivePregnancy: true,
        tryingToConceive: false,
      );
      expect(sNotTtc, MotherStage.pregnantWithChildren);
    });

    test('E: mom — ≥1 born children, no active pregnancy, not TTC', () {
      final s = deriveMotherStage(
        bornChildren: 1,
        hasActivePregnancy: false,
        tryingToConceive: false,
      );
      expect(s, MotherStage.mom);
      expect(s.isPregnant, isFalse);
      expect(s.hasChildren, isTrue);
      expect(s.tracksCycle, isFalse);
      expect(s.legacyStatus, UserStatus.mom);
    });

    test('F: momHope — ≥1 born children, no active pregnancy, TTC', () {
      final s = deriveMotherStage(
        bornChildren: 1,
        hasActivePregnancy: false,
        tryingToConceive: true,
      );
      expect(s, MotherStage.momHope);
      expect(s.isPregnant, isFalse);
      expect(s.hasChildren, isTrue);
      expect(s.tracksCycle, isTrue);
      expect(s.legacyStatus, UserStatus.mom);
    });

    test('edge case: negative bornChildren clamps safely to 0', () {
      final s = deriveMotherStage(
        bornChildren: -1,
        hasActivePregnancy: false,
        tryingToConceive: false,
      );
      expect(s, MotherStage.exploring);
    });
  });

  group('MotherStage getters exhaustiveness', () {
    test('isPregnant is true only for pregnantFirst and pregnantWithChildren', () {
      expect(MotherStage.exploring.isPregnant, isFalse);
      expect(MotherStage.hope.isPregnant, isFalse);
      expect(MotherStage.pregnantFirst.isPregnant, isTrue);
      expect(MotherStage.pregnantWithChildren.isPregnant, isTrue);
      expect(MotherStage.mom.isPregnant, isFalse);
      expect(MotherStage.momHope.isPregnant, isFalse);
    });

    test('hasChildren is true only for pregnantWithChildren, mom, and momHope', () {
      expect(MotherStage.exploring.hasChildren, isFalse);
      expect(MotherStage.hope.hasChildren, isFalse);
      expect(MotherStage.pregnantFirst.hasChildren, isFalse);
      expect(MotherStage.pregnantWithChildren.hasChildren, isTrue);
      expect(MotherStage.mom.hasChildren, isTrue);
      expect(MotherStage.momHope.hasChildren, isTrue);
    });

    test('tracksCycle is true only for hope and momHope', () {
      expect(MotherStage.exploring.tracksCycle, isFalse);
      expect(MotherStage.hope.tracksCycle, isTrue);
      expect(MotherStage.pregnantFirst.tracksCycle, isFalse);
      expect(MotherStage.pregnantWithChildren.tracksCycle, isFalse);
      expect(MotherStage.mom.tracksCycle, isFalse);
      expect(MotherStage.momHope.tracksCycle, isTrue);
    });

    test('legacyStatus maps pregnant* to pregnant, hope/exploring to hope, mom* to mom', () {
      expect(MotherStage.exploring.legacyStatus, UserStatus.hope);
      expect(MotherStage.hope.legacyStatus, UserStatus.hope);
      expect(MotherStage.pregnantFirst.legacyStatus, UserStatus.pregnant);
      expect(MotherStage.pregnantWithChildren.legacyStatus, UserStatus.pregnant);
      expect(MotherStage.mom.legacyStatus, UserStatus.mom);
      expect(MotherStage.momHope.legacyStatus, UserStatus.mom);
    });
  });

  group('Schema version constants', () {
    test('kCurrentProfileSchemaVersion is 2', () {
      expect(kCurrentProfileSchemaVersion, 2);
    });
  });

  group('UserProfile tryingToConceive and schemaVersion', () {
    final now = DateTime(2026, 10, 21);

    test('UserProfile constructor defaults', () {
      final p = UserProfile(
        uid: 'user_1',
        createdAt: now,
        updatedAt: now,
      );
      expect(p.tryingToConceive, isFalse);
      expect(p.schemaVersion, 1);
    });

    test('UserProfile.fromMap reads tryingToConceive and schemaVersion defaults when missing', () {
      final p = UserProfile.fromMap(
        {
          'status': 'mom',
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        },
        'user_2',
      );
      expect(p.uid, 'user_2');
      expect(p.status, UserStatus.mom);
      expect(p.tryingToConceive, isFalse);
      expect(p.schemaVersion, 1);
    });

    test('UserProfile.fromMap parses explicit tryingToConceive and schemaVersion', () {
      final p = UserProfile.fromMap(
        {
          'status': 'hope',
          'tryingToConceive': true,
          'schemaVersion': 2,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        },
        'user_3',
      );
      expect(p.uid, 'user_3');
      expect(p.status, UserStatus.hope);
      expect(p.tryingToConceive, isTrue);
      expect(p.schemaVersion, 2);
    });

    test('UserProfile.toFirestore writes tryingToConceive and schemaVersion while keeping status', () {
      final p = UserProfile(
        uid: 'user_4',
        status: UserStatus.hope,
        tryingToConceive: true,
        schemaVersion: 2,
        createdAt: now,
        updatedAt: now,
      );
      final map = p.toFirestore();
      expect(map['status'], 'hope');
      expect(map['tryingToConceive'], isTrue);
      expect(map['schemaVersion'], 2);
    });

    test('UserProfile.copyWith preserves or overrides tryingToConceive and schemaVersion', () {
      final p = UserProfile(
        uid: 'user_5',
        status: UserStatus.mom,
        tryingToConceive: false,
        schemaVersion: 1,
        createdAt: now,
        updatedAt: now,
      );

      final copy1 = p.copyWith(tryingToConceive: true);
      expect(copy1.tryingToConceive, isTrue);
      expect(copy1.schemaVersion, 1);

      final copy2 = p.copyWith(schemaVersion: 2);
      expect(copy2.tryingToConceive, isFalse);
      expect(copy2.schemaVersion, 2);

      final copy3 = p.copyWith();
      expect(copy3.tryingToConceive, isFalse);
      expect(copy3.schemaVersion, 1);
    });
  });
}
