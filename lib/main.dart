import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/providers/profile_providers.dart';
import 'features/timeline/data/milestones_data.dart';
import 'features/timeline/screens/milestone_detail_screen.dart';
import 'features/timeline/services/timeline_service.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Timezone (also done inside NotificationService, but belt+suspenders)
  tz.initializeTimeZones();

  // Initialize notification service and request permissions
  final notificationService = NotificationService();
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: LuckymamApp()));
}

/// Root application widget with theming, localization, and routing.
class LuckymamApp extends ConsumerStatefulWidget {
  const LuckymamApp({super.key});

  @override
  ConsumerState<LuckymamApp> createState() => _LuckymamAppState();
}

class _LuckymamAppState extends ConsumerState<LuckymamApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.onNotificationTapped.addListener(
      _onNotificationTapped,
    );
    // Handle the case where a notification launched the app from terminated.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final launchPayload = await NotificationService().getLaunchPayload();
      _handleDeepLink(launchPayload);
    });
  }

  @override
  void dispose() {
    NotificationService.onNotificationTapped.removeListener(
      _onNotificationTapped,
    );
    super.dispose();
  }

  void _onNotificationTapped() {
    _handleDeepLink(NotificationService.onNotificationTapped.value);
  }

  /// Parses and validates a milestone-reminder notification payload, then
  /// deep-links to the milestone detail screen. Malformed or unknown
  /// child/milestone ids are silently ignored (deep-link validation).
  Future<void> _handleDeepLink(String? payload) async {
    if (payload == null || payload.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    if (data['type'] != 'milestone_reminder') return;
    final childId = data['childId'] as String?;
    final milestoneId = data['milestoneId'] as String?;
    if (childId == null || childId.isEmpty) return;
    if (milestoneId == null || milestoneId.isEmpty) return;
    if (!allMilestones.any((m) => m.id == milestoneId)) return;

    AnalyticsService().logEvent(
      'milestone_reminder_fired',
      parameters: {'milestone_id': milestoneId},
    );

    try {
      final children = await ref.read(childrenProvider.future);
      if (!children.any((c) => c.id == childId)) return;

      final milestones = await ref.read(
        childMilestonesProvider(childId).future,
      );
      final milestone = milestones
          .where((m) => m.milestone.id == milestoneId)
          .firstOrNull;
      if (milestone == null) return;

      AppRouter.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              MilestoneDetailScreen(milestone: milestone, childId: childId),
        ),
      );

      AnalyticsService().logEvent(
        'milestone_reminder_opened',
        parameters: {'milestone_id': milestoneId},
      );
    } catch (_) {
      // Not authenticated / data not available — ignore deep link.
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Luckymam',
      debugShowCheckedModeBanner: false,

      // Theming
      theme: AppTheme.lightTheme(activeLocale),
      darkTheme: AppTheme.darkTheme(activeLocale),
      themeMode: themeMode,

      // Localization
      locale: activeLocale,
      supportedLocales: const [
        Locale('fr'), // French - default
        Locale('ar'), // Arabic
        Locale('en'), // English
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routing
      routerConfig: AppRouter.router,
    );
  }
}
