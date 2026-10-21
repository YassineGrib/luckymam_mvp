import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/notification_service.dart';
import 'package:lukymam_mvp/features/home/data/home_tips_data.dart';
import 'package:lukymam_mvp/features/home/providers/home_providers.dart';
import 'package:lukymam_mvp/features/home/tabs/dashboard_tab.dart';
import 'package:lukymam_mvp/features/home/widgets/children_overview.dart';
import 'package:lukymam_mvp/features/home/widgets/cycle_tracking_section.dart';
import 'package:lukymam_mvp/features/home/widgets/mother_health_card.dart';
import 'package:lukymam_mvp/features/home/widgets/weekly_day_strip.dart';
import 'package:lukymam_mvp/features/notifications/providers/notifications_providers.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/pregnancy.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';
import 'package:lukymam_mvp/features/subscription/providers/subscription_providers.dart';
import 'package:lukymam_mvp/features/vaccines/models/vaccine.dart';
import 'package:lukymam_mvp/features/vaccines/providers/vaccine_providers.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

UserProfile _profile({
  UserStatus status = UserStatus.mom,
  DateTime? lastPregnancyDate,
  bool tryingToConceive = false,
  CycleInfo? cycleInfo,
}) {
  return UserProfile(
    uid: 'test_user',
    displayName: 'Amina Test',
    status: status,
    lastPregnancyDate: lastPregnancyDate,
    tryingToConceive: tryingToConceive,
    cycleInfo: cycleInfo ?? const CycleInfo(),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

Child _child({
  required String id,
  String name = 'Amina',
  DateTime? birthDate,
  ChildGender gender = ChildGender.girl,
  ChildLifecycle lifecycle = ChildLifecycle.born,
  bool archived = false,
}) {
  return Child(
    id: id,
    name: name,
    birthDate: birthDate ?? DateTime(2025, 1, 1),
    gender: gender,
    lifecycle: lifecycle,
    archived: archived,
  );
}

Pregnancy _pregnancy({
  required String id,
  required DateTime lmpDate,
  DateTime? eddDate,
  PregnancyStatus status = PregnancyStatus.active,
}) {
  return Pregnancy(
    id: id,
    lmpDate: lmpDate,
    eddDate: eddDate ?? Pregnancy.eddFromLmp(lmpDate),
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Task 7a: HomeTipsData stage mapping', () {
    test('tipForStage maps pregnant stages to pregnant tips pool', () {
      final tipFirst =
          HomeTipsData.tipForStage('fr', MotherStage.pregnantFirst);
      final tipWithChildren =
          HomeTipsData.tipForStage('fr', MotherStage.pregnantWithChildren);
      final legacyPregnant = HomeTipsData.tipFor('fr', UserStatus.pregnant);

      expect(tipFirst, legacyPregnant);
      expect(tipWithChildren, legacyPregnant);
    });

    test('tipForStage maps exploring and hope to hope tips pool', () {
      final tipExploring = HomeTipsData.tipForStage('fr', MotherStage.exploring);
      final tipHope = HomeTipsData.tipForStage('fr', MotherStage.hope);
      final legacyHope = HomeTipsData.tipFor('fr', UserStatus.hope);

      expect(tipExploring, legacyHope);
      expect(tipHope, legacyHope);
    });

    test('tipForStage maps mom and momHope to mom tips pool', () {
      final tipMom = HomeTipsData.tipForStage('fr', MotherStage.mom);
      final tipMomHope = HomeTipsData.tipForStage('fr', MotherStage.momHope);
      final legacyMom = HomeTipsData.tipFor('fr', UserStatus.mom);

      expect(tipMom, legacyMom);
      expect(tipMomHope, legacyMom);
    });
  });

  group('Task 7a: dailyTipProvider feeds from motherStageProvider.legacyStatus', () {
    test(
        'dailyTipProvider uses pregnant pool when motherStage is pregnantWithChildren, even if profile.status was mom',
        () async {
      final container = ProviderContainer(
        overrides: [
          motherStageProvider
              .overrideWithValue(MotherStage.pregnantWithChildren),
          profileProvider.overrideWith(
            (ref) => Stream.value(_profile(status: UserStatus.mom)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final tip = container.read(dailyTipProvider);
      final pregnantTip = HomeTipsData.tipFor('fr', UserStatus.pregnant);

      expect(tip, pregnantTip);
    });

    test('dailyTipProvider uses hope pool when motherStage is exploring', () async {
      final container = ProviderContainer(
        overrides: [
          motherStageProvider.overrideWithValue(MotherStage.exploring),
          profileProvider.overrideWith(
            (ref) => Stream.value(_profile(status: UserStatus.mom)),
          ),
        ],
      );
      addTearDown(container.dispose);

      final tip = container.read(dailyTipProvider);
      final hopeTip = HomeTipsData.tipFor('fr', UserStatus.hope);

      expect(tip, hopeTip);
    });
  });

  group('Task 7a: DashboardTab Mes Enfants visibility', () {
    Widget createDashboardTestApp({
      required bool hasBornChildren,
      required MotherStage stage,
    }) {
      return ProviderScope(
        overrides: [
          notificationServiceProvider
              .overrideWithValue(_FakeNotificationService()),
          motherStageProvider.overrideWithValue(stage),
          hasBornChildrenProvider.overrideWithValue(hasBornChildren),
          bornChildrenProvider.overrideWithValue(hasBornChildren
              ? [_child(id: 'c1', name: 'Karim')]
              : []),
          profileProvider.overrideWith(
            (ref) => Stream.value(_profile(status: UserStatus.pregnant)),
          ),
          childrenProvider.overrideWith((ref) => Stream.value([])),
          vaccineCalendarProvider.overrideWith(
            (ref) async => const VaccineCalendar(
              version: '1.0',
              country: 'DZ',
              language: 'fr',
              groups: [],
            ),
          ),
          isPremiumProvider.overrideWithValue(true),
          isVipProvider.overrideWithValue(false),
          unreadNotificationsCountProvider.overrideWithValue(0),
          recentCapsulesProvider.overrideWithValue([]),
          childrenSummaryProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fr'),
          home: Scaffold(body: DashboardTab()),
        ),
      );
    }

    testWidgets(
        'shows ChildrenOverview when hasBornChildren is true even if stage is pregnantWithChildren',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardTestApp(
        hasBornChildren: true,
        stage: MotherStage.pregnantWithChildren,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChildrenOverview), findsOneWidget);
    });

    testWidgets('hides ChildrenOverview when hasBornChildren is false',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createDashboardTestApp(
        hasBornChildren: false,
        stage: MotherStage.pregnantFirst,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChildrenOverview), findsNothing);
    });
  });

  group('Task 7a: WeeklyDayStrip coexisting events', () {
    testWidgets('renders day strip and handles multiple event kinds',
        (tester) async {
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final bornChild = _child(
        id: 'child_1',
        name: 'Amina',
        birthDate: DateTime(monday.year, monday.month - 2, monday.day),
        lifecycle: ChildLifecycle.born,
      );
      final expectedChild = _child(
        id: 'child_exp',
        name: 'Futur Bébé',
        birthDate: DateTime(monday.year, monday.month - 2, monday.day),
        lifecycle: ChildLifecycle.expected,
      );

      final lmp = monday.subtract(const Duration(days: 28)); // 4 weeks ago
      final pregnancy = _pregnancy(id: 'preg_1', lmpDate: lmp);

      const vaccineGroup = VaccineGroup(
        id: 'g2',
        ageKey: '2m',
        ageFr: '2 mois',
        ageAr: 'شهران',
        ageMonths: 2,
        vaccines: [
          Vaccine(
            code: 'DTC',
            nameFr: 'DTC',
            nameAr: 'DTC',
            protectsFr: 'DTC',
            protectsAr: 'DTC',
          ),
        ],
      );

      const calendar = VaccineCalendar(
        version: '1.0',
        country: 'DZ',
        language: 'fr',
        groups: [vaccineGroup],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(_FakeNotificationService()),
            motherStageProvider
                .overrideWithValue(MotherStage.pregnantWithChildren),
            hasBornChildrenProvider.overrideWithValue(true),
            isPregnantProvider.overrideWithValue(true),
            activePregnancyProvider.overrideWithValue(pregnancy),
            bornChildrenProvider
                .overrideWithValue([bornChild, expectedChild]),
            childrenProvider
                .overrideWith((ref) => Stream.value([bornChild, expectedChild])),
            vaccineCalendarProvider.overrideWith((ref) async => calendar),
            profileProvider.overrideWith((ref) => Stream.value(_profile())),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(
              body: WeeklyDayStrip(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WeeklyDayStrip), findsOneWidget);

      await tester.tap(find.text('${monday.day}'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Vaccin: DTC'), findsOneWidget);
      expect(find.textContaining('Semaine 4 de grossesse'), findsOneWidget);
      expect(find.textContaining('Amina'), findsOneWidget);
      expect(find.textContaining('Futur Bébé'), findsNothing);
    });
  });

  group('Task 7a: MotherHealthCard and CycleTrackingSection capabilities', () {
    testWidgets('MotherHealthCard shows pregnancy tracking when isPregnantProvider is true',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPregnantProvider.overrideWithValue(true),
            profileProvider.overrideWith(
              (ref) => Stream.value(_profile(status: UserStatus.mom)),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(body: MotherHealthCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Suivi de grossesse'), findsOneWidget);
    });

    testWidgets('CycleTrackingSection uses active pregnancy dates when active pregnancy exists',
        (tester) async {
      final now = DateTime.now();
      final lmp = DateTime(now.year, now.month, now.day - 70); // 10 weeks
      final pregnancy = _pregnancy(id: 'p1', lmpDate: lmp);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPregnantProvider.overrideWithValue(true),
            activePregnancyProvider.overrideWithValue(pregnancy),
            profileProvider.overrideWith(
              (ref) => Stream.value(_profile(status: UserStatus.mom)),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(body: CycleTrackingSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ma Grossesse'), findsOneWidget);
      // Week 10 is gestationalWeek for 70 days
      expect(find.textContaining('Semaine 10'), findsOneWidget);
    });

    testWidgets('CycleTrackingSection falls back to profile.lastPregnancyDate when active pregnancy is null',
        (tester) async {
      final now = DateTime.now();
      final lmp = DateTime(now.year, now.month, now.day - 42); // 6 weeks

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isPregnantProvider.overrideWithValue(true),
            activePregnancyProvider.overrideWithValue(null),
            profileProvider.overrideWith(
              (ref) => Stream.value(_profile(
                status: UserStatus.pregnant,
                lastPregnancyDate: lmp,
              )),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('fr'),
            home: Scaffold(body: CycleTrackingSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ma Grossesse'), findsOneWidget);
      expect(find.textContaining('Semaine 6'), findsOneWidget);
    });
  });
}
