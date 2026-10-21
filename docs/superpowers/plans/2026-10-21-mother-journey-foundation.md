# Mother Journey — Data Foundation Implementation Plan (Plan 1 of 4)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single mutually-exclusive `UserStatus` with derived mother stages, add pregnancies + expected children (unknown sex), and give capsules multiple subjects (children / mother / family), without breaking existing screens or data.

**Architecture:** Pure model logic (stage derivation, pregnancy maths, capsule space) lives in plain Dart with unit tests. Firestore access stays in `ProfileService` / `CapsuleService`; Riverpod providers expose capability flags (`isPregnantProvider`, `hasBornChildrenProvider`) that widgets consume instead of switching on `status`. A one-time, idempotent client migration (guarded by `schemaVersion`) upgrades existing users.

**Tech Stack:** Flutter, Riverpod 2 (`Provider`/`StreamProvider`), cloud_firestore 5, flutter_test, gen-l10n (fr/ar/en).

**Spec:** `docs/specs/SPEC_mother_journey_and_ai_assistant.md` §1–§3 (FR/AR: `docs/specs/parcours_maman_ia/`)

**Out of scope here (later plans):** Plan 2 = UI (onboarding questions, declare-pregnancy sheet, birth wizard, pregnancy-end flow, mother journey screen, "Qui est sur ce souvenir ?" picker). Plan 3 = AI backend + marketplace fields. Plan 4 = bird avatar + assistant screen.

## Global Constraints

- UI copy in French first, plus `ar` and `en` in `lib/l10n/app_*.arb`; run `flutter gen-l10n` after editing `.arb`. Never hard-code new user-facing strings in Dart.
- No new packages in this plan.
- Existing Firestore docs must keep parsing: a missing `lifecycle` ⇒ `born`; a missing/invalid `gender` ⇒ `unknown` (never `boy`); a missing `childIds` ⇒ `[childId]` if `childId` non-empty else `[]`.
- Keep writing `status` (`pregnant|mom|hope`) on the user doc as a derived value for admin + old app versions.
- `flutter analyze` on every modified file: zero new issues. `flutter test` green.
- Work on branch `feat/mother-journey-foundation`; one commit per task, message ends with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Deliberate deviation from spec §3.2:** `Child.birthDate` stays a non-null `DateTime` in Dart. For expected children it holds the expected date (EDD); Firestore stores `birthDate: null` + `expectedDate`. This avoids touching ~20 call sites; consumers that generate schedules must skip `isExpected` children (Task 7).

## Review Focus

1. Pregnant mother who already has children → dashboard shows both pregnancy block and "Mes enfants" (Task 7 check).
2. Legacy child doc with `gender: null` or garbage → parses as `unknown`, neutral colour, no crash (Task 2 test `legacy gender falls back to unknown`).
3. Legacy capsule without `childIds` still appears in its child's folder before and after migration (Task 5 test `legacy childId backfills childIds`, Task 6 query fallback).
4. Migration runs twice (app restarted mid-way / two devices) → no duplicate pregnancy or expected child (Task 4: `schemaVersion` written in the same batch; test of `needsMigration`).
5. LMP in the future or > 44 weeks ago → no negative week / absurd countdown (Task 1 tests `clamps future lmp` and `overdue`).

---

### Task 0: Branch + tickets

**Files:**
- Create: `docs/updates/issues/LM2-140.md`, `LM2-141.md`, `LM2-143.md`, `LM2-146.md` (copy the format of `docs/updates/issues/LM2-124.md`; content from spec §6 rows + §1/§2/§3)
- Modify: `docs/updates/TASKS.md` (new section "Addendum Parcours Maman", 4 rows status `🔄`)

- [ ] **Step 1:** `git checkout -b feat/mother-journey-foundation`
- [ ] **Step 2:** Write the 4 issue files (Statut `🔄 En cours`) and TASKS.md rows.
- [ ] **Step 3:** Commit `docs(backlog): add LM2-140/141/143/146 mother journey tickets`.

---

### Task 1: Pregnancy model + maths (LM2-140)

**Files:**
- Create: `lib/features/profile/models/pregnancy.dart`
- Test: `test/pregnancy_test.dart`

