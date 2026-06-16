import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lukymam_mvp/l10n/app_localizations.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
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
class LuckymamApp extends ConsumerWidget {
  const LuckymamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Luckymam',
      debugShowCheckedModeBanner: false,

      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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
