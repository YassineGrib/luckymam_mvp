import 'package:lukymam_mvp/core/providers/auth_provider.dart';
import 'package:lukymam_mvp/features/profile/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/notification_service.dart';
import 'package:lukymam_mvp/features/home/home_screen.dart';
import 'package:lukymam_mvp/features/home/providers/home_providers.dart';
import 'package:lukymam_mvp/features/home/widgets/personal_header.dart';
import 'package:lukymam_mvp/features/notifications/models/app_notification.dart';
import 'package:lukymam_mvp/features/notifications/notifications_screen.dart';
import 'package:lukymam_mvp/features/notifications/providers/notifications_providers.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:lukymam_mvp/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeProfileService implements ProfileService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeNotificationActions implements NotificationActions {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrapWithScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      userIdProvider.overrideWithValue(null),
      profileServiceProvider.overrideWithValue(_FakeProfileService()),
      notificationActionsProvider.overrideWithValue(_FakeNotificationActions()),
      ...overrides,
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  final testProfile = UserProfile(
    uid: 'user_nav_test',
    displayName: 'Amira',
    status: UserStatus.mom,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  group('LM-NAV-001: Bottom Navigation Bar Stabilization Tests', () {
    testWidgets('AppBottomNav is present and maintains state in HomeScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithScope(
          child: const HomeScreen(),
          overrides: [
            profileProvider.overrideWith((ref) => Stream.value(testProfile)),
            childrenProvider.overrideWith((ref) => Stream.value([])),
            childrenSummaryProvider.overrideWith((ref) async => []),
            notificationServiceProvider.overrideWithValue(
              _FakeNotificationService(),
            ),
            homeNavigationIndexProvider.overrideWith((ref) => 0),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // AppBottomNav should be rendered
      expect(find.byType(AppBottomNav), findsOneWidget);

      // Verify 5 navigation items exist
      final nav = tester.widget<AppBottomNav>(find.byType(AppBottomNav));
      expect(nav.items.length, 5);
      expect(nav.currentIndex, 0);

      // Tap on Timeline tab (index 1)
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNav),
          matching: find.byIcon(nav.items[1].icon),
        ),
      );
      await tester.pumpAndSettle();

      final updatedNav = tester.widget<AppBottomNav>(find.byType(AppBottomNav));
      expect(updatedNav.currentIndex, 1);
    });

    testWidgets(
      'Tapping avatar in PersonalHeader switches tab to Profile without losing bottom bar',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            profileProvider.overrideWith((ref) => Stream.value(testProfile)),
            notificationServiceProvider.overrideWithValue(
              _FakeNotificationService(),
            ),
            homeNavigationIndexProvider.overrideWith((ref) => 0),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('fr'),
              home: Scaffold(body: PersonalHeader()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(container.read(homeNavigationIndexProvider), 0);

        // Tap avatar (represented by Circular User Avatar GestureDetector)
        final avatarFinder = find.byType(ClipOval);
        expect(avatarFinder, findsOneWidget);

        await tester.tap(avatarFinder);
        await tester.pumpAndSettle();

        // Index should switch to 4 (Profile)
        expect(container.read(homeNavigationIndexProvider), 4);
      },
    );

    testWidgets(
      'NotificationsScreen contains AppBottomNav with active tab highlighted',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithScope(
            child: const NotificationsScreen(),
            overrides: [
              notificationsStreamProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
              unreadNotificationsCountProvider.overrideWith((ref) => 0),
              notificationServiceProvider.overrideWithValue(
                _FakeNotificationService(),
              ),
              homeNavigationIndexProvider.overrideWith((ref) => 0),
            ],
          ),
        );
        await tester.pumpAndSettle();

        // Bottom bar must be present in NotificationsScreen as required by LM-NAV-001
        expect(find.byType(AppBottomNav), findsOneWidget);
        final nav = tester.widget<AppBottomNav>(find.byType(AppBottomNav));
        expect(nav.currentIndex, 0);
      },
    );
  });
}
