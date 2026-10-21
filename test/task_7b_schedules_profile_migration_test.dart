import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/cycle_notification_service.dart';
import 'package:lukymam_mvp/core/services/notification_service.dart';
import 'package:lukymam_mvp/features/capsules/providers/capsule_providers.dart';
import 'package:lukymam_mvp/features/capsules/services/capsule_service.dart';
import 'package:lukymam_mvp/features/home/home_screen.dart';
import 'package:lukymam_mvp/features/home/providers/home_providers.dart';
import 'package:lukymam_mvp/features/home/tabs/vaccinations_tab.dart';
import 'package:lukymam_mvp/features/notifications/providers/notifications_providers.dart';
import 'package:lukymam_mvp/features/profile/edit_mother_profile_screen.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/pregnancy.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';
import 'package:lukymam_mvp/features/profile/services/profile_service.dart';
import 'package:lukymam_mvp/features/subscription/models/subscription_models.dart';
import 'package:lukymam_mvp/features/subscription/providers/subscription_providers.dart';
import 'package:lukymam_mvp/features/timeline/screens/timeline_screen.dart';
import 'package:lukymam_mvp/features/timeline/services/milestone_notification_service.dart';
import 'package:lukymam_mvp/features/timeline/services/timeline_service.dart';
import 'package:lukymam_mvp/features/vaccines/models/vaccine.dart';
import 'package:lukymam_mvp/features/vaccines/models/vaccine_status.dart';
import 'package:lukymam_mvp/features/vaccines/providers/vaccine_providers.dart';
import 'package:lukymam_mvp/features/vaccines/services/vaccine_service.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeFirebaseFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeMilestoneNotificationService implements MilestoneNotificationService {
  int scheduleCount = 0;

  @override
  Future<void> scheduleAllReminders({
    required Child child,
    required List<MilestoneWithDueDate> milestones,
  }) async {
    scheduleCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeVaccineService implements VaccineService {
  final List<String> scheduledChildIds = [];

  @override
  Future<void> scheduleReminders({
    required String childId,
    required DateTime dob,
    required String childName,
  }) async {
    scheduledChildIds.add(childId);
  }

  @override
  Future<VaccineCalendar> loadVaccineCalendar() async {
    return const VaccineCalendar(
      version: '1',
      country: 'dz',
      language: 'fr',
      groups: [],
    );
  }

  @override
  Stream<List<VaccineStatus>> watchVaccinationStatuses(String childId) {
    return Stream.value([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileService implements ProfileService {
  DateTime? declaredLmp;
  String? declaredPlaceholder;
  bool? ttcValue;
  int migrationCallCount = 0;
  String? migrationPlaceholder;

  @override
  Future<String> declarePregnancy({
    required DateTime lmpDate,
    DateTime? eddDate,
    EddSource eddSource = EddSource.lmp,
    int babyCount = 1,
    required String placeholderName,
  }) async {
    declaredLmp = lmpDate;
    declaredPlaceholder = placeholderName;
    return 'fake_preg_id';
  }

  @override
  Future<void> setTryingToConceive(bool value) async {
    ttcValue = value;
  }

  @override
  Future<void> runProfileMigrationIfNeeded({
    required String placeholderName,
  }) async {
    migrationCallCount++;
    migrationPlaceholder = placeholderName;
  }

  @override
  Future<void> updateFullProfile({
    String? displayName,
    String? phone,
    DateTime? birthDate,
    String? wilaya,
    String? photoUrl,
    bool removePhoto = false,
    UserStatus? status,
    DateTime? pregnancyDate,
    MedicalInfo? medicalInfo,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCapsuleService implements CapsuleService {
  int migrateCallCount = 0;

  @override
  Future<int> migrateCapsuleSubjects() async {
    migrateCallCount++;
    return 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Child _bornChild({
  String id = 'child_born',
  String name = 'Nadia',
  DateTime? birthDate,
}) {
  return Child(
    id: id,
    name: name,
    birthDate: birthDate ?? DateTime(2024, 1, 1),
    gender: ChildGender.girl,
    lifecycle: ChildLifecycle.born,
    archived: false,
  );
}

Child _expectedChild({
  String id = 'child_expected',
  String name = 'Bébé',
  DateTime? edd,
}) {
  return Child(
    id: id,
    name: name,
    birthDate: edd ?? DateTime(2026, 12, 1),
    expectedDate: edd ?? DateTime(2026, 12, 1),
    gender: ChildGender.unknown,
    lifecycle: ChildLifecycle.expected,
    archived: false,
  );
}

UserProfile _userProfile({
  UserStatus status = UserStatus.mom,
  DateTime? pregnancyDate,
}) {
  return UserProfile(
    uid: 'user_1',
    displayName: 'Amina',
    status: status,
    lastPregnancyDate: pregnancyDate,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Widget _wrapWithApp(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: [
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('ar'),
        Locale('en'),
      ],
      locale: const Locale('fr'),
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Task 7b: Schedule generators skip expected children', () {
    test('home_providers childrenSummaryProvider skips expected children', () async {
      final born = _bornChild(id: 'born_1');
      final expected = _expectedChild(id: 'expected_1');

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith((ref) => Stream.value([born, expected])),
          vaccineGroupsWithStatusProvider((childId: born.id, birthDate: born.birthDate))
              .overrideWith((ref) => Future.value([])),
          upcomingMilestonesProvider(born.id).overrideWith((ref) => Future.value([])),
        ],
      );

      final summaries = await container.read(childrenSummaryProvider.future);
      expect(summaries.length, 1);
      expect(summaries.first.child.id, 'born_1');
    });

    test('vaccineSchedulerProvider skips expected children', () async {
      final fakeVaccineService = _FakeVaccineService();
      final born = _bornChild(id: 'born_1');
      final expected = _expectedChild(id: 'expected_1');

      final container = ProviderContainer(
        overrides: [
          vaccineServiceProvider.overrideWithValue(fakeVaccineService),
          childrenProvider.overrideWith((ref) => Stream.value([born, expected])),
        ],
      );

      await container.read(vaccineSchedulerProvider.future);
      expect(fakeVaccineService.scheduledChildIds, ['born_1']);
      expect(fakeVaccineService.scheduledChildIds.contains('expected_1'), false);
    });

    test('TimelineService.getMilestonesForChild returns empty list for expected child', () {
      final service = TimelineService(_FakeFirebaseFirestore());
      final expected = _expectedChild();
      final milestones = service.getMilestonesForChild(expected);
      expect(milestones, isEmpty);
    });

    test('childMilestonesProvider returns empty list for expected child', () async {
      final expected = _expectedChild(id: 'expected_1');

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith((ref) => Stream.value([expected])),
          milestoneProgressStreamProvider('expected_1').overrideWith((ref) => Stream.value([])),
          profileProvider.overrideWith((ref) => Stream.value(_userProfile())),
        ],
      );

      final milestones = await container.read(childMilestonesProvider('expected_1').future);
      expect(milestones, isEmpty);
    });

    test('milestoneRemindersProvider skips scheduling for expected child', () async {
      final fakeNotif = _FakeMilestoneNotificationService();
      final expected = _expectedChild(id: 'expected_1');

      final container = ProviderContainer(
        overrides: [
          childrenProvider.overrideWith((ref) => Stream.value([expected])),
          milestoneNotificationServiceProvider.overrideWithValue(fakeNotif),
          childMilestonesProvider('expected_1').overrideWith((ref) => Future.value([])),
        ],
      );

      await container.read(milestoneRemindersProvider('expected_1').future);
      expect(fakeNotif.scheduleCount, 0);
    });
  });

  group('Task 7b: scheduleStartsAtBirth empty state in tabs', () {
    testWidgets('VaccinationsTab displays scheduleStartsAtBirth for expected child', (tester) async {
      final expected = _expectedChild(id: 'expected_1', name: 'Mon Bébé');

      await tester.pumpWidget(
        _wrapWithApp(
          const VaccinationsTab(),
          overrides: [
            childrenProvider.overrideWith((ref) => Stream.value([expected])),
            vaccineSchedulerProvider.overrideWith((ref) => Future.value()),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Le calendrier démarre à la naissance'), findsOneWidget);
      expect(find.byIcon(Icons.child_care_rounded), findsOneWidget);
    });

    testWidgets('TimelineScreen displays scheduleStartsAtBirth for expected child', (tester) async {
      final expected = _expectedChild(id: 'expected_1', name: 'Mon Bébé');

      await tester.pumpWidget(
        _wrapWithApp(
          const TimelineScreen(),
          overrides: [
            childrenProvider.overrideWith((ref) => Stream.value([expected])),
            childMilestonesProvider('expected_1').overrideWith((ref) => Future.value([])),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Le calendrier démarre à la naissance'), findsOneWidget);
      expect(find.byIcon(Icons.child_care_rounded), findsOneWidget);
    });
  });

  group('Task 7b: edit_mother_profile_screen save wiring', () {
    testWidgets('saves pregnant status -> calls declarePregnancy when no active pregnancy', (tester) async {
      final fakeProfileService = _FakeProfileService();
      final lmp = DateTime(2026, 3, 15);
      final profile = _userProfile(status: UserStatus.pregnant, pregnancyDate: lmp);

      await tester.pumpWidget(
        _wrapWithApp(
          EditMotherProfileScreen(profile: profile),
          overrides: [
            profileServiceProvider.overrideWithValue(fakeProfileService),
            activePregnancyProvider.overrideWithValue(null),
            cycleNotificationServiceProvider.overrideWithValue(
              CycleNotificationService(_FakeNotificationService()),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Tap save button (trailing action in AppBar or bottom)
      final saveButton = find.text('Enregistrer les modifications');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(fakeProfileService.declaredLmp, lmp);
      expect(fakeProfileService.declaredPlaceholder, 'Bébé');
    });

    testWidgets('saves hope status -> calls setTryingToConceive(true)', (tester) async {
      final fakeProfileService = _FakeProfileService();
      final profile = _userProfile(status: UserStatus.hope);

      await tester.pumpWidget(
        _wrapWithApp(
          EditMotherProfileScreen(profile: profile),
          overrides: [
            profileServiceProvider.overrideWithValue(fakeProfileService),
            cycleNotificationServiceProvider.overrideWithValue(
              CycleNotificationService(_FakeNotificationService()),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final saveButton = find.text('Enregistrer les modifications');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(fakeProfileService.ttcValue, isTrue);
    });

    testWidgets('saves mom status -> calls setTryingToConceive(false)', (tester) async {
      final fakeProfileService = _FakeProfileService();
      final profile = _userProfile(status: UserStatus.mom);

      await tester.pumpWidget(
        _wrapWithApp(
          EditMotherProfileScreen(profile: profile),
          overrides: [
            profileServiceProvider.overrideWithValue(fakeProfileService),
            cycleNotificationServiceProvider.overrideWithValue(
              CycleNotificationService(_FakeNotificationService()),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final saveButton = find.text('Enregistrer les modifications');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(fakeProfileService.ttcValue, isFalse);
    });
  });

  group('Task 7b: HomeScreen startup migration', () {
    testWidgets('initState calls runProfileMigrationIfNeeded and migrateCapsuleSubjects', (tester) async {
      final fakeProfileService = _FakeProfileService();
      final fakeCapsuleService = _FakeCapsuleService();

      await tester.pumpWidget(
        _wrapWithApp(
          const HomeScreen(),
          overrides: [
            profileServiceProvider.overrideWithValue(fakeProfileService),
            capsuleServiceProvider.overrideWithValue(fakeCapsuleService),
            notificationServiceProvider.overrideWithValue(_FakeNotificationService()),
            // dependencies for child tabs
            childrenProvider.overrideWith((ref) => Stream.value([])),
            profileProvider.overrideWith((ref) => Stream.value(_userProfile())),
            motherStageProvider.overrideWithValue(MotherStage.mom),
            hasBornChildrenProvider.overrideWithValue(false),
            isPregnantProvider.overrideWithValue(false),
            activePregnancyProvider.overrideWithValue(null),
            capsulesProvider.overrideWith((ref) => Stream.value([])),
            vaccineSchedulerProvider.overrideWith((ref) => Future.value()),
            notificationsStreamProvider.overrideWith((ref) => Stream.value([])),
            unreadNotificationsCountProvider.overrideWithValue(0),
            currentTierProvider.overrideWith((ref) => Stream.value(SubscriptionTier.free)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(fakeProfileService.migrationCallCount, 1);
      expect(fakeProfileService.migrationPlaceholder, 'Bébé');
      expect(fakeCapsuleService.migrateCallCount, 1);
    });
  });
}
