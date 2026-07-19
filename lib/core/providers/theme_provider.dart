import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'app_theme_mode';

/// Manages the app's ThemeMode. Default is light; the user's choice is
/// persisted and restored on launch.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    if (stored == ThemeMode.dark.name) {
      state = ThemeMode.dark;
    } else if (stored == ThemeMode.system.name) {
      state = ThemeMode.system;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, state.name);
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _persist();
  }

  void setMode(ThemeMode mode) {
    state = mode;
    _persist();
  }
}
