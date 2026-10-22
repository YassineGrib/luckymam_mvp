import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/pregnancy/screens/pregnancy_tracking_screen.dart';
import 'package:lukymam_mvp/features/profile/models/pregnancy.dart';
import 'package:lukymam_mvp/features/profile/models/profile_models.dart';
import 'package:lukymam_mvp/features/profile/providers/profile_providers.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'package:lukymam_mvp/shared/widgets/medical_disclaimer_banner.dart';

Widget _createTestApp({
  required Pregnancy? activePregnancy,
  UserProfile? profile,
  Locale locale = const Locale('fr'),
}) {
  return ProviderScope(
    overrides: [
      activePregnancyProvider.overrideWithValue(activePregnancy),
      profileProvider.overrideWith(
        (ref) => Stream.value(
          profile ??
              UserProfile(
                uid: 'user_1',
                displayName: 'Fatima',
                status: UserStatus.pregnant,
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
              ),
        ),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PregnancyTrackingScreen(),
    ),
  );
}

void main() {
  testWidgets('PregnancyTrackingScreen renders gestational week, countdown and disclaimer in French',
      (tester) async {
    final now = DateTime.now();
    final lmp = now.subtract(const Duration(days: 70)); // 10 weeks
    final pregnancy = Pregnancy(
      id: 'preg_1',
      lmpDate: lmp,
      eddDate: Pregnancy.eddFromLmp(lmp),
      status: PregnancyStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(_createTestApp(
      activePregnancy: pregnancy,
      locale: const Locale('fr'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(PregnancyTrackingScreen), findsOneWidget);
    expect(find.text('Suivi de grossesse'), findsOneWidget);
    expect(find.text('Semaine 10'), findsOneWidget);
    expect(find.byType(MedicalDisclaimerBanner), findsOneWidget);
    expect(find.textContaining('destinées au suivi'), findsOneWidget);
  });

  testWidgets('PregnancyTrackingScreen renders localized in Arabic',
      (tester) async {
    final now = DateTime.now();
    final lmp = now.subtract(const Duration(days: 84)); // 12 weeks
    final pregnancy = Pregnancy(
      id: 'preg_1',
      lmpDate: lmp,
      eddDate: Pregnancy.eddFromLmp(lmp),
      status: PregnancyStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(_createTestApp(
      activePregnancy: pregnancy,
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(PregnancyTrackingScreen), findsOneWidget);
    expect(find.text('متابعة الحمل'), findsOneWidget);
    expect(find.text('الأسبوع 12'), findsOneWidget);
    expect(find.textContaining('المعلومات الواردة للتتبع'), findsOneWidget);
  });
}
