import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Screen to host Chargily Pay V2 Checkout page.
class ChargilyCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final String? checkoutId;
  final String successUrl;
  final String failureUrl;
  final VoidCallback? onSuccess;

  const ChargilyCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    this.checkoutId,
    this.successUrl = 'https://luckymam-app-dv.web.app/#/payment-success',
    this.failureUrl = 'https://luckymam-app-dv.web.app/#/payment-failure',
    this.onSuccess,
  });

  @override
  State<ChargilyCheckoutScreen> createState() => _ChargilyCheckoutScreenState();
}

class _ChargilyCheckoutScreenState extends State<ChargilyCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasLaunchedWeb = false;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted) setState(() => _isLoading = true);
              _checkRedirect(url);
            },
            onPageFinished: (url) {
              if (mounted) setState(() => _isLoading = false);
              _checkRedirect(url);
            },
            onNavigationRequest: (request) {
              if (_checkRedirect(request.url)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.checkoutUrl));
    } else {
      // On Web, launch in browser
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchWebUrl();
      });
    }
  }

  Future<void> _launchWebUrl() async {
    if (_hasLaunchedWeb) return;
    _hasLaunchedWeb = true;
    final uri = Uri.parse(widget.checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _checkRedirect(String url) {
    if (url.contains(widget.successUrl) || url.contains('payment-success')) {
      widget.onSuccess?.call();
      if (mounted) {
        Navigator.pop(context, true);
      }
      return true;
    }
    if (url.contains(widget.failureUrl) || url.contains('payment-failure')) {
      if (mounted) {
        Navigator.pop(context, false);
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF5801A2).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Chargily Pay',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5801A2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'الدفع الآمن (الذهبية / CIB)',
              style: AppTypography.fromContext(
                context,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: kIsWeb
          ? _buildWebFallback(context, textColor)
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  Widget _buildWebFallback(BuildContext context, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.payment_rounded,
              size: 64,
              color: Color(0xFF5801A2),
            ),
            const SizedBox(height: 24),
            Text(
              'تم فتح بوابة الدفع في نافذة جديدة',
              style: AppTypography.fromContext(
                context,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'يرجى إكمال عملية الدفع عبر بطاقتكم الذهبية أو CIB، ثم الضغط على الزر أدناه لتأكيد التفعيل.',
              style: AppTypography.fromContext(
                context,
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                widget.onSuccess?.call();
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('تأكيد إتمام الدفع بنجاح'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _launchWebUrl(),
              child: const Text('إعادة فتح رابط الدفع'),
            ),
          ],
        ),
      ),
    );
  }
}
