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
///
/// SECURITY NOTE: All API keys are stored server-side in the Cloud Function.
/// Never expose secret keys in client code — they are detected by Google Play
/// automated security scanners and cause immediate rejection.
class ChargilyPaymentService {
  static const String _cloudFunctionUrl =
      'https://us-central1-luckymam-app-dv.cloudfunctions.net/createChargilyCheckout';

  /// Creates a checkout session via the secure backend Cloud Function.
  ///
  /// The Cloud Function holds all Chargily API keys server-side.
  /// The client never touches the secret key directly.
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

    try {
      final response = await http
          .post(
            Uri.parse(_cloudFunctionUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChargilyCheckoutResult(
          success: true,
          checkoutId: data['checkoutId'],
          checkoutUrl: data['checkoutUrl'],
        );
      } else {
        final data = jsonDecode(response.body);
        debugPrint('[Chargily] Server error ${response.statusCode}: ${response.body}');
        return ChargilyCheckoutResult(
          success: false,
          errorMessage: data['message'] ?? 'فشل إنشاء جلسة الدفع',
        );
      }
    } catch (e) {
      debugPrint('[Chargily] Request failed: $e');
      return ChargilyCheckoutResult(
        success: false,
        errorMessage: 'خطأ في الاتصال بخادم الدفع. تحقق من الاتصال بالإنترنت.',
      );
    }
  }
}
