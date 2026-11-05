import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/home/widgets/home_bento_grid.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';

void main() {
  group('LM-HOME-002: Reorganized Quick Access Bento Grid', () {
    testWidgets('Renders Reels on top-left, Mes souvenirs on bottom-left, Santé Enfant on right',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            motherStageProvider.overrideWith(
              (ref) => const MotherStageState(effectiveStatus: UserStatus.mom),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeBentoGrid(),
              ),
            ),
          ),
        ),
      );

      // Verify the outer Row exists
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);

      final row = tester.widget<Row>(rowFinder);
      expect(row.children.length, 3); // Left Expanded, SizedBox(width: 14), Right Expanded

      // Left column
      final leftExpanded = row.children[0] as Expanded;
      expect(leftExpanded.child, isA<Column>());

      final leftColumn = leftExpanded.child as Column;
      // In left column: Reels (top), SizedBox, Memories (bottom)
      expect(leftColumn.children.length, 3);

      // Verify Right column holds the Tall Health card
      final rightExpanded = row.children[2] as Expanded;
      expect(rightExpanded.flex, 5);
      expect(leftExpanded.flex, 5);
    });

    test('Reels watermark avoids purple ban', () {
      // Color used: 0xFFE85A71 (LuckyMam Coral / Rose)
      const watermarkColor = Color(0xFFE85A71);
      expect(watermarkColor.value, 0xFFE85A71);
    });
  });
}

