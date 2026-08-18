import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/services/analytics_service.dart';
import '../models/house_ad.dart';

/// Full-screen native ad page inserted inside the Reels feed.
/// Non-blocking: the user swipes past it like any reel.
class ReelAdItem extends StatefulWidget {
  const ReelAdItem({super.key, required this.ad, required this.isActive});

  final HouseAd ad;
  final bool isActive;

  @override
  State<ReelAdItem> createState() => _ReelAdItemState();
}

class _ReelAdItemState extends State<ReelAdItem> {
  bool _impressionLogged = false;

  @override
  void didUpdateWidget(covariant ReelAdItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLogImpression();
  }

  @override
  void initState() {
    super.initState();
    _maybeLogImpression();
  }

  void _maybeLogImpression() {
    if (widget.isActive && !_impressionLogged) {
      _impressionLogged = true;
      AnalyticsService().logEvent(
        'ad_impression',
        parameters: {
          'ad_id': widget.ad.id,
          'placement': widget.ad.placement.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final ad = widget.ad;
    final imageUrl = ad.safeImageUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Creative
        if (ad.assetPath != null)
          Image.asset(
            ad.assetPath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _gradient(ad, lang),
          )
        else if (imageUrl != null)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _gradient(ad, lang),
          )
        else
          _gradient(ad, lang),

        // Scrim for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.55),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Sponsor badge (top-left, below the feed's own top bar)
        Positioned(
          top: 110,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
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
        ),

        // Text + CTA (bottom)
        Positioned(
          left: 20,
          right: 20,
          bottom: 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad.getTitle(lang),
                style: AppTypography.fromContext(context,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ad.getSubtitle(lang),
                style: AppTypography.fromContext(context,
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              if (ad.getCtaLabel(lang) != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AnalyticsService().logEvent(
                        'ad_clicked',
                        parameters: {'ad_id': ad.id},
                      );
                      final route = ad.ctaRoute;
                      if (route != null) context.push(route);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      ad.getCtaLabel(lang)!,
                      style: AppTypography.fromContext(context,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _gradient(HouseAd ad, String lang) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ad.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(ad.icon, size: 80, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}
