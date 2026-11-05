import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/notification_service.dart';
import 'package:lukymam_mvp/features/capsules/models/capsule.dart';
import 'package:lukymam_mvp/features/capsules/providers/capsule_providers.dart';
import 'package:lukymam_mvp/features/capsules/screens/capsules_gallery.dart';
import 'package:lukymam_mvp/features/capsules/screens/create_capsule_screen.dart';
import 'package:lukymam_mvp/features/home/providers/home_providers.dart';
import 'package:lukymam_mvp/features/home/tabs/dashboard_tab.dart';
import 'package:lukymam_mvp/features/home/widgets/home_bento_grid.dart';
import 'package:lukymam_mvp/features/notifications/providers/notifications_providers.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';
import 'package:lukymam_mvp/features/subscription/providers/subscription_providers.dart';
import 'package:lukymam_mvp/features/vaccines/models/vaccine.dart';
import 'package:lukymam_mvp/features/vaccines/providers/vaccine_providers.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:lukymam_mvp/shared/widgets/page_header_with_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrapWithScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  final testChild = Child(
    id: 'child_1',
    name: 'Yanis',
    birthDate: DateTime(2025, 6, 1),
    gender: ChildGender.boy,
    lifecycle: ChildLifecycle.born,
  );

  final testProfile = UserProfile(
    uid: 'user_test',
    displayName: 'Fatima',
    status: UserStatus.mom,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  group('LM-MEM-001 & LM-MEM-002: CapsulesGallery unit & widget tests', () {
    testWidgets(
      'CapsulesGallery displays back button and filter pills (Tous, MAM, Enfant)',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithScope(
            child: const CapsulesGallery(showBackButton: true),
            overrides: [
              childrenProvider.overrideWith((ref) => Stream.value([testChild])),
              filteredCapsulesProvider.overrideWith(
                (ref) => Stream.value(<Capsule>[]),
              ),
              canCreateCapsuleProvider.overrideWith((ref) => Future.value(true)),
              remainingCapsuleQuotaProvider.overrideWith(
                (ref) => Future.value(20),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        // Back button must exist when showBackButton is true
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

        // Verify PageHeaderWithFilter shows title "Mes Souvenirs"
        expect(find.text('Mes Souvenirs'), findsOneWidget);

        // Verify filters: "Tous", "MAM", and "Yanis" within PageHeaderWithFilter
        expect(
          find.descendant(
            of: find.byType(PageHeaderWithFilter),
            matching: find.text('Tous'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(PageHeaderWithFilter),
            matching: find.text('MAM'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(PageHeaderWithFilter),
            matching: find.text('Yanis'),
          ),
          findsOneWidget,
        );

        // Verify empty state shows CTA "Créer mon premier souvenir"
        expect(find.text('Créer mon premier souvenir'), findsOneWidget);
      },
    );

    testWidgets('CapsulesGallery empty state button opens CreateCapsuleScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScope(
          child: const CapsulesGallery(showBackButton: true),
          overrides: [
            childrenProvider.overrideWith((ref) => Stream.value([testChild])),
            filteredCapsulesProvider.overrideWith(
              (ref) => Stream.value(<Capsule>[]),
            ),
            canCreateCapsuleProvider.overrideWith((ref) => Future.value(true)),
            remainingCapsuleQuotaProvider.overrideWith(
              (ref) => Future.value(20),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      final createButton = find.text('Créer mon premier souvenir');
      expect(createButton, findsOneWidget);

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should now be on CreateCapsuleScreen
      expect(find.byType(CreateCapsuleScreen), findsOneWidget);
    });
  });

  group('LM-MEM-001 & LM-MEM-002: Bento Grid and Dashboard Navigation', () {
    testWidgets(
      'Tapping Mes Souvenirs card in HomeBentoGrid navigates to CapsulesGallery',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithScope(
            child: const HomeBentoGrid(),
            overrides: [
              motherStageProvider.overrideWithValue(MotherStage.mom),
              childrenProvider.overrideWith((ref) => Stream.value([testChild])),
              filteredCapsulesProvider.overrideWith(
                (ref) => Stream.value(<Capsule>[]),
              ),
              canCreateCapsuleProvider.overrideWith((ref) => Future.value(true)),
              remainingCapsuleQuotaProvider.overrideWith(
                (ref) => Future.value(20),
              ),
            ],
          ),
        );

        await tester.pumpAndSettle();

        // Locate the "Mes Souvenirs" text in Bento Grid
        final cardFinder = find.text('Mes Souvenirs');
        expect(cardFinder, findsOneWidget);

        await tester.tap(cardFinder);
        await tester.pumpAndSettle();

        // Verify CapsulesGallery is opened with back button
        expect(find.byType(CapsulesGallery), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      },
    );

    testWidgets('Tapping Voir tout in DashboardTab navigates to CapsulesGallery', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrapWithScope(
          child: const DashboardTab(),
          overrides: [
            notificationServiceProvider.overrideWithValue(
              _FakeNotificationService(),
            ),
            motherStageProvider.overrideWithValue(MotherStage.mom),
            profileProvider.overrideWith((ref) => Stream.value(testProfile)),
            childrenProvider.overrideWith((ref) => Stream.value([testChild])),
            hasBornChildrenProvider.overrideWithValue(true),
            bornChildrenProvider.overrideWithValue([testChild]),
            isPremiumProvider.overrideWithValue(false),
            isVipProvider.overrideWithValue(false),
            unreadNotificationsCountProvider.overrideWithValue(0),
            filteredCapsulesProvider.overrideWith(
              (ref) => Stream.value(<Capsule>[]),
            ),
            recentCapsulesProvider.overrideWithValue(<Capsule>[]),
            capsulesProvider.overrideWith((ref) => Stream.value(<Capsule>[])),
            canCreateCapsuleProvider.overrideWith((ref) => Future.value(true)),
            remainingCapsuleQuotaProvider.overrideWith(
              (ref) => Future.value(20),
            ),
            vaccineCalendarProvider.overrideWith(
              (ref) async => const VaccineCalendar(
                version: '1.0',
                country: 'DZ',
                language: 'fr',
                groups: [],
              ),
            ),
            childrenSummaryProvider.overrideWith((ref) async => []),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Locate "Voir tout"
      final seeAllFinder = find.text('Voir tout');
      expect(seeAllFinder, findsOneWidget);

      await tester.tap(seeAllFinder);
      await tester.pumpAndSettle();

      // Verify CapsulesGallery is opened
      expect(find.byType(CapsulesGallery), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });
}
