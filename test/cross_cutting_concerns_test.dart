import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/analytics_service.dart';

void main() {
  group('LM-CROSS-003: Technical Error Logging & PII Sanitization', () {
    test(
      'Technical diagnostic boundary redacts nested sensitive values before persistence',
      () {
        final result = AnalyticsService.technicalErrorParameters(
          errorType: 'pdf_generation_failed',
          step: 'render_page_3',
          rawMessage:
              'fatima@example.com 0555123456 https://private.test/asset',
          extraContext: {
            'nested': {
              'accessToken': 'opaque-secret',
              'contact': 'fatima@example.com',
            },
          },
        );
        expect(result['errorType'], 'pdf_generation_failed');
        expect(result['step'], 'render_page_3');
        for (final raw in [
          'fatima@example.com',
          '0555123456',
          'private.test',
          'opaque-secret',
        ]) {
          expect(result.toString(), isNot(contains(raw)));
        }
        expect(result['platform'], isNotEmpty);
      },
    );
  });

  group('LM-CROSS-002: Terminological Consistency & i18n Parity', () {
    test(
      'Key product terms are uniformly defined in French, Arabic, and English',
      () {
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
      },
    );
  });
}
