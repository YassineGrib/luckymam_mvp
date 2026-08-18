import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/gradient_scaffold.dart';
import '../../core/services/analytics_service.dart';
import '../ads/providers/ads_providers.dart';
import '../ads/screens/interstitial_ad_screen.dart';
import '../subscription/providers/subscription_providers.dart';
import '../subscription/screens/diamond_sponsors_screen.dart';
import '../profile/services/profile_service.dart';

/// Animated splash screen with logo fade-in.
/// Shows sponsors interstitial (2s), then the launch ad slot (plan-gated),
/// then routes to home or onboarding.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Log splash shown event
    AnalyticsService().logSplashShown();

    // After logo animation → show sponsors interstitial
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      String destination = '/onboarding';

      if (user != null) {
        try {
          final profile = await ProfileService().getProfile();
          if (profile != null && profile.consent1807 == true) {
            destination = '/home';
          } else {
            destination = '/law-consent';
          }
        } catch (e) {
          destination = '/law-consent';
        }
      }

      if (!mounted) return;
      // Show sponsors overlay for 2 s, then the launch ad slot, then navigate
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _SponsorInterstitial(
          onDone: () {
            Navigator.of(ctx).pop();
            _showLaunchAdThenGo(destination);
          },
        ),
      );
    });
  }

  /// Launch ad slot: only for signed-in users heading to home, gated by
  /// plan (VIP: none). Waits for the real tier before deciding, so a VIP
  /// is never shown an ad because the tier hadn't loaded yet.
  Future<void> _showLaunchAdThenGo(String destination) async {
    if (destination != '/home') {
      if (mounted) context.go(destination);
      return;
    }
    try {
      await ref
          .read(currentTierProvider.future)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // Tier unknown — skip the ad rather than guessing.
      if (mounted) context.go(destination);
      return;
    }
    if (!mounted) return;

    final ad = await ref.read(adGateProvider).requestSplashAd();
    if (!mounted) return;
    if (ad == null) {
      context.go(destination);
      return;
    }
    InterstitialAdScreen.show(
      context,
      ad,
      onDone: () {
        if (mounted) context.go(destination);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: const AppLogo(
            variant: LogoVariant.vertical,
            size: LogoSize.large,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sponsor Interstitial — shows for 2 seconds after splash, then auto-dismisses
// ─────────────────────────────────────────────────────────────────────────────

class _SponsorInterstitial extends StatefulWidget {
  const _SponsorInterstitial({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_SponsorInterstitial> createState() => _SponsorInterstitialState();
}

class _SponsorInterstitialState extends State<_SponsorInterstitial> {
  @override
  void initState() {
    super.initState();
    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(
          children: [
            // Full DiamondSponsorsScreen content (without AppBar)
            const DiamondSponsorsScreen(showAppBar: false),
            // Top "skip" bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    GestureDetector(
                      onTap: widget.onDone,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Passer ›',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
