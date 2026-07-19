import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';
const _supportedLocales = ['fr', 'ar', 'en'];

/// Notifier to manage the active locale. Default is French; the user's
/// choice is persisted and restored on launch.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kLocaleKey);
    if (stored != null && _supportedLocales.contains(stored)) {
      state = Locale(stored);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    if (!_supportedLocales.contains(locale.languageCode)) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

/// Provider for the application's active locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
