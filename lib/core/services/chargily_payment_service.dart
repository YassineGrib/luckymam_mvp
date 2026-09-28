import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChargilyCheckoutResult {
  final bool success;
  final String? checkoutId;
  final String? checkoutUrl;
  final String? errorMessage;

  ChargilyCheckoutResult({
    required this.success,
    this.checkoutId,
    this.checkoutUrl,
    this.errorMessage,
  });
}

/// Service to handle Chargily Pay V2 integration.
class ChargilyPaymentService {
  static const String _cloudFunctionUrl =
      'https://us-central1-luckymam-app-dv.cloudfunctions.net/createChargilyCheckout';

  // Test mode credentials provided by user
  static const String testPublicKey =
      'test_pk_EHn7KhhKbaIj4aCYalTbA4z27EZff7TNXJjIA8PG';
  static const String testSecretKey =
      'test_sk_jvafVLt72Jkk8DIepElTKJLEANXnDxctuMEZHFYA';
  static const String _chargilyTestApi =
      'https://pay.chargily.net/test/api/v2/checkouts';

  /// Creates a checkout session.
  /// First attempts via Cloud Function (backend-first best practice).
  /// Falls back to direct Test API if the Cloud Function is not yet deployed.
  static Future<ChargilyCheckoutResult> createCheckout({
    required int amount,
    required String userId,
    required String type, // 'subscription' | 'order'
    String? planTier,
    String? orderId,
    String? customerName,
    String? customerPhone,
    String successUrl = 'https://luckymam-app-dv.web.app/#/payment-success',
    String failureUrl = 'https://luckymam-app-dv.web.app/#/payment-failure',
  }) async {
    final payload = <String, dynamic>{
      'amount': amount,
      'userId': userId,
      'type': type,
      'successUrl': successUrl,
      'failureUrl': failureUrl,
    };
    if (planTier != null) payload['planTier'] = planTier;
    if (orderId != null) payload['orderId'] = orderId;
    if (customerName != null) payload['customerName'] = customerName;
    if (customerPhone != null) payload['customerPhone'] = customerPhone;

    // 1. Try Cloud Function
    try {
      final response = await http
          .post(
            Uri.parse(_cloudFunctionUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChargilyCheckoutResult(
          success: true,
          checkoutId: data['checkoutId'],
          checkoutUrl: data['checkoutUrl'],
        );
      }
    } catch (e) {
      debugPrint('[Chargily] Cloud function not reached ($e), trying direct test API...');
    }

    // 2. Direct Chargily Test API Fallback (for immediate testing)
    try {
      final metadata = <String, dynamic>{
        'userId': userId,
        'type': type,
      };
      if (planTier != null) metadata['planTier'] = planTier;
      if (orderId != null) metadata['orderId'] = orderId;

      final chargilyPayload = {
        'amount': amount,
        'currency': 'dzd',
        'success_url': successUrl,
        'failure_url': failureUrl,
        'locale': 'ar',
        'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse(_chargilyTestApi),
        headers: {
          'Authorization': 'Bearer $testSecretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(chargilyPayload),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChargilyCheckoutResult(
          success: true,
          checkoutId: data['id'],
          checkoutUrl: data['checkout_url'],
        );
      } else {
        return ChargilyCheckoutResult(
          success: false,
          errorMessage: data['message'] ?? 'فشل إنشاء جلسة الدفع عبر شارجيلي',
        );
      }
    } catch (e) {
      return ChargilyCheckoutResult(
        success: false,
        errorMessage: 'خطأ في الاتصال بخادم الدفع: $e',
      );
    }
  }
}
