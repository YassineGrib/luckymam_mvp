import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/home/widgets/home_bento_grid.dart';
import 'package:lukymam_mvp/features/profile/models/mother_stage.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';

void main() {
  group('LM-HOME-002: Reorganized Quick Access Bento Grid', () {
    testWidgets(
      'Renders Reels on top-left, Mes souvenirs on bottom-left, Santé Enfant on right',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              motherStageProvider.overrideWith((ref) => MotherStage.mom),
            ],
            child: MaterialApp(
              locale: const Locale('fr'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: const SingleChildScrollView(child: HomeBentoGrid()),
              ),
            ),
          ),
        );

        final labels = AppLocalizations.of(tester.element(find.byType(HomeBentoGrid)))!;
      final reels = find.text(labels.reelsTitle);
      final memories = find.text(labels.dashboardMyMemories);
      final health = find.text(labels.homeHealthTitle);
      expect(reels, findsOneWidget);
      expect(memories, findsOneWidget);
      expect(health, findsOneWidget);
      expect(tester.getCenter(reels).dy, lessThan(tester.getCenter(memories).dy));
      expect(tester.getCenter(reels).dx, lessThan(tester.getCenter(health).dx));
      expect(tester.takeException(), isNull);
    });
  });
}
