import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

/// SharedPreferences key for the active app locale (mirrors [LocaleNotifier]).
const kAppLocaleKey = 'app_locale';

/// Loads [AppLocalizations] for background services (notifications) using the
/// locale persisted by the user, defaulting to French.
Future<AppLocalizations> loadStoredL10n() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(kAppLocaleKey) ?? 'fr';
  return lookupAppLocalizations(Locale(code));
}
