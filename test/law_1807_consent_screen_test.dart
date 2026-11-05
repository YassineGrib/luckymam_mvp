import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/analytics_service.dart';
import 'package:lukymam_mvp/core/services/compliance_service.dart';
import 'package:lukymam_mvp/features/auth/law_1807_consent_screen.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';

class FakeComplianceService extends ComplianceService {
  bool saveConsentCalled = false;
  bool? lastConsent;

  @override
  Future<void> saveConsent({
    required bool consent,
    required String textVersion,
    required String fullText,
  }) async {
    saveConsentCalled = true;
    lastConsent = consent;
  }
}

class FakeAnalyticsService extends AnalyticsService {
  bool viewedCalled = false;
  bool acceptedCalled = false;
  bool blockedCalled = false;

  @override
  Future<void> logLaw1807Viewed() async {
    viewedCalled = true;
  }

  @override
  Future<void> logLaw1807Accepted() async {
    acceptedCalled = true;
  }

  @override
  Future<void> logLaw1807Blocked() async {
    blockedCalled = true;
  }
}

Widget _buildTestApp({
  required FakeComplianceService complianceService,
  required FakeAnalyticsService analyticsService,
  Locale locale = const Locale('fr'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Law1807ConsentScreen(
      complianceService: complianceService,
      analyticsService: analyticsService,
    ),
  );
}

void main() {
  group('Law1807ConsentScreen Tests (LM-ONB-001 & LM-ONB-002)', () {
    testWidgets('renders properly with legal title, text and updated checkbox wording', (tester) async {
      final compliance = FakeComplianceService();
      final analytics = FakeAnalyticsService();

      await tester.pumpWidget(_buildTestApp(
        complianceService: compliance,
        analyticsService: analytics,
        locale: const Locale('fr'),
      ));
      await tester.pumpAndSettle();

      expect(analytics.viewedCalled, isTrue);

      // Check updated legal wording (LM-ONB-001)
      expect(find.text('J’accepte les termes de la loi n° 18-07.'), findsOneWidget);

      // Check link to full legal text & privacy policy
      expect(find.text('Consulter le texte intégral et la politique de confidentialité'), findsOneWidget);
    });

    testWidgets('renders in Arabic with correct RTL legal wording', (tester) async {
      final compliance = FakeComplianceService();
      final analytics = FakeAnalyticsService();

      await tester.pumpWidget(_buildTestApp(
        complianceService: compliance,
        analyticsService: analytics,
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // Check Arabic legal text
      expect(find.text('أوافق على شروط وأحكام القانون رقم 18-07.'), findsOneWidget);
      expect(find.text('قراءة النص الكامل وسياسة الخصوصية'), findsOneWidget);
    });

    testWidgets('checkbox is immediately clickable without forced scrolling (LM-ONB-002)', (tester) async {
      final compliance = FakeComplianceService();
      final analytics = FakeAnalyticsService();

      await tester.pumpWidget(_buildTestApp(
        complianceService: compliance,
        analyticsService: analytics,
      ));
      await tester.pumpAndSettle();

      // Find Checkbox
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);
      expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);

      // Tap on the checkbox row text directly (large touch target)
      await tester.tap(find.text('J’accepte les termes de la loi n° 18-07.'));
      await tester.pumpAndSettle();

      // Should be checked immediately on single tap!
      expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);

      // Tap again to toggle off
      await tester.tap(find.text('J’accepte les termes de la loi n° 18-07.'));
      await tester.pumpAndSettle();

      expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);
    });

    testWidgets('attempting to continue without checking triggers error and analytics', (tester) async {
      final compliance = FakeComplianceService();
      final analytics = FakeAnalyticsService();

      await tester.pumpWidget(_buildTestApp(
        complianceService: compliance,
        analyticsService: analytics,
      ));
      await tester.pumpAndSettle();

      // Tap Continuer while unchecked
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // Should trigger blocked analytics and snackbar
      expect(analytics.blockedCalled, isTrue);
      expect(compliance.saveConsentCalled, isFalse);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('checking and continuing triggers saveConsent and accepted analytics', (tester) async {
      final compliance = FakeComplianceService();
      final analytics = FakeAnalyticsService();

      await tester.pumpWidget(_buildTestApp(
        complianceService: compliance,
        analyticsService: analytics,
      ));
      await tester.pumpAndSettle();

      // Tap to accept
      await tester.tap(find.text('J’accepte les termes de la loi n° 18-07.'));
      await tester.pumpAndSettle();

      // Tap Continuer
      await tester.tap(find.text('Continuer'));
      await tester.pump();

      expect(compliance.saveConsentCalled, isTrue);
      expect(compliance.lastConsent, isTrue);
      expect(analytics.acceptedCalled, isTrue);
    });
  });
}
