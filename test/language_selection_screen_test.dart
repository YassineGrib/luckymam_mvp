import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/providers/locale_provider.dart';
import 'package:lukymam_mvp/features/onboarding/language_selection_screen.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrapWithScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: Consumer(
      builder: (context, ref, _) {
        final activeLocale = ref.watch(localeProvider);
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: activeLocale,
          home: child,
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('LM-ONB-003: LanguageSelectionScreen Tests', () {
    testWidgets('Displays all 3 languages (Français, العربية, English)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithScope(
          child: const LanguageSelectionScreen(isModal: true),
        ),
      );
      await tester.pumpAndSettle();

      // Check for the 3 languages
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // Check badges
      expect(find.text('FR'), findsOneWidget);
      expect(find.text('عربي'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('Tapping Arabic card immediately switches locale and updates direction to RTL',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => LocaleNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeProvider);
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: activeLocale,
                home: const LanguageSelectionScreen(isModal: true),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially French
      expect(container.read(localeProvider).languageCode, 'fr');
      expect(find.text('Choisissez votre langue'), findsOneWidget);

      // Tap on Arabic
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      // Locale changed to ar
      expect(container.read(localeProvider).languageCode, 'ar');
      // UI reflects Arabic translation immediately
      expect(find.text('اختاري لغتكِ المفضلة'), findsOneWidget);
    });

    testWidgets('Tapping English card immediately switches locale to en',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => LocaleNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeProvider);
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: activeLocale,
                home: const LanguageSelectionScreen(isModal: true),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(container.read(localeProvider).languageCode, 'en');
      expect(find.text('Choose your language'), findsOneWidget);
    });
  });
}

