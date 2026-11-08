import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/capsules/models/emotion.dart';
import 'package:lukymam_mvp/features/capsules/widgets/emotion_picker.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

void main() {
  for (final language in ['fr', 'ar', 'en']) {
    testWidgets('Equal emotion cards allow 1-3 selections ($language)', (
      tester,
    ) async {
      // Nested capsule padding leaves less than 330 logical pixels on phones.
      await tester.binding.setSurfaceSize(const Size(340, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var selected = <Emotion>[];
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder: (context, update) => EmotionPicker(
                  selectedEmotions: selected,
                  onChanged: (value) => update(() => selected = value),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Finder card(int index) =>
          find.byKey(ValueKey('emotion-${Emotion.values[index].name}'));
      final size = tester.getSize(card(0));
      expect(size.height, lessThan(96));
      final firstRowY = tester.getTopLeft(card(0)).dy;
      expect(tester.getTopLeft(card(1)).dy, firstRowY);
      expect(tester.getTopLeft(card(2)).dy, firstRowY);
      expect(tester.getTopLeft(card(3)).dy, greaterThan(firstRowY));
      for (var i = 1; i < Emotion.values.length; i++) {
        expect(tester.getSize(card(i)), size);
      }
      await tester.tap(card(0));
      await tester.pump();
      expect(selected.length, 1);
      expect(find.text('1 / 3'), findsOneWidget);
      for (var i = 1; i < 3; i++) {
        await tester.tap(card(i));
        await tester.pump();
      }
      expect(selected.length, 3);
      expect(tester.widget<InkWell>(card(3)).onTap, isNull);
      await tester.tap(card(0));
      await tester.pump();
      expect(selected.length, 2);
      expect(tester.widget<InkWell>(card(3)).onTap, isNotNull);
      await tester.tap(card(3));
      await tester.pump();
      expect(selected.length, 3);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('primary'), findsNothing);
      expect(find.textContaining('secondary'), findsNothing);
    });
  }
}