**Interfaces:**
- Produces:
  - `enum PregnancyStatus { active, delivered, ended }`
  - `enum EddSource { lmp, ultrasound, doctor }`
  - `class Pregnancy { String id; DateTime lmpDate; DateTime eddDate; EddSource eddSource; int babyCount; List<String> childIds; PregnancyStatus status; DateTime? endedAt; DateTime createdAt; DateTime updatedAt; }` with `factory Pregnancy.fromFirestore(Map<String,dynamic> data, String id)`, `Map<String,dynamic> toFirestore()`, `copyWith`.
  - `static DateTime Pregnancy.eddFromLmp(DateTime lmp)` → `lmp + 280 days` (date only).
  - `int gestationalWeek(DateTime now)` → completed weeks since LMP, clamped to `0..42`.
  - `int gestationalDay(DateTime now)` → day within week `0..6`.
  - `int daysUntilDue(DateTime now)` → `eddDate - today` in days, can be negative (overdue).
  - `int trimester(DateTime now)` → 1 (weeks 0–13), 2 (14–27), 3 (28+).
  - `bool get isActive`.

- [ ] **Step 1: Write the failing tests** in `test/pregnancy_test.dart`:

```dart
test('eddFromLmp adds 280 days', () {
  expect(Pregnancy.eddFromLmp(DateTime(2026, 1, 1)), DateTime(2026, 10, 8));
});
test('gestational week and day', () {
  final p = _p(lmp: DateTime(2026, 1, 1));
  expect(p.gestationalWeek(DateTime(2026, 3, 5)), 9); // 63 days
  expect(p.gestationalDay(DateTime(2026, 3, 5)), 0);
  expect(p.trimester(DateTime(2026, 3, 5)), 1);
});
test('clamps future lmp to week 0', () {
  expect(_p(lmp: DateTime(2026, 5, 1)).gestationalWeek(DateTime(2026, 4, 1)), 0);
});
test('overdue gives negative daysUntilDue and week capped at 42', () {
  final p = _p(lmp: DateTime(2025, 1, 1));
  expect(p.daysUntilDue(DateTime(2026, 1, 1)) < 0, isTrue);
  expect(p.gestationalWeek(DateTime(2026, 1, 1)), 42);
});
test('firestore round trip keeps fields', () { /* toFirestore → fromFirestore equals on lmp, edd, babyCount, childIds, status */ });
```
(`_p` = helper building a `Pregnancy` with `eddDate: Pregnancy.eddFromLmp(lmp)`, `babyCount: 1`, `status: active`.) Note: `fromFirestore` must accept `Timestamp` values; the round-trip test converts via `toFirestore()` so it gets `Timestamp`s.

- [ ] **Step 2:** `flutter test test/pregnancy_test.dart` → FAIL (file missing).
- [ ] **Step 3:** Implement `pregnancy.dart`. Date arithmetic on date-only values (`DateTime(y,m,d)`) to avoid DST/hour drift. Unknown enum strings fall back to `active` / `lmp`.
- [ ] **Step 4:** `flutter test test/pregnancy_test.dart` → PASS.
- [ ] **Step 5:** `flutter analyze lib/features/profile/models/pregnancy.dart test/pregnancy_test.dart` → No issues. Commit `feat(profile): add Pregnancy model with gestational maths`.

---

### Task 2: Expected child + unknown gender (LM2-143)

**Files:**
- Modify: `lib/features/profile/models/profile_models.dart` (`ChildGender`, `Child`)
- Modify: `lib/core/extensions/profile_l10n_extension.dart` (localized gender + expected age)
- Modify: `lib/l10n/app_fr.arb`, `app_ar.arb`, `app_en.arb`
- Test: `test/child_model_test.dart`

