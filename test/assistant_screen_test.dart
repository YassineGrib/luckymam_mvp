import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_avatar.dart';
import 'package:lukymam_mvp/features/assistant/providers/assistant_providers.dart';
import 'package:lukymam_mvp/features/assistant/screens/assistant_screen.dart';
import 'package:lukymam_mvp/features/assistant/services/fake_assistant_backend.dart';
import 'package:lukymam_mvp/features/assistant/widgets/assistant_cards.dart';
import 'package:lukymam_mvp/features/assistant/widgets/message_bubble.dart';
import 'package:lukymam_mvp/features/assistant/widgets/suggestion_chips.dart';
import 'package:lukymam_mvp/features/home/widgets/assistant_shortcut_card.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

Widget _createTestApp({
  Locale locale = const Locale('fr'),
  bool disableAnimations = false,
  Widget? child,
}) {
  return ProviderScope(
    overrides: [
      assistantBackendProvider.overrideWithValue(
        FakeAssistantBackend(delay: Duration.zero),
      ),
      assistantControllerProvider.overrideWith(
        (ref) => AssistantController(
          ref.watch(assistantBackendProvider),
          locale: locale.languageCode,
          speakingDuration: (_) => Duration.zero,
        ),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: child ?? const AssistantScreen(),
      ),
    ),
  );
}

void main() {
  group('AssistantScreen Widget Tests', () {
    testWidgets('shows greeting and 4 suggestion chips', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pump(const Duration(milliseconds: 1300));

      // Greeting message bubble should be present
      expect(find.byType(MessageBubble), findsAtLeastNWidgets(1));

      // Suggestion chips row should be visible
      expect(find.byType(SuggestionChips), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(4));
    });

    testWidgets('typing and sending shows the user bubble then the reply',
        (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pump(const Duration(milliseconds: 1300));

      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'Bonjour');
      await tester.pump(const Duration(milliseconds: 50));

      // Find and tap send button
      final sendFinder = find.byIcon(Icons.arrow_upward_rounded);
      expect(sendFinder, findsOneWidget);
      await tester.tap(sendFinder);

      await tester.pump(const Duration(milliseconds: 50));
      // Appended user message
      expect(find.text('Bonjour'), findsOneWidget);

      // Settle response
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MessageBubble), findsAtLeastNWidgets(2));
    });

    testWidgets('outing question renders a weather card', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pump(const Duration(milliseconds: 1300));

      await tester.enterText(find.byType(TextField), 'sortie');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));

      await tester.pump(const Duration(milliseconds: 200));

      // Weather card should be rendered inside assistant card view
      expect(find.byType(AssistantCardView), findsOneWidget);
      expect(find.text('21°C'), findsOneWidget);
    });

    testWidgets('product question renders a product card with its benefit and CTA',
        (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pump(const Duration(milliseconds: 1300));

      await tester.enterText(find.byType(TextField), 'jouet');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));

      await tester.pump(const Duration(milliseconds: 200));

      // Product card with benefit and CTA button
      expect(find.byType(AssistantCardView), findsOneWidget);
      expect(find.textContaining('Hochet'), findsOneWidget);
      expect(find.textContaining('2200 DZD'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('error message is localized (fr and ar)', (tester) async {
      // Test FR
      await tester.pumpWidget(_createTestApp(locale: const Locale('fr')));
      await tester.pump(const Duration(milliseconds: 1300));

      await tester.enterText(find.byType(TextField), 'erreur');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.textContaining('L\'assistante est très occupée'),
        findsOneWidget,
      );

      // Test AR
      await tester.pumpWidget(_createTestApp(locale: const Locale('ar')));
      await tester.pump(const Duration(milliseconds: 1300));

      await tester.enterText(find.byType(TextField), 'erreur');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.textContaining('المساعد مشغول حالياً'),
        findsOneWidget,
      );
    });

    testWidgets('send button disabled when empty', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pump(const Duration(milliseconds: 1300));

      final iconBtn = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded),
      );
      expect(iconBtn.onPressed, isNull);
    });

    testWidgets('arabic layout at 360dp does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_createTestApp(locale: const Locale('ar')));
      await tester.pump(const Duration(milliseconds: 1300));

      // Send jouet
      await tester.enterText(find.byType(TextField), 'jouet');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 200));

      // Send vaccin
      await tester.enterText(find.byType(TextField), 'vaccin');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion keeps the bird static', (tester) async {
      await tester.pumpWidget(_createTestApp(disableAnimations: true));
      await tester.pump(const Duration(milliseconds: 1300));
      expect(tester.takeException(), isNull);
      expect(find.byType(MochiAvatar), findsWidgets);
    });

    testWidgets('shortcut card navigates to assistant', (tester) async {
      bool navigated = false;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: AssistantShortcutCard(),
            ),
          ),
          GoRoute(
            path: '/assistant',
            name: 'assistant',
            builder: (context, state) {
              navigated = true;
              return const Scaffold(body: Text('Assistant Screen'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AssistantShortcutCard), findsOneWidget);
      await tester.tap(find.byType(AssistantShortcutCard));
      await tester.pumpAndSettle();

      expect(navigated, isTrue);
      expect(find.text('Assistant Screen'), findsOneWidget);
    });
  });
}
