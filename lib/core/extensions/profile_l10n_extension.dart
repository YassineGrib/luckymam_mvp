import '../../features/profile/models/profile_models.dart';
import '../../l10n/app_localizations.dart';

/// Maps internal French cycle phase keys from [CycleInfo.currentPhase] to l10n.
String localizedCyclePhase(AppLocalizations l10n, String phase) {
  switch (phase) {
    case 'Règles':
      return l10n.profilePhasePeriod;
    case 'Phase Folliculaire':
      return l10n.profilePhaseFollicular;
    case 'Phase Ovulatoire':
      return l10n.profilePhaseOvulatory;
    case 'Phase Lutéale':
      return l10n.profilePhaseLuteal;
    default:
      return phase;
  }
}

/// Localized gender label for a [ChildGender].
String childGenderLabel(AppLocalizations l10n, ChildGender gender) {
  return gender == ChildGender.girl ? l10n.profileGirl : l10n.profileBoy;
}

/// Localized age string from [birthDate].
String childAgeString(AppLocalizations l10n, DateTime birthDate) {
  final now = DateTime.now();
  final months =
      (now.year - birthDate.year) * 12 + now.month - birthDate.month;

  if (months < 12) {
    return l10n.profileAgeMonthsOnly(months);
  }

  final years = months ~/ 12;
  final remainingMonths = months % 12;
  if (remainingMonths == 0) {
    return l10n.profileAgeYearsOnly(years);
  }
  return l10n.profileAgeYearsAndMonths(years, remainingMonths);
}

/// Localized user status label.
String userStatusLabel(AppLocalizations l10n, UserStatus status) {
  switch (status) {
    case UserStatus.pregnant:
      return l10n.statusPregnant;
    case UserStatus.hope:
      return l10n.statusHope;
    case UserStatus.mom:
      return l10n.statusMom;
  }
}

/// Localized current cycle phase for [CycleInfo].
String cycleCurrentPhaseLabel(AppLocalizations l10n, CycleInfo cycleInfo) {
  return localizedCyclePhase(l10n, cycleInfo.currentPhase);
}

/// Extension helpers on profile models (prefer these over hardcoded getters).
extension ChildL10n on Child {
  String localizedGenderLabel(AppLocalizations l10n) =>
      childGenderLabel(l10n, gender);

  String localizedAgeString(AppLocalizations l10n) =>
      childAgeString(l10n, birthDate);
}

extension UserProfileL10n on UserProfile {
  String localizedStatusLabel(AppLocalizations l10n) =>
      userStatusLabel(l10n, status);
}

extension CycleInfoL10n on CycleInfo {
  String localizedCurrentPhase(AppLocalizations l10n) =>
      cycleCurrentPhaseLabel(l10n, this);
}