**Interfaces:**
- Produces:
  - `enum ChildGender { boy, girl, unknown }`
  - `enum ChildLifecycle { expected, born }`
  - `Child` gains `final ChildLifecycle lifecycle` (default `born`), `final DateTime? expectedDate`, `final String? pregnancyId`, `final bool archived` (default false; set when a pregnancy ends and memories are kept); getters `bool get isExpected`, `bool get isBorn`.
  - `Child.fromFirestore`: if `birthDate` null and `expectedDate` present ⇒ `birthDate = expectedDate`; if both null ⇒ `DateTime.now()` (defensive). Gender fallback `unknown`.
  - `Child.toFirestore`: writes `lifecycle`, `expectedDate`, `pregnancyId`; writes `birthDate: null` when `isExpected`.
  - `themeColor`: custom hex first; else `unknown` ⇒ `AppColors.goldenrod`; boy/girl unchanged.
  - `ageString` when expected: `'Naissance prévue dans N semaines'` (keep French getter for legacy callers; localized version below).
  - Extension (in `profile_l10n_extension.dart`): `String localizedGenderLabel(AppLocalizations l10n)`; `localizedAgeString` returns `l10n.childExpectedInWeeks(n)` when expected (n = ceil(days/7), min 0) or `l10n.childDueToday` when n == 0.
  - New `.arb` keys: `genderUnknown` (fr "Surprise", ar "مفاجأة", en "Surprise"), `childExpectedInWeeks` (plural-free `{weeks}`; fr "Naissance prévue dans {weeks} sem.", ar "الولادة متوقعة بعد {weeks} أسابيع", en "Due in {weeks} weeks"), `childDueToday` (fr "Naissance prévue aujourd'hui", ar "الولادة متوقعة اليوم", en "Due today"), `childExpectedDefaultName` (fr "Bébé", ar "بيبي", en "Baby").

- [ ] **Step 1: Failing tests** (`test/child_model_test.dart`), building maps with `Timestamp.fromDate`:

```dart
test('legacy gender falls back to unknown', () {
  final c = Child.fromFirestore({'name': 'A', 'birthDate': ts(2024,1,1), 'gender': null}, 'id');
  expect(c.gender, ChildGender.unknown);
  expect(c.lifecycle, ChildLifecycle.born);
});
test('legacy boy/girl still parse', () { /* 'girl' -> girl */ });
test('expected child uses expectedDate as birthDate and writes null birthDate', () {
  final c = Child.fromFirestore({'name': 'Bébé', 'birthDate': null, 'expectedDate': ts(2027,1,10),
      'lifecycle': 'expected', 'gender': 'unknown', 'pregnancyId': 'p1'}, 'id');
  expect(c.isExpected, isTrue);
  expect(c.birthDate, DateTime(2027,1,10));
  expect(c.toFirestore()['birthDate'], isNull);
  expect(c.toFirestore()['lifecycle'], 'expected');
});
test('unknown gender gets neutral colour', () {
  expect(_child(gender: ChildGender.unknown).themeColor, AppColors.goldenrod);
});
```

- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement model + extension + arb keys; `flutter gen-l10n`. Fix every exhaustive `switch` on `ChildGender` that `flutter analyze lib` reports (add the `unknown` branch using neutral colour / `l10n.genderUnknown`). `copyWith` gains the 3 new fields.
- [ ] **Step 4:** `flutter test test/child_model_test.dart` → PASS; `flutter analyze lib` → no new issues.
- [ ] **Step 5:** Commit `feat(profile): support expected children with unknown gender`.

---

### Task 3: MotherStage derivation (LM2-140)

**Files:**
- Create: `lib/features/profile/models/mother_stage.dart`
- Modify: `lib/features/profile/models/profile_models.dart` (`UserProfile`: `bool tryingToConceive` default false, `int schemaVersion` default 1; parse/write/copyWith)
- Test: `test/mother_stage_test.dart`

**Interfaces:**
- Produces:
  - `enum MotherStage { exploring, hope, pregnantFirst, pregnantWithChildren, mom, momHope }` with getters `bool isPregnant`, `bool hasChildren`, `bool tracksCycle` (`hope`, `momHope`), and `UserStatus get legacyStatus` (`pregnant*` ⇒ `pregnant`; `hope`/`exploring` ⇒ `hope`; `mom`/`momHope` ⇒ `mom`).
  - `MotherStage deriveMotherStage({required int bornChildren, required bool hasActivePregnancy, required bool tryingToConceive})`.
  - `const int kCurrentProfileSchemaVersion = 2;`

- [ ] **Step 1: Failing tests** — the 6 rows of spec §1.1, one `test` each, e.g.:

