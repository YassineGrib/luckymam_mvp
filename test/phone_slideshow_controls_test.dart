import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/digital_album/models/digital_slideshow_model.dart';
import 'package:lukymam_mvp/features/digital_album/screens/digital_slideshow_player_screen.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

void main() {
  testWidgets('end-card share receives taps instead of pausing; header closes', (
    tester,
  ) async {
    var shares = 0;
    String? sharedText;
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'share') {
        shares++;
        sharedText = (call.arguments as Map)['text'] as String?;
      }
      return 'success';
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DigitalSlideshowPlayerScreen(
                    slideshow: DigitalSlideshow(
                      childId: 'test',
                      childName: 'Lina',
                      title: 'Souvenirs',
                      slides: [],
                      durationPerSlide: Duration(milliseconds: 100),
                    ),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slideshow-share')));
    await tester.pump();
    expect(shares, 1);
    expect(sharedText, contains('Lina'));
    expect(
      sharedText,
      contains(
        'https://play.google.com/store/apps/details?id=com.luckmam.luckmam_mvp&hl=en',
      ),
    );
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Fermer'), findsNothing);
    expect(find.text('Rejouer'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('slideshow-close')));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
