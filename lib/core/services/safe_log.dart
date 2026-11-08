import 'package:flutter/foundation.dart';

/// One boundary for diagnostic output. Never log media, credentials or raw payloads.
class SafeLog {
  static final _sensitiveKey = RegExp(
    r'email|phone|mobile|token|password|authorization|cookie|secret|credential|payload|responsebody',
    caseSensitive: false,
  );
  static final _email = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  static final _url = RegExp(r'https?://\S+', caseSensitive: false);
  static final _phone = RegExp(
    r'(?<!\w)(?:(?:\+|00)213[\s.-]?[5-7]|0[5-7])(?:[\s.-]?\d){8}(?!\d)',
  );

  static String text(String value) => value
      .replaceAll(_email, '[REDACTED_EMAIL]')
      .replaceAll(_url, '[REDACTED_URL]')
      .replaceAll(_phone, '[REDACTED_PHONE]');

  static Object? sanitize(Object? value, {String? key}) {
    if (key != null && _sensitiveKey.hasMatch(key)) return '[REDACTED]';
    if (value == null || value is num || value is bool) return value;
    if (value is String) return text(value);
    if (value is Map) {
      return value.map(
        (key, item) =>
            MapEntry(text(key.toString()), sanitize(item, key: key.toString())),
      );
    }
    if (value is Iterable) return value.map((item) => sanitize(item)).toList();
    // Exceptions/custom objects can stringify arbitrary request or user data.
    return value.runtimeType.toString();
  }
}

void safeDebugPrint(String? message, {int? wrapWidth}) {
  if (kDebugMode && message != null)
    debugPrint(SafeLog.text(message), wrapWidth: wrapWidth);
}
