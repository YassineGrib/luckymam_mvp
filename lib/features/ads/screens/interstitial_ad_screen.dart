import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../models/house_ad.dart';
import '../providers/ads_providers.dart';

/// Full-screen house ad with a plan-dependent non-skippable countdown
/// (Gratuit 5 s · Premium 3 s). The close button only appears once the
/// timer elapses. [onDone] runs after the ad is dismissed.
class InterstitialAdScreen extends ConsumerStatefulWidget {
  const InterstitialAdScreen({super.key, required this.ad, this.onDone});

  final HouseAd ad;
  final VoidCallback? onDone;

  /// Pushes the ad as a fullscreen dialog route.
  static Future<void> show(
    BuildContext context,
    HouseAd ad, {
    VoidCallback? onDone,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: InterstitialAdScreen(ad: ad, onDone: onDone),
        ),
      ),
    );
  }

  @override
  ConsumerState<InterstitialAdScreen> createState() =>
      _InterstitialAdScreenState();
}

class _InterstitialAdScreenState extends ConsumerState<InterstitialAdScreen> {
  late int _remaining;
  Timer? _timer;
  bool _closable = false;

  @override
  void initState() {
    super.initState();
    _remaining = ref.read(adTimerSecondsProvider);

    AnalyticsService().logEvent(
      'ad_impression',
      parameters: {
        'ad_id': widget.ad.id,
        'placement': widget.ad.placement.name,
      },
    );

    if (_remaining <= 0) {
      _closable = true;
    } else {
      AnalyticsService().logEvent(
        'ad_timer_started',
        parameters: {'ad_id': widget.ad.id, 'duration_s': _remaining},
      );
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _remaining--;
          if (_remaining <= 0) {
            _closable = true;
            t.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _close() {
    AnalyticsService().logEvent(
      'ad_closed',
      parameters: {'ad_id': widget.ad.id},
    );
    Navigator.of(context).pop();
    widget.onDone?.call();
  }

  void _onCta() {
    final route = widget.ad.ctaRoute;
    AnalyticsService().logEvent(
      'ad_clicked',
      parameters: {'ad_id': widget.ad.id},
    );
    Navigator.of(context).pop();
    widget.onDone?.call();
    // push (not go) so the destination keeps a back stack.
    if (route != null && route != '/home') context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final ad = widget.ad;
    final imageUrl = ad.safeImageUrl;

    // Back is blocked until the timer elapses (non-skippable requirement).
    return PopScope(
      canPop: _closable,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Creative ─────────────────────────────────────────────
            if (ad.assetPath != null)
              Image.asset(
                ad.assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _gradientCreative(ad, lang),
              )
            else if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _gradientCreative(ad, lang),
              )
            else
              _gradientCreative(ad, lang),

            // ── Top bar: sponsor badge + timer / close ───────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.adsSponsored(ad.getSponsorName(lang)),
                        style: AppTypography.fromContext(context,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _closable
                        ? GestureDetector(
                            onTap: _close,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_remaining',
                                style: AppTypography.fromContext(context,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ───────────────────────────────────────────
            if (ad.getCtaLabel(lang) != null)
              Positioned(
                left: 24,
                right: 24,
                bottom: 40,
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: _onCta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      ad.getCtaLabel(lang)!,
                      style: AppTypography.fromContext(context,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _gradientCreative(HouseAd ad, String lang) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ad.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ad.icon, size: 72, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                ad.getTitle(lang),
                textAlign: TextAlign.center,
                style: AppTypography.fromContext(context,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                ad.getSubtitle(lang),
                textAlign: TextAlign.center,
                style: AppTypography.fromContext(context,
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
