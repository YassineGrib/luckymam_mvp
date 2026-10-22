import 'profile_models.dart';

/// Target schema version for user profiles after mother journey migration.
const int kCurrentProfileSchemaVersion = 2;

/// Derived life stage of a mother, computed client-side from independent facts
/// (born children count, active pregnancy, and trying-to-conceive flag).
enum MotherStage {
  /// Newly married, not trying yet / exploring (0 children, no active pregnancy, not TTC).
  exploring,

  /// Trying to conceive (0 children, no active pregnancy, TTC).
  hope,

  /// First pregnancy (0 born children, active pregnancy).
  pregnantFirst,

  /// Pregnant again with existing children (>=1 born children, active pregnancy).
  pregnantWithChildren,

  /// Mother with children, not currently trying (>=1 born children, no active pregnancy, not TTC).
  mom,

  /// Mother with children, trying for another child (>=1 born children, no active pregnancy, TTC).
  momHope;

  /// Whether the mother is currently carrying an active pregnancy.
  bool get isPregnant =>
      this == MotherStage.pregnantFirst ||
      this == MotherStage.pregnantWithChildren;

  /// Whether the mother already has at least one born child.
  bool get hasChildren =>
      this == MotherStage.pregnantWithChildren ||
      this == MotherStage.mom ||
      this == MotherStage.momHope;

  /// Whether the mother is actively tracking her menstrual / ovulation cycle to conceive.
  bool get tracksCycle =>
      this == MotherStage.hope || this == MotherStage.momHope;

  /// Effective active mode for UI display:
  /// - `pregnantFirst`, `pregnantWithChildren` => [UserStatus.pregnant]
  /// - `exploring`, `hope`, `momHope` => [UserStatus.hope]
  /// - `mom` => [UserStatus.mom]
  UserStatus get effectiveStatus {
    if (isPregnant) return UserStatus.pregnant;
    if (this == MotherStage.exploring || tracksCycle) return UserStatus.hope;
    return UserStatus.mom;
  }

  /// Legacy [UserStatus] equivalent for backward compatibility.
  /// - `pregnant*` => [UserStatus.pregnant]
  /// - `hope` / `exploring` => [UserStatus.hope]
  /// - `mom` / `momHope` => [UserStatus.mom]
  UserStatus get legacyStatus {
    switch (this) {
      case MotherStage.pregnantFirst:
      case MotherStage.pregnantWithChildren:
        return UserStatus.pregnant;
      case MotherStage.exploring:
      case MotherStage.hope:
        return UserStatus.hope;
      case MotherStage.mom:
      case MotherStage.momHope:
        return UserStatus.mom;
    }
  }
}

/// Derives the client-side [MotherStage] from three independent facts:
/// - [bornChildren]: count of children with `lifecycle == ChildLifecycle.born`
/// - [hasActivePregnancy]: whether there is an active pregnancy record
/// - [tryingToConceive]: whether user enabled TTC mode ([UserProfile.tryingToConceive])
MotherStage deriveMotherStage({
  required int bornChildren,
  required bool hasActivePregnancy,
  required bool tryingToConceive,
}) {
  final hasBorn = bornChildren > 0;
  if (hasActivePregnancy) {
    return hasBorn
        ? MotherStage.pregnantWithChildren
        : MotherStage.pregnantFirst;
  }
  if (hasBorn) {
    return tryingToConceive ? MotherStage.momHope : MotherStage.mom;
  }
  return tryingToConceive ? MotherStage.hope : MotherStage.exploring;
}