```dart
test('D: pregnant with children', () {
  final s = deriveMotherStage(bornChildren: 2, hasActivePregnancy: true, tryingToConceive: true);
  expect(s, MotherStage.pregnantWithChildren);
  expect(s.isPregnant, isTrue);
  expect(s.hasChildren, isTrue);
  expect(s.legacyStatus, UserStatus.pregnant);
});
test('A: exploring', () => expect(deriveMotherStage(bornChildren: 0, hasActivePregnancy: false, tryingToConceive: false), MotherStage.exploring));
// B hope, C pregnantFirst, E mom, F momHope likewise
test('UserProfile reads tryingToConceive and schemaVersion defaults', () { /* missing fields → false, 1 */ });
```

- [ ] **Step 2:** Run → FAIL. **Step 3:** Implement. **Step 4:** Run → PASS, analyze clean.
- [ ] **Step 5:** Commit `feat(profile): derive MotherStage from children, pregnancy and TTC`.

---

### Task 4: Pregnancy persistence, migration, providers (LM2-140 / LM2-143)

**Files:**
- Modify: `lib/features/profile/services/profile_service.dart`
- Modify: `lib/features/profile/providers/profile_providers.dart`
- Create: `lib/features/profile/services/profile_migration.dart` (pure `needsMigration` + plan builder)
- Modify: `firestore.rules` (`match /pregnancies/{pregnancyId}` under `/users/{userId}`, same owner rule as `children`)
- Test: `test/profile_migration_test.dart`

**Interfaces:**
- Consumes: `Pregnancy` (Task 1), `Child` expected fields (Task 2), `deriveMotherStage`, `kCurrentProfileSchemaVersion` (Task 3).
- Produces (`ProfileService`):
  - `Stream<List<Pregnancy>> watchPregnancies()` (ordered `createdAt desc`)
  - `Future<String> declarePregnancy({required DateTime lmpDate, DateTime? eddDate, EddSource eddSource = EddSource.lmp, int babyCount = 1, required String placeholderName})` — one `WriteBatch`: pregnancy doc + `babyCount` expected children (names `placeholderName` or `'$placeholderName 1'`, `'… 2'` when twins; gender unknown; `expectedDate` = EDD) + user `{status: 'pregnant', tryingToConceive: false, lastPregnancyDate: lmp}`. Returns pregnancy id.
  - `Future<void> markChildBorn({required String childId, required DateTime birthDate, required String name, required ChildGender gender})` — sets child `born`; if every child of that pregnancy is born ⇒ pregnancy `delivered`; recompute + write derived `status`.
  - `Future<void> endPregnancy(String pregnancyId, {required bool keepMemories})` — pregnancy `ended` + `endedAt`; expected children: if `keepMemories` keep docs but set `lifecycle: 'expected'` untouched and add `archived: true`, else delete them (capsule deletion is Plan 2); recompute `status`.
  - `Future<void> setTryingToConceive(bool value)`.
  - `Future<void> runProfileMigrationIfNeeded()` — reads profile; if `needsMigration(profile)` applies `buildMigration` in one batch **including** `schemaVersion: 2` so a re-run is a no-op.
- Produces (`profile_migration.dart`, pure):
  - `bool needsMigration(UserProfile p)` → `p.schemaVersion < kCurrentProfileSchemaVersion`
  - `ProfileMigrationPlan buildProfileMigration(UserProfile p)` → `{bool createPregnancy; DateTime? lmp; bool setTryingToConceive}`: `pregnant` + `lastPregnancyDate != null` ⇒ createPregnancy; `hope` ⇒ setTryingToConceive.
