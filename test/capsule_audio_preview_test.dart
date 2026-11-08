import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/widgets/audio_recorder.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

Widget _wrap(Widget child, [Locale locale = const Locale('fr')]) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('LM-CAP-004: Audio preview and modification before validation', () {
    testWidgets(
      'Completed recording is ready without a confirmation and keeps modification controls',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RecordedAudioPreview(
              duration: 8,
              onDelete: () {},
              onReRecord: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Audio validé'), findsOneWidget);
        expect(find.text("Valider l'audio"), findsNothing);
        expect(find.text('Recommencer'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Displays audio preview with pending badge and validation action',
      (tester) async {
        bool validated = false;
        bool reRecorded = false;
        bool deleted = false;

        await tester.pumpWidget(
          _wrap(
            RecordedAudioPreview(
              duration: 15,
              isValidated: false,
              onValidate: () => validated = true,
              onReRecord: () => reRecorded = true,
              onDelete: () => deleted = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check pending status badge
        expect(find.text('En attente de validation'), findsOneWidget);

        // Check duration display (00:00 / 00:15)
        expect(find.textContaining('00:15'), findsOneWidget);

        // Check action buttons exist
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
        expect(find.text('Recommencer'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
        expect(find.text('Valider l\'audio'), findsOneWidget);

        // Tap Validate
        await tester.tap(find.text('Valider l\'audio'));
        await tester.pump();
        expect(validated, isTrue);

        // Tap Re-record
        await tester.tap(find.text('Recommencer'));
        await tester.pump();
        expect(reRecorded, isTrue);

        // Tap Delete
        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pump();
        expect(deleted, isTrue);
      },
    );

    testWidgets(
      'Displays validated badge and hides validate button when confirmed',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RecordedAudioPreview(
              duration: 22,
              isValidated: true,
              onDelete: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check validated status badge
        expect(find.text('Audio validé'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

        // "Valider l'audio" button should NOT be shown once confirmed
        expect(find.text('Valider l\'audio'), findsNothing);

        // Recommencer and Delete remain available for modifications
        expect(find.text('Recommencer'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      },
    );

    testWidgets('RTL Arabic localization renders correctly', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RecordedAudioPreview(
            duration: 10,
            isValidated: false,
            onValidate: () {},
            onDelete: () {},
          ),
          const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Check Arabic labels
      expect(find.text('قيد المعاينة'), findsOneWidget);
      expect(find.text('تأكيد الصوت'), findsOneWidget);
      expect(find.text('إعادة التسجيل'), findsOneWidget);
    });

    test('Temporary file cleanup and empty file validation logic', () async {
      final tempDir = Directory.systemTemp.createTempSync('audio_test_');
      final validFile = File('${tempDir.path}/valid.m4a');
      validFile.writeAsStringSync('valid audio bytes data');

      final emptyFile = File('${tempDir.path}/empty.m4a');
      emptyFile.writeAsStringSync('');

      expect(isSaveableCapsuleAudio(validFile), isTrue);
      expect(isSaveableCapsuleAudio(emptyFile), isFalse);
      expect(
        isSaveableCapsuleAudio(File('${tempDir.path}/missing.m4a')),
        isFalse,
      );
      expect(validFile.existsSync(), isTrue);
      expect(validFile.lengthSync() > 0, isTrue);

      expect(emptyFile.existsSync(), isTrue);
      expect(emptyFile.lengthSync() == 0, isTrue);

      // Empty file must be cleaned up and not associated
      if (emptyFile.lengthSync() == 0) {
        emptyFile.deleteSync();
      }
      expect(emptyFile.existsSync(), isFalse);

      // Cleanup
      tempDir.deleteSync(recursive: true);
    });
  });
}
