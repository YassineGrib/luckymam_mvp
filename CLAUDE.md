# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Luckymam** is a Flutter mobile app targeting Algerian mothers for child health tracking, memory-keeping, and parenting guidance. It targets Android (primary) with Firebase as the backend. The repository also contains two companion web projects: a React/Vite landing page (`luckymam_web/`) and a static HTML landing page (`landing_page/`).

## Commands

### Flutter App (root)

```bash
flutter pub get                         # Install dependencies
flutter run                             # Run on connected device/emulator
flutter build apk --release             # Build release APK
flutter build apk --release --split-per-abi  # Split APKs by ABI (preferred for distribution)
flutter analyze                         # Static analysis
flutter test                            # Run all tests
flutter test test/widget_test.dart      # Run a single test file
flutter gen-l10n                        # Regenerate localization files from .arb
dart run build_runner build --delete-conflicting-outputs  # Regenerate Riverpod providers
```

### Web App (`luckymam_web/`)

```bash
npm install       # Install dependencies
npm run dev       # Dev server
npm run build     # Production build (runs tsc + vite build)
npm run lint      # ESLint
```

### Firebase

```bash
firebase deploy --only firestore:rules   # Deploy Firestore rules
firebase deploy --only storage           # Deploy Storage rules
```

## Architecture

### Flutter App Structure

```
lib/
  main.dart               # App entry point — Firebase init, notifications, ProviderScope
  core/
    router/app_router.dart    # GoRouter config, all named routes, page transitions
    services/                 # Stateless service classes (no Riverpod)
    providers/                # App-wide Riverpod providers (theme, locale)
    theme/                    # AppTheme, AppColors, AppSpacing
  features/                   # Feature slices (see below)
  shared/widgets/             # Reusable UI components used across features
  l10n/                       # Generated localization files (do not edit manually)
```

### Feature Slice Pattern

Each feature under `lib/features/` follows a consistent layout:

```
features/<feature>/
  models/          # Plain Dart data classes / enums
  services/        # Direct Firestore / Firebase Storage operations
  providers/       # Riverpod providers wrapping services
  screens/         # Full-page widgets (routed via GoRouter)
  widgets/         # Feature-specific sub-widgets
```

### State Management

Riverpod is used throughout. Services are instantiated via `Provider<Service>` and consumed by `StreamProvider` / `FutureProvider` / `StateNotifierProvider`. Code-generated providers (`@riverpod` annotation) require running `build_runner` after changes.

### Navigation

GoRouter (`lib/core/router/app_router.dart`). All routes are named. Navigation flow: `splash → onboarding → login/signup → home`. The `HomeScreen` is a tab host with `IndexedStack` + `AppBottomNav` (5 tabs: Dashboard, Timeline, Capsules, Vaccinations, Profile). Screens not in the tab bar (reels, sponsors, etc.) are top-level GoRouter routes.

### Firebase / Firestore Data Model

All user data lives under `/users/{uid}/`:
- `children/{childId}` — child profiles
  - `vaccinations/{id}`, `growth/{id}`, `appointments/{id}` — child health subcollections
- `capsules/{capsuleId}` — memory capsules (photos, audio, text)
- `milestoneProgress/{id}` — timeline milestone completion state

Top-level collections: `consent_logs`, `analytics_logs` (append-only), `album_claims` (create/read only — no update/delete).

### Localization

Three locales: French (`fr`, default), Arabic (`ar`), English (`en`). Source `.arb` files are in `lib/l10n/`. Generated Dart files are committed alongside them. Run `flutter gen-l10n` after editing `.arb` files. RTL layout is automatically handled for Arabic via Flutter's `Directionality`.

### Subscription Tiers

Defined in `lib/features/subscription/models/subscription_models.dart`. Three tiers: `free` (25 capsules, 1 child), `premium` (2 490 DZD/year, unlimited), `vip` (9 890 DZD/year, includes a printed album perk). Payment methods: CIB and Edahabia (Algérie Poste). The subscription tier gates capsule creation — checked via `capsuleCountProvider` and quota constants in `lib/features/capsules/providers/capsule_providers.dart`.

### Compliance

Algerian Law 18-07 (data privacy) consent is collected at first launch via `Law1807ConsentScreen` and logged as a write-once Firestore document in `consent_logs`. The `ComplianceService` handles this flow.

## Key Conventions

- **French** is the primary UI language; UI labels are written in French even in Dart source (e.g. `'Accueil'`, `'Gratuit'`).
- Services are plain classes instantiated inside Riverpod `Provider`s — they are not singletons accessed globally.
- Prices are in **DZD** (Algerian Dinar).
- The app is Android-only for now; iOS-specific code is absent.

## Workflow — Backlog Tickets

Every ticket in `docs/updates/issues/` follows this sequence. Do **not** skip any step.

### 1. Implement
- Read the issue file before touching any code.
- Run `flutter analyze` on every modified file before declaring done. Zero new issues required.

### 2. Update TASKS.md
- Change ticket status to `✅ Terminé` in `docs/updates/TASKS.md`.
- Increment the "✅ Terminé" counter and decrement "⬜ À faire".

### 3. Create client report — MANDATORY
After **every** completed ticket, create a report file at:

```
docs/reports/rapport_client_YYYY-MM-DD_LM2-XXX.md
```

Use today's date (`currentDate` from context). The report must follow this exact structure:

```markdown
# Rapport — LM2-XXX : <Titre du ticket>

**Date :** YYYY-MM-DD
**Ticket :** LM2-XXX
**Priorité :** <Must/Should/Could> Have · X SP
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. <Sous-titre>
<Description détaillée de chaque changement>

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `path/to/file.dart` | Description courte |

---

## Résultat

| Critère | Statut |
|---------|--------|
| <Critère d'acceptation> | ✅ |
| `flutter analyze` clean | ✅ |
```

### 4. Add report link to TASKS.md
Add the new report to the `> Rapports :` line at the top of `docs/updates/TASKS.md`.

### 5. Update issue file
Change the `**Statut**` field in `docs/updates/issues/LM2-XXX.md` from `⬜ À faire` to `✅ Terminé`.
