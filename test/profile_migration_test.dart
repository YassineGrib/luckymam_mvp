import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/pregnancy.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';
import 'package:lukymam_mvp/features/profile/services/profile_migration.dart';

UserProfile _profile({
  UserStatus status = UserStatus.mom,
  DateTime? lmp,
  int schemaVersion = 1,
  bool tryingToConceive = false,
}) {
  return UserProfile(
    uid: 'test_uid',
    status: status,
    lastPregnancyDate: lmp,
    schemaVersion: schemaVersion,
    tryingToConceive: tryingToConceive,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Child _child({
  required String id,
  String name = 'Baby',
  DateTime? birthDate,
  ChildGender gender = ChildGender.unknown,
  ChildLifecycle lifecycle = ChildLifecycle.born,
  DateTime? expectedDate,
  bool archived = false,
}) {
  return Child(
    id: id,
    name: name,
    birthDate: birthDate ?? DateTime(2024, 1, 1),
    gender: gender,
    lifecycle: lifecycle,
    expectedDate: expectedDate,
    archived: archived,
  );
}

Pregnancy _pregnancy({
  required String id,
  PregnancyStatus status = PregnancyStatus.active,
  DateTime? lmpDate,
  DateTime? eddDate,
}) {
  final lmp = lmpDate ?? DateTime(2026, 1, 1);
  return Pregnancy(
    id: id,
    lmpDate: lmp,
    eddDate: eddDate ?? Pregnancy.eddFromLmp(lmp),
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('Profile migration pure logic (Spec §1.6)', () {
    test('pregnant legacy user creates one pregnancy', () {
      final plan = buildProfileMigration(
        _profile(
          status: UserStatus.pregnant,
          lmp: DateTime(2026, 6, 1),
        ),
      );
      expect(plan.createPregnancy, isTrue);
      expect(plan.lmp, DateTime(2026, 6, 1));
      expect(plan.setTryingToConceive, isFalse);
    });

    test('pregnant without lmp does not create pregnancy', () {
      final plan = buildProfileMigration(
        _profile(
          status: UserStatus.pregnant,
          lmp: null,
        ),
      );
      expect(plan.createPregnancy, isFalse);
      expect(plan.lmp, isNull);
      expect(plan.setTryingToConceive, isFalse);
    });

    test('hope legacy user sets TTC', () {
      final plan = buildProfileMigration(
        _profile(status: UserStatus.hope),
      );
      expect(plan.createPregnancy, isFalse);
      expect(plan.lmp, isNull);
      expect(plan.setTryingToConceive, isTrue);
    });

    test('mom legacy user does not create pregnancy or set TTC', () {
      final plan = buildProfileMigration(
        _profile(status: UserStatus.mom),
      );
      expect(plan.createPregnancy, isFalse);
      expect(plan.lmp, isNull);
      expect(plan.setTryingToConceive, isFalse);
    });

    test('preserves tryingToConceive if mom profile was already TTC', () {
      final plan = buildProfileMigration(
        _profile(
          status: UserStatus.mom,
          tryingToConceive: true,
        ),
      );
      expect(plan.createPregnancy, isFalse);
      expect(plan.lmp, isNull);
      expect(plan.setTryingToConceive, isTrue);
    });

    test('needsMigration returns true when schemaVersion < 2', () {
      expect(needsMigration(_profile(schemaVersion: 1)), isTrue);
      expect(needsMigration(_profile(schemaVersion: 0)), isTrue);
    });

    test('migrated profile is not migrated again', () {
      expect(needsMigration(_profile(schemaVersion: 2)), isFalse);
      expect(needsMigration(_profile(schemaVersion: 3)), isFalse);
    });

    test('ProfileMigrationPlan equality and hashCode', () {
      final plan1 = ProfileMigrationPlan(
        createPregnancy: true,
        lmp: DateTime(2026, 6, 1),
        setTryingToConceive: false,
      );
      final plan2 = ProfileMigrationPlan(
        createPregnancy: true,
        lmp: DateTime(2026, 6, 1),
        setTryingToConceive: false,
      );
      final plan3 = ProfileMigrationPlan(
        createPregnancy: false,
        lmp: null,
        setTryingToConceive: true,
      );

      expect(plan1, equals(plan2));
      expect(plan1.hashCode, equals(plan2.hashCode));
      expect(plan1, isNot(equals(plan3)));
    });
  });

  group('Profile providers (LM2-140 / LM2-143)', () {
    test('bornChildrenProvider and expectedChildrenProvider filter archived', () async {
      final born1 = _child(id: 'c1', name: 'Amine', lifecycle: ChildLifecycle.born);
      final bornArchived = _child(id: 'c2', name: 'Old', lifecycle: ChildLifecycle.born, archived: true);
      final expected1 = _child(id: 'c3', name: 'Baby', lifecycle: ChildLifecycle.expected);
      final expectedArchived = _child(id: 'c4', name: 'Lost', lifecycle: ChildLifecycle.expected, archived: true);

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith(
            (ref) => Stream.value([born1, bornArchived, expected1, expectedArchived]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childrenProvider.future);

      final born = container.read(bornChildrenProvider);
      expect(born.map((c) => c.id), ['c1']);

      final expected = container.read(expectedChildrenProvider);
      expect(expected.map((c) => c.id), ['c3']);
    });

    test('activePregnancyProvider returns first active pregnancy and ignores non-active', () async {
      final p1 = _pregnancy(id: 'p1', status: PregnancyStatus.active);
      final pDelivered = _pregnancy(id: 'p2', status: PregnancyStatus.delivered);

      final container = ProviderContainer(
        overrides: [
          pregnanciesProvider.overrideWith(
            (ref) => Stream.value([p1, pDelivered]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pregnanciesProvider.future);

      final active = container.read(activePregnancyProvider);
      expect(active?.id, 'p1');
    });

    test('motherStageProvider defaults to mom while loading', () {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith((ref) => const Stream.empty()),
          childrenProvider.overrideWith((ref) => const Stream.empty()),
          pregnanciesProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(motherStageProvider), MotherStage.mom);
    });

    test('motherStageProvider derives pregnantFirst when active pregnancy and 0 born children', () async {
      final expectedChild = _child(id: 'c1', lifecycle: ChildLifecycle.expected);
      final activePreg = _pregnancy(id: 'p1', status: PregnancyStatus.active);

      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            (ref) => Stream.value(_profile(status: UserStatus.pregnant)),
          ),
          childrenProvider.overrideWith(
            (ref) => Stream.value([expectedChild]),
          ),
          pregnanciesProvider.overrideWith(
            (ref) => Stream.value([activePreg]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(childrenProvider.future);
      await container.read(pregnanciesProvider.future);

      expect(container.read(motherStageProvider), MotherStage.pregnantFirst);
      expect(container.read(isPregnantProvider), isTrue);
      expect(container.read(hasBornChildrenProvider), isFalse);
    });

    test('motherStageProvider derives pregnantWithChildren when active pregnancy and >=1 born children', () async {
      final bornChild = _child(id: 'c1', lifecycle: ChildLifecycle.born);
      final expectedChild = _child(id: 'c2', lifecycle: ChildLifecycle.expected);
      final activePreg = _pregnancy(id: 'p1', status: PregnancyStatus.active);

      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            (ref) => Stream.value(_profile(status: UserStatus.pregnant)),
          ),
          childrenProvider.overrideWith(
            (ref) => Stream.value([bornChild, expectedChild]),
          ),
          pregnanciesProvider.overrideWith(
            (ref) => Stream.value([activePreg]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(childrenProvider.future);
      await container.read(pregnanciesProvider.future);

      expect(container.read(motherStageProvider), MotherStage.pregnantWithChildren);
      expect(container.read(isPregnantProvider), isTrue);
      expect(container.read(hasBornChildrenProvider), isTrue);
    });

    test('motherStageProvider derives hope when 0 born, 0 active pregnancy, TTC true', () async {
      final container = ProviderContainer(
        overrides: [
          profileProvider.overrideWith(
            (ref) => Stream.value(_profile(status: UserStatus.hope, tryingToConceive: true)),
          ),
          childrenProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
          pregnanciesProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(profileProvider.future);
      await container.read(childrenProvider.future);
      await container.read(pregnanciesProvider.future);

      expect(container.read(motherStageProvider), MotherStage.hope);
      expect(container.read(isPregnantProvider), isFalse);
      expect(container.read(hasBornChildrenProvider), isFalse);
    });

    test('selectedChildProvider defaults to first born non-archived child', () async {
      final archivedBorn = _child(id: 'c0', name: 'Archived Born', lifecycle: ChildLifecycle.born, archived: true);
      final expected = _child(id: 'c1', name: 'Expected', lifecycle: ChildLifecycle.expected);
      final born1 = _child(id: 'c2', name: 'Amine', lifecycle: ChildLifecycle.born);
      final born2 = _child(id: 'c3', name: 'Sara', lifecycle: ChildLifecycle.born);

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith(
            (ref) => Stream.value([archivedBorn, expected, born1, born2]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childrenProvider.future);

      final selectedAsync = container.read(selectedChildProvider);
      expect(selectedAsync.value?.id, 'c2');
    });

    test('selectedChildProvider defaults to first non-archived child when no born child exists', () async {
      final archivedBorn = _child(id: 'c0', lifecycle: ChildLifecycle.born, archived: true);
      final expected = _child(id: 'c1', name: 'Expected Baby', lifecycle: ChildLifecycle.expected);

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith(
            (ref) => Stream.value([archivedBorn, expected]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childrenProvider.future);

      final selectedAsync = container.read(selectedChildProvider);
      expect(selectedAsync.value?.id, 'c1');
    });

    test('selectedChildProvider returns null when all children are archived', () async {
      final archivedBorn = _child(id: 'c0', lifecycle: ChildLifecycle.born, archived: true);
      final archivedExpected = _child(id: 'c1', lifecycle: ChildLifecycle.expected, archived: true);

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith(
            (ref) => Stream.value([archivedBorn, archivedExpected]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childrenProvider.future);

      final selectedAsync = container.read(selectedChildProvider);
      expect(selectedAsync.value, isNull);
    });

    test('selectedChildProvider honors explicit selectedChildIdProvider', () async {
      final born = _child(id: 'c1', name: 'Born', lifecycle: ChildLifecycle.born);
      final expected = _child(id: 'c2', name: 'Expected', lifecycle: ChildLifecycle.expected);

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith(
            (ref) => Stream.value([born, expected]),
          ),
          selectedChildIdProvider.overrideWith((ref) => 'c2'),
        ],
      );
      addTearDown(container.dispose);

      await container.read(childrenProvider.future);

      final selectedAsync = container.read(selectedChildProvider);
      expect(selectedAsync.value?.id, 'c2');
    });
  });
}
