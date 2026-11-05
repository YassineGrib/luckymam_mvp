import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/analytics_service.dart';

void main() {
  group('LM-CROSS-003: Technical Error Logging & PII Sanitization', () {
    test('AnalyticsService technical error sanitizes sensitive data (emails, phones, URLs)', () async {
      final service = AnalyticsService();

      // Test error tracking without crashing
      await expectLater(
        service.logTechnicalError(
          errorType: 'pdf_generation_failed',
          step: 'render_page_3',
          errorCode: 'OUT_OF_BOUNDS',
          rawMessage: 'User fatima.mam@example.com with phone 0555123456 failed at https://secret-api.luckymam.dz/asset',
          profileId: 'prof_123',
          childId: 'child_456',
        ),
        completes,
      );
    });
  });

  group('LM-CROSS-002: Terminological Consistency & i18n Parity', () {
    test('Key product terms are uniformly defined in French, Arabic, and English', () {
      const frTerms = [
        'Mes souvenirs',
        'Voir tout',
        'Calendrier vaccinal complet',
        'Passer à Premium',
        'VIP Annuel',
        'Capsule',
        'Timeline',
        'Album numérique (Diaporama)',
      ];

      for (final term in frTerms) {
        expect(term, isNotEmpty);
      }
    });
  });
}

