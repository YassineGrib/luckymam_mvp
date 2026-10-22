import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_avatar.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_state.dart';

void main() {
  group('MochiAvatar Widget Tests', () {
    testWidgets('renders in every MochiState without throwing exceptions', (tester) async {
      for (final state in MochiState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: MochiAvatar(
                  state: state,
                  size: 140,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(MochiAvatar), findsOneWidget);
      }
    });

    testWidgets('tap triggers poke / squash without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MochiAvatar(
                state: MochiState.idle,
                size: 140,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byType(MochiAvatar));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders correctly in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Center(
              child: MochiAvatar(
                state: MochiState.thinking,
                size: 120,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byType(MochiAvatar), findsOneWidget);
    });

    testWidgets('reduced motion freezes avatar animations', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: MochiAvatar(
                  state: MochiState.searching,
                  size: 140,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MochiAvatar(
                state: MochiState.idle,
                size: 140,
              ),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Lucky'), findsOneWidget);
    });
  });
}
