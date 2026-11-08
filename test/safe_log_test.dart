import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/core/services/safe_log.dart';

void main() {
  test(
    'nested logs redact contacts, credentials, private links and unknown objects',
    () {
      final clean = SafeLog.sanitize({
        'step': 'save_capsule',
        'context': [
          {
            'message':
                'fatima@example.com 0555123456 +213 555 12 34 56 https://private.test/file?token=hidden',
          },
          {
            'accessToken': 'opaque-device-secret',
            'responseBody': 'private body',
          },
        ],
        'error': Exception('fatima@example.com'),
      }).toString();
      for (final secret in [
        'fatima@example.com',
        '0555123456',
        '+213',
        'private.test',
        'opaque-device-secret',
        'private body',
      ]) {
        expect(clean, isNot(contains(secret)));
      }
      expect(clean, contains('save_capsule'));
      expect(clean, contains('REDACTED'));
    },
  );

  test(
    'formatted local and international Algerian phone numbers are redacted',
    () {
      for (final phone in [
        '0555123456',
        '05 55 12 34 56',
        '+213555123456',
        '00213 555 12 34 56',
      ]) {
        expect(SafeLog.text('contact $phone'), 'contact [REDACTED_PHONE]');
      }
    },
  );
}