- Produces (providers, `profile_providers.dart`):
  - `pregnanciesProvider : StreamProvider<List<Pregnancy>>`
  - `activePregnancyProvider : Provider<Pregnancy?>`
  - `bornChildrenProvider`, `expectedChildrenProvider : Provider<List<Child>>` (children not `archived`)
  - `motherStageProvider : Provider<MotherStage>` (defaults to `mom` while loading — matches today's default)
  - `isPregnantProvider`, `hasBornChildrenProvider : Provider<bool>`
  - `selectedChildProvider` keeps working; it must prefer born children when nothing is selected.

- [ ] **Step 1: Failing tests** for the pure part:

```dart
test('pregnant legacy user creates one pregnancy', () {
  final plan = buildProfileMigration(_profile(status: UserStatus.pregnant, lmp: DateTime(2026, 6, 1)));
  expect(plan.createPregnancy, isTrue);
  expect(plan.lmp, DateTime(2026, 6, 1));
});
test('hope legacy user sets TTC', () => expect(buildProfileMigration(_profile(status: UserStatus.hope)).setTryingToConceive, isTrue));
test('migrated profile is not migrated again', () => expect(needsMigration(_profile(schemaVersion: 2)), isFalse));
test('pregnant without lmp does not create pregnancy', () { ... createPregnancy false ... });
```

- [ ] **Step 2:** Run → FAIL. **Step 3:** Implement pure file, service methods, providers, rules.
- [ ] **Step 4:** `flutter test` → PASS; `flutter analyze lib` clean.
- [ ] **Step 5:** Commit `feat(profile): persist pregnancies, expected children and migrate legacy status`.

---

### Task 5: Capsule subjects model (LM2-146)

**Files:**
- Modify: `lib/features/capsules/models/capsule.dart`
- Test: `test/capsule_subjects_test.dart`

**Interfaces:**
- Produces:
  - `enum CapsuleSpace { child, mother, family }`
  - `CapsuleSpace deriveCapsuleSpace({required List<String> childIds, required bool withMother})` — `childIds.length >= 2` ⇒ family; `withMother && childIds.isNotEmpty` ⇒ family; `withMother` ⇒ mother; else child.
  - `Capsule` gains `List<String> childIds`, `bool withMother` (default false), `String? pregnancyId`, `int? pregnancyWeek`, getter `CapsuleSpace get space`. `childId` becomes `String` still (= `childIds.firstOrNull ?? ''`) for backward compat.
  - `fromFirestore`: `childIds` missing ⇒ `[childId]` when non-empty else `[]`.
  - `toFirestore`: writes `childIds`, `withMother`, `space` (name), `pregnancyId`, `pregnancyWeek`, and `childId` = first or `''`.

  > Spec table says "Mother with 2 children ⇒ family" and "Bump photo week 24 (expected baby + mother) ⇒ mother journey **and** baby folder". With the rule above that bump photo derives `family`. Override: when `pregnancyId != null && childIds.length == 1 && withMother` ⇒ `mother`. Encode this as the first rule.

- [ ] **Step 1: Failing tests:**

```dart
test('legacy childId backfills childIds', () { expect(fromMap({'childId': 'a'}).childIds, ['a']); });
test('empty legacy childId gives empty list', () { expect(fromMap({'childId': ''}).childIds, isEmpty); });
test('mother alone is mother space', () => expect(deriveCapsuleSpace(childIds: [], withMother: true), CapsuleSpace.mother));
test('siblings are family', () => expect(deriveCapsuleSpace(childIds: ['a','b'], withMother: false), CapsuleSpace.family));
test('bump photo stays in mother space', () { /* Capsule with pregnancyId 'p', childIds ['baby'], withMother true → space mother */ });
test('toFirestore writes space and first childId', () { ... });
```

- [ ] **Step 2:** FAIL. **Step 3:** Implement (`deriveCapsuleSpace` gains optional `String? pregnancyId`). **Step 4:** PASS + analyze. **Step 5:** Commit `feat(capsules): add multi-subject capsules (children, mother, family)`.

---

### Task 6: Capsule queries, creation, migration, indexes (LM2-146)

**Files:**
- Modify: `lib/features/capsules/services/capsule_service.dart`
- Modify: `lib/features/capsules/providers/capsule_providers.dart`
- Modify: `firestore.indexes.json`

**Interfaces:**
- Consumes: Task 5 fields.
- Produces (`CapsuleService`):
  - `watchCapsulesForChild(String childId)` → `where('childIds', arrayContains: childId)`, ordered like today.
  - `Stream<List<Capsule>> watchMotherCapsules()` → `where('withMother', isEqualTo: true)`.
  - `Stream<List<Capsule>> watchFamilyCapsules()` → `where('space', isEqualTo: 'family')`.
  - `createCapsule(...)`: `childId` param becomes optional `String? childId`; new `List<String>? childIds`, `bool withMother = false`, `String? pregnancyId`, `int? pregnancyWeek`. Effective `childIds = childIds ?? (childId != null ? [childId] : [])`. Throw `ArgumentError` if effective `childIds` empty and `!withMother`.
  - `watchFilteredCapsules` in-memory child filter uses `c.childIds.contains(childId)`.
  - `Future<int> migrateCapsuleSubjects()` — for docs missing `childIds`, batch-update (≤ 450 writes per batch) `childIds`, `withMother: false`, `space: 'child'`; returns count. Guarded by its own user-doc flag `capsuleSchemaVersion: 2` (written after success); called from home startup in Task 7.
- Produces (providers): `motherCapsulesProvider`, `familyCapsulesProvider : StreamProvider<List<Capsule>>`.
- Indexes: composite on `capsules` (`childIds` ARRAY_CONTAINS + `createdAt` DESC), (`withMother` ASC + `createdAt` DESC), (`space` ASC + `createdAt` DESC). Match the order field the existing `watchCapsulesForChild` uses.

- [ ] **Step 1:** Implement; keep every existing caller of `createCapsule(childId: …)` compiling unchanged.
- [ ] **Step 2:** `flutter analyze lib` → no new issues; `flutter test` → PASS.
- [ ] **Step 3:** Commit `feat(capsules): query capsules by subject and migrate legacy capsules`.

---

### Task 7: Consumers use stage capabilities (LM2-141)

**Files (modify):**
- `lib/features/home/tabs/dashboard_tab.dart` — "Mes enfants" shown when `hasBornChildrenProvider`.
- `lib/features/home/widgets/home_hero_card.dart`, `weekly_day_strip.dart`, `home_bento_grid.dart`, `personal_header.dart`, `mother_health_card.dart`, `cycle_tracking_section.dart`, `home_providers.dart`, `lib/features/home/data/home_tips_data.dart` — replace `status == UserStatus.pregnant` with `isPregnantProvider` / `activePregnancyProvider` (week + EDD from `Pregnancy`, fallback to `profile.lastPregnancyDate` while loading); `status == hope` with `motherStage.tracksCycle`; `status == mom` with `hasBornChildren`. Tips: map stage → existing pools (`pregnant*`→pregnant, `exploring|hope`→hope, `mom|momHope`→mom).
- `lib/features/profile/edit_mother_profile_screen.dart` — when the user picks "Enceinte" and saves, call `declarePregnancy` (if no active pregnancy) instead of only `updateStatus`; "Espoir" ⇒ `setTryingToConceive(true)`; "Maman" ⇒ `setTryingToConceive(false)`. Keep the existing UI.
- Skip expected children in schedule generators: `lib/features/vaccines/providers/vaccine_providers.dart`, `lib/features/home/tabs/vaccinations_tab.dart`, `lib/features/timeline/services/timeline_service.dart`, `weekly_day_strip.dart:341`, `home_providers.dart:42` (iterate `bornChildrenProvider` or `if (child.isExpected) continue`). Expected child selected in Vaccinations/Timeline tabs ⇒ empty state text `l10n.scheduleStartsAtBirth` (new key: fr "Le calendrier démarre à la naissance", ar "يبدأ الجدول عند الولادة", en "The schedule starts at birth").
- `lib/features/home/home_screen.dart` (or the first authenticated screen's `initState`) — call `profileService.runProfileMigrationIfNeeded()` then `capsuleService.migrateCapsuleSubjects()` once, errors logged to Crashlytics, never blocking UI.

- [ ] **Step 1:** Implement; `grep -rn "UserStatus\." lib --include=*.dart` should only remain in `profile_models.dart`, `mother_stage.dart`, `profile_l10n_extension.dart`, `edit_mother_profile_screen.dart` (status picker UI) and `profile_service.dart`.
- [ ] **Step 2:** `flutter gen-l10n`; `flutter analyze` → no new issues vs. `main`; `flutter test` → PASS.
- [ ] **Step 3:** Manual check list (emulator, `flutter run`): (a) mom with 1 child declares pregnancy in profile → home shows pregnancy week **and** Mes enfants; (b) Vaccinations tab with the expected baby selected shows the "starts at birth" state; (c) existing capsules still visible in child folder.
- [ ] **Step 4:** Commit `feat(home): drive dashboard from mother stage (pregnant with children)`.

---

### Task 8: Close tickets (CLAUDE.md workflow)

- [ ] For each of LM2-140, 141, 143, 146: issue `**Statut**` → `✅ Terminé`; TASKS.md row ✅ and counters; report `docs/reports/rapport_client_2026-10-21_LM2-XXX.md` in the exact CLAUDE.md structure; link added to the `> Rapports :` line.
- [ ] Commit `docs(reports): LM2-140/141/143/146 client reports`.
