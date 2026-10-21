import '../models/mother_stage.dart';
import '../models/profile_models.dart';

/// Pure plan describing how to migrate a legacy profile to the mother journey model.
class ProfileMigrationPlan {
  /// Whether an active pregnancy record and expected child doc should be created.
  final bool createPregnancy;

  /// The last menstrual period (LMP) date to use for the pregnancy record.
  final DateTime? lmp;

  /// Whether tryingToConceive flag should be enabled on the profile.
  final bool setTryingToConceive;

  const ProfileMigrationPlan({
    required this.createPregnancy,
    this.lmp,
    required this.setTryingToConceive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileMigrationPlan &&
          runtimeType == other.runtimeType &&
          createPregnancy == other.createPregnancy &&
          lmp == other.lmp &&
          setTryingToConceive == other.setTryingToConceive;

  @override
  int get hashCode => Object.hash(createPregnancy, lmp, setTryingToConceive);

  @override
  String toString() =>
      'ProfileMigrationPlan(createPregnancy: $createPregnancy, lmp: $lmp, setTryingToConceive: $setTryingToConceive)';
}

/// Checks whether the user profile requires migration to schema version 2.
bool needsMigration(UserProfile profile) {
  return profile.schemaVersion < kCurrentProfileSchemaVersion;
}

/// Builds a pure [ProfileMigrationPlan] based on the user's legacy profile data:
/// - `pregnant` + `lastPregnancyDate != null` => create pregnancy using `lastPregnancyDate`
/// - `hope` => set tryingToConceive = true
/// - preserves existing `tryingToConceive` flag if user was already TTC
ProfileMigrationPlan buildProfileMigration(UserProfile profile) {
  final canCreatePregnancy =
      profile.status == UserStatus.pregnant &&
      profile.lastPregnancyDate != null;

  final setTtc = profile.status == UserStatus.hope ||
      (!canCreatePregnancy && profile.tryingToConceive);

  return ProfileMigrationPlan(
    createPregnancy: canCreatePregnancy,
    lmp: canCreatePregnancy ? profile.lastPregnancyDate : null,
    setTryingToConceive: setTtc,
  );
}
