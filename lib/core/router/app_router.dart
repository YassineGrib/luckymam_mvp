import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/privacy_policy_screen.dart';
import '../../features/auth/law_1807_consent_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/reels/screens/reels_screen.dart';
import '../../features/subscription/screens/diamond_sponsors_screen.dart';
import '../../features/health/screens/health_hub_screen.dart';
import '../../features/memory_book/screens/memory_book_screen.dart';
import '../../features/memory_book/screens/album_template_picker_screen.dart';
import '../../features/marketplace/screens/cart_screen.dart';
import '../../features/marketplace/screens/checkout_screen.dart';
import '../../features/marketplace/screens/my_orders_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/home/tabs/timeline_tab.dart';

/// App router configuration with soft page transitions.
class AppRouter {
  AppRouter._();

  /// Root navigator key — used to push routes (e.g. notification deep links)
  /// from outside the widget tree that has a BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // Sign Up
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const SignUpScreen(),
        ),
      ),

      // Forgot Password
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return _buildPageWithTransition(
            key: state.pageKey,
            child: ForgotPasswordScreen(initialEmail: email),
          );
        },
      ),

      // Home (Main app with bottom nav)
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
      ),

      // Reels (Educational short videos)
      GoRoute(
        path: '/reels',
        name: 'reels',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const ReelsScreen(),
        ),
      ),

      // Privacy Policy & Terms of Use
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab =
              tabParam == 'terms' ? LegalTab.terms : LegalTab.privacy;
          return _buildPageWithTransition(
            key: state.pageKey,
            child: PrivacyPolicyScreen(initialTab: initialTab),
          );
        },
      ),
      GoRoute(
        path: '/terms-of-use',
        name: 'terms-of-use',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(initialTab: LegalTab.terms),
        ),
      ),

      // Partner Marketplace
      GoRoute(
        path: '/marketplace',
        name: 'marketplace',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const MarketplaceScreen(),
        ),
      ),

      // Diamond Sponsors
      GoRoute(
        path: '/sponsors-diamant',
        name: 'sponsors-diamant',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const DiamondSponsorsScreen(),
        ),
      ),

      // Law 18-07 Privacy Consent Compliance Screen
      GoRoute(
        path: '/law-consent',
        name: 'law-consent',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const Law1807ConsentScreen(),
        ),
      ),

      // Health Hub (Santé Enfant)
      GoRoute(
        path: '/health',
        name: 'health',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const HealthHubScreen(),
        ),
      ),

      // Memory Book
      GoRoute(
        path: '/memory-book',
        name: 'memory-book',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const MemoryBookScreen(),
        ),
      ),

      // Album Template Picker
      GoRoute(
        path: '/album-templates',
        name: 'album-templates',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const AlbumTemplatePickerScreen(
            childId: 'c1',
            childName: 'Amine',
          ),
        ),
      ),

      // Cart
      GoRoute(
        path: '/cart',
        name: 'cart',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const CartScreen(),
        ),
      ),

      // Checkout
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const CheckoutScreen(),
        ),
      ),

      // My Orders
      GoRoute(
        path: '/orders',
        name: 'orders',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const MyOrdersScreen(),
        ),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),

      // Timeline
      GoRoute(
        path: '/timeline',
        name: 'timeline',
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const Scaffold(body: SafeArea(child: TimelineTab())),
        ),
      ),
    ],
  );

  /// Builds a page with soft fade + slide transition.
  static CustomTransitionPage<void> _buildPageWithTransition({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        // Slide transition (subtle)
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
