# Spec — Mother journey, mother capsule, expected baby & AI assistant

**Date:** 2026-10-21
**Status:** Proposal, for validation before tickets are opened
**Scope:** Flutter app (`lib/`), Firestore model, Cloud Functions (`functions/`), `CHARACTER_AI/` kit

---

## 0. What the app does today (findings)

These are the parts of the current code that the requests below depend on.

| Area | Current behaviour | Problem |
|---|---|---|
| Mother status | `UserProfile.status` is a single enum `UserStatus { pregnant, mom, hope }` (`lib/features/profile/models/profile_models.dart`). Pregnancy is one field, `lastPregnancyDate` (the LMP). | Statuses exclude each other. A mother **with children who is pregnant again** has to pick one. If she picks `pregnant`, the dashboard hides "Mes enfants" (`dashboard_tab.dart:88` shows it only when `status == mom`). If she picks `mom`, she loses the DPA/week tracking. |
| Status consumers | About 10 widgets branch on `status`: `home_hero_card`, `weekly_day_strip`, `home_bento_grid`, `personal_header`, `cycle_tracking_section`, `mother_health_card`, `home_tips_data`, `dashboard_tab`, `edit_mother_profile_screen`. | Each widget makes its own either/or decision. There is no shared "life stage" concept. |
| Child | `Child.birthDate` and `Child.gender` (`boy`/`girl`) are **required**. A missing gender falls back to `boy` when parsed. `themeColor` is blue or red by gender. | A folder for a baby who isn't born yet, or whose sex is unknown, can't be represented. Making one forces fake data (gender "boy", birth date "today"). |
| Capsule | `Capsule.childId` is **required**, so every memory belongs to exactly one child. `create_capsule_screen` needs at least one child. | There's nowhere to put memories about the mother herself or family photos. A `hope` user with no children can't create a capsule at all. |
| Appointments | `/users/{uid}/children/{childId}/appointments`, children only. | The mother's own prenatal and postnatal visits can't be tracked. |
| Marketplace product | Has `category` (`puericulture, alimentation, hygiene, eveil, maman`), `highlights` and `featured`. | No **age range**, **skills/benefits** or **pregnancy stage** fields, so an AI has nothing structured to match a product to a child. |
| Subscription | `childLimit: 1` on free, but nothing outside the model reads `childLimit`. | The limit isn't enforced. It needs a decision (see §2.6). |
| Location | `UserProfile.wilaya` exists. | Weather can use it without asking for GPS permission. |
| Backend | `functions/` (Node, firebase-functions v2) already hosts Chargily payment and admin SSR. | This is the right place for an AI proxy. No LLM or weather dependency exists yet. |

---

## 1. Mother situations: proposed model

### 1.1 Principle: store facts and derive the situation

Don't add more values to `UserStatus`. Store three **independent facts** and compute the situation from them:

| Fact | Source | Example |
|---|---|---|
| Born children | `children` where `lifecycle == born` | 0, 1, 3… |
| Active pregnancy | `/users/{uid}/pregnancies` where `status == active` | LMP, DPA, number of babies |
| Trying to conceive | `UserProfile.tryingToConceive: bool` | true / false |

The derived **`MotherStage`** (computed client-side, never stored as the source of truth):

| # | Situation | Born children | Active pregnancy | TTC | `MotherStage` |
|---|---|---|---|---|---|
| A | Newly married, not trying yet / exploring | 0 | no | false | `exploring` |
| B | Trying to conceive (current HOPE) | 0 | no | true | `hope` |
| C | First pregnancy | 0 | yes | n/a | `pregnantFirst` |
| D | Pregnant again, with children | ≥1 | yes | n/a | `pregnantWithChildren` |
| E | Mother | ≥1 | no | false | `mom` |
| F | Mother trying for another child | ≥1 | no | true | `momHope` |

> Situation A was missing entirely. Today a newlywed has to pick "HOPE", which isn't always accurate and drives fertility-tracking content she may not want.

```dart
// lib/features/profile/models/mother_stage.dart (new)
enum MotherStage { exploring, hope, pregnantFirst, pregnantWithChildren, mom, momHope }

// lib/features/profile/providers/profile_providers.dart (new)
final motherStageProvider = Provider<MotherStage>((ref) { ... });
// Plus convenience flags consumed by widgets:
//   isPregnantProvider, hasBornChildrenProvider, activePregnancyProvider
```

Widgets then ask **capability questions** ("is she pregnant?", "does she have children?") instead of switching on one status. This fixes situation D for free: the pregnancy panel shows when `isPregnant` and "Mes enfants" shows when `hasBornChildren`, and both can be true at once.

### 1.2 Firestore changes

```
/users/{uid}
  status: 'pregnant' | 'mom' | 'hope'        # KEPT for backward compat, written as a derived value
  tryingToConceive: bool                      # NEW
  lastPregnancyDate                           # DEPRECATED → migrated to pregnancies/

/users/{uid}/pregnancies/{pregnancyId}        # NEW
  lmpDate: Timestamp                          # DDR
  eddDate: Timestamp                          # DPA = LMP + 280 j (or corrected by doctor/echo)
  eddSource: 'lmp' | 'ultrasound' | 'doctor'
  babyCount: 1 | 2 | 3                        # twins / triplets
  childIds: [childId, ...]                    # the "expected" child docs (see §3)
  status: 'active' | 'delivered' | 'ended'
  endedAt: Timestamp?
  createdAt, updatedAt
```

Why a sub-collection and not fields: a mother has several pregnancies over the years. Keeping each one preserves the history (the mother's journey, §2) and links each pregnancy to the baby it produced.

### 1.3 Transitions (user flows)

| From → To | Trigger in UI | What the app does |
|---|---|---|
| any → pregnant | "Je suis enceinte 🎉" (profile, cycle card, AI chat) | Asks for LMP (or DPA if known) and number of babies. Creates the `pregnancy` and **N expected child folders** (§3). Stops the fertility/cycle notifications. If she already has children they stay visible, which is situation D. |
| pregnant → mom | "Bébé est né(e) 👶" card shown from DPA − 3 weeks | Birth wizard: date, first name, sex, weight/height at birth. Converts the expected child to `born`. The pregnancy becomes `delivered`. The vaccine calendar starts from the real birth date. Offers a "Naissance" capsule. |
| pregnant → ended (loss) | Discreet "Ma grossesse s'est arrêtée" in the pregnancy settings, never promoted | **Must be handled with care.** Cancel every pregnancy notification, AI recommendation and marketplace push immediately. Ask once whether to **keep** the memories (archived in the mother journey) or **delete** them. Never show "J-XX" again. The AI gets a `recentLoss` flag that suppresses commercial and pregnancy content for a configurable period (default 90 days). |
| exploring ↔ hope | Toggle "Nous essayons d'avoir un enfant" | Turns cycle/ovulation tracking and HOPE tips on or off. |
| mom → momHope | Same toggle, with children present | Cycle tracking on, child content stays. |

### 1.4 Onboarding / sign-up

Replace the single-choice status question with two short questions:

1. **"Avez-vous déjà des enfants ?"** No / Yes → quick add (first name + birth date; sex optional at this step)
2. **"Êtes-vous enceinte actuellement ?"** Yes → LMP or DPA + number of babies · No → "Souhaitez-vous suivre votre cycle pour concevoir ?" (sets `tryingToConceive`)

This covers all six situations in at most three taps and asks nothing irrelevant.

### 1.5 What each stage sees (summary)

| Block | exploring | hope | pregnantFirst | pregnantWithChildren | mom | momHope |
|---|---|---|---|---|---|---|
| Pregnancy panel (week, DPA, J-XX) | – | – | ✅ | ✅ | – | – |
| Cycle / ovulation | optional | ✅ | – | – | optional | ✅ |
| Mes enfants | – | – | – | ✅ | ✅ | ✅ |
| Expected baby card | – | – | ✅ | ✅ | – | – |
| Vaccines / milestones tabs | empty state + CTA | empty state | expected baby: "dès la naissance" | ✅ born children | ✅ | ✅ |
| Mother journey capsule | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daily tips pool | couple / health | fertility | pregnancy week | pregnancy + child age | child age | child age + fertility |

### 1.6 Migration (one-off, idempotent)

Run it in the app on first launch after the update (`ProfileService.migrateToPregnancyModel()`), guarded by `schemaVersion` on the user doc:

- `status == pregnant` and `lastPregnancyDate != null`: create `pregnancies/{auto}` (active, LMP = `lastPregnancyDate`, `babyCount: 1`) plus one expected child (§3).
- `status == hope`: `tryingToConceive = true`.
- `status == mom`: nothing to do.
- Keep writing `status` (derived) so the admin panel and older app versions still work.

---

## 2. Mother capsule ("Mon parcours de maman")

### 2.1 Concept

A memory space centred on the mother, alongside the per-child folders. It holds:

- **Pregnancy journal**: weekly bump photos, ultrasounds, prenatal visit notes, cravings, "first kick" audio.
- **My journey as a mother**: postpartum, return to work, personal milestones, letters to herself.
- **Family**: group photos, mother + children, siblings together, celebrations (Aïd, birthdays).
- **Me time**: things that are only about her.

### 2.2 Data model change

Replace "one capsule = one child" with **subjects**:

```
/users/{uid}/capsules/{capsuleId}
  childId: String?        # KEPT (nullable now); = childIds.first for backward compat
  childIds: [String]      # NEW, children who appear in / own this memory (0..n)
  withMother: bool        # NEW, the mother is a subject of this memory
  pregnancyId: String?    # NEW, links pregnancy-journal entries to a pregnancy
  pregnancyWeek: int?     # NEW, auto-filled from LMP at capturedAt
  space: 'child' | 'mother' | 'family'   # NEW, derived on write, used for filtering/UI
```

| Memory | `childIds` | `withMother` | `space` | Appears in |
|---|---|---|---|---|
| Child's first steps | [amine] | false | child | Amine's folder |
| Mother alone, postpartum | [] | true | mother | Mother journey |
| Bump photo, week 24 | [baby2] | true | mother | Mother journey **and** expected baby's folder |
| Mother with 2 children | [amine, sara] | true | family | Family, Amine's folder, Sara's folder |
| Siblings together | [amine, sara] | false | family | Family, both folders |

Queries:
- Child folder: `where('childIds', arrayContains: childId)` (replaces `childId ==` in `CapsuleService.watchCapsulesForChild`).
- Mother journey: `where('withMother', isEqualTo: true)`.
- Family: `where('space', isEqualTo: 'family')`.
- Add the matching composite indexes in `firestore.indexes.json` (with `capturedAt desc`).

Migration: backfill `childIds = [childId]`, `withMother = false`, `space = 'child'` for existing capsules. Run it once per user in the client or as an admin script. Firestore rules must accept the new fields and still validate ownership.

### 2.3 UI

- **Capsules tab**: add a subject selector at the top as a horizontal chip row in the existing Squircle Bento style: `Moi` (mother avatar) · `Famille` · one chip per child · the expected baby with a 🤍 neutral chip.
- **Create capsule**: replace the single child picker with **"Qui est sur ce souvenir ?"**, a multi-select of avatars (Moi + children). Default: the chip the user came from.
- **Mother journey screen**: a vertical timeline grouped by life chapter (each pregnancy, each child's arrival, years). Pregnancy entries show a "Semaine 24" badge.
- **Pregnancy bump timeline** (bonus): auto-builds a grid of the weekly bump photos, a natural candidate for a printed album (§4.4).
- **Categories**: the existing `CapsuleCategory` (`preGestation, gestation, postPartum, enfance, adulte`) already covers the mother's phases, so reuse it.

### 2.4 Quota

Mother and family capsules count toward the same tier quota (`capsuleCountProvider`). No new rule is needed, and the space is available to `exploring`/`hope` users with no children.

### 2.5 Mother appointments (needed for AI §4.3)

Add `/users/{uid}/appointments/{id}` (mother-level, same `Appointment` model with `childId` null and `subject: 'mother'`) for prenatal visits, ultrasounds and postpartum check-ups.

### 2.6 Decision needed: child limit on the free tier

`childLimit: 1` isn't enforced today. **Recommendation:** an *expected* baby never counts toward the limit. The limit applies at birth, when converting a second child to `born` shows the upgrade prompt. This creates a natural, emotional upsell moment without blocking pregnancy tracking.

---

## 3. Child folder before birth / gender unknown

### 3.1 Solution: the "expected child"

Create the child document **as soon as the pregnancy is declared** and mark it as expected:

```
/users/{uid}/children/{childId}
  lifecycle: 'expected' | 'born'            # NEW (missing ⇒ 'born')
  gender: 'boy' | 'girl' | 'unknown'        # 'unknown' NEW (missing ⇒ 'unknown', NOT 'boy')
  birthDate: Timestamp?                     # now nullable; null while expected
  expectedDate: Timestamp?                  # NEW, = pregnancy.eddDate
  pregnancyId: String?                      # NEW
  name: String                              # placeholder until birth, editable
  nickname / placeholder: e.g. "Bébé", "Petit cœur", or user-chosen
```

Behaviour:

| Topic | While `expected` + `unknown` | When sex is learned (ultrasound) | At birth |
|---|---|---|---|
| Name shown | Placeholder chosen by the mother ("Bébé", "Notre petit trésor"…), localised | Unchanged unless she renames | Real first name |
| Theme colour | **Neutral palette** (`AppColors.goldenrod` / `willowBrook`), never blue/pink by default | Optional switch to the gender colour (asked, not forced) | Unchanged |
| Age line | "Naissance prévue dans 12 semaines" / "Semaine 28" | Same | `ageString` as today |
| Capsules | All pregnancy photos and doctor visits attach to this child (`childIds` + `withMother`) | **Nothing moves.** All existing capsules stay linked because the child id never changes. | Same |
| "Gender reveal" | – | Optional special capsule "C'est un garçon / une fille !" with a celebration animation | – |
| Vaccines / milestones | Hidden, with an empty state: "Le calendrier démarre à la naissance" | Same | Calendar generated from the real `birthDate` |
| Sex never revealed | Supported: the mother can stay on `unknown` until birth | – | Sex asked in the birth wizard |

Twins: `pregnancy.babyCount = 2` creates two expected children ("Bébé 1", "Bébé 2"). A capsule like a shared ultrasound can be tagged with both thanks to `childIds`.

Why this beats the alternatives:
- *A separate "pregnancy album" that you move into the child at birth* adds a migration step, risks lost or duplicated memories, and breaks deep links.
- *Forcing a gender* corrupts data and themes, and is the current bug.

### 3.2 Code impact

- `Child`: make `birthDate` nullable and add `lifecycle`, `expectedDate`, `pregnancyId` and `ChildGender.unknown`. Change the parse fallback from `boy` to `unknown`.
- `ageString`, `themeColor`, `genderLabel` need `expected`/`unknown` branches. `genderLabel` should move to l10n (it's hard-coded French today).
- Every place that does `child.birthDate` arithmetic (vaccines, milestones, growth charts, timeline, child summary card) must guard on `lifecycle == born`. **Grep for `birthDate` before implementing.**
- `childrenProvider` keeps returning all children. Add `bornChildrenProvider` and `expectedChildrenProvider`.

---

## 4. AI assistant

### 4.1 Product shape

- **Dedicated screen** `/assistant` (top-level GoRouter route, **not** a sixth tab, because the bottom nav already has five).
  Entry points: the bird avatar in the Home `personal_header`, a Bento card on the dashboard, notification taps (deep link to the conversation and the recommendation), and contextual "Demander à <nom>" buttons (e.g., on a vaccine, a product, or the pregnancy panel).
- **Layout** (top to bottom):
  1. **Animated bird header** (~140 dp, shrinks to 48 dp while scrolling)
  2. Message list: chat bubbles in the app theme (light/dark); RTL is automatic for Arabic
  3. **Rich cards** inside the conversation (product, appointment, album, plan, weather outing)
  4. Suggestion chips above the input ("Que faire ce week-end ?", "Prochain vaccin ?", "Idée cadeau pour Amine")
  5. Input bar: text and send, plus an optional "attach photo" for "create a capsule from this"
- **Language**: the assistant answers in the app locale (`fr`/`ar`/`en`). Arabic may be answered in MSA or Darija depending on how the mother writes. All static UI strings go in the `.arb` files.

### 4.2 Architecture

```
Flutter (assistant screen)
  │  httpsCallable('aiChat', {conversationId, message, locale})
  ▼
Cloud Function aiChat  (functions/ai/*.mjs, europe-west1, auth required, App Check)
  1. Load minimal context from Firestore (server-side; the app never sends health data itself)
     - MotherStage, pregnancy week, children: [{alias, ageMonths, lifecycle}], wilaya,
       tier, upcoming vaccines/appointments (dates only), recentLoss flag
  2. Call the LLM with tools (below), stream tokens back
  3. Persist messages to /users/{uid}/aiConversations/{cid}/messages
  4. Return text + structured "cards"
  ▼
Flutter renders text + cards; cards with actions need a user tap to execute
```

Tools the model can call (server-side functions; **read-only or "propose" only**):

| Tool | Returns | Notes |
|---|---|---|
| `get_family_context` | stage, children ages, pregnancy week | Pseudonymised: no names sent unless the mother typed them |
| `list_health_schedule` | due/overdue vaccines, appointments (child + mother) | From the app's own vaccine calendar |
| `propose_appointment` | an `AppointmentSuggestion` card | The app creates the appointment **only after the mother confirms** |
| `search_products` | top N marketplace products matching age / stage / skill | Requires the new product fields (§4.5) |
| `get_weather` | Open-Meteo forecast for the wilaya centroid | No GPS permission needed; free, no API key |
| `propose_album` | predefined/standard album suggestion + pre-selected capsules | Opens the existing album builder pre-filled |
| `propose_subscription` | plan card (premium/vip) with the concrete benefit | Only when the user hits a real limit or asks |

**No tool writes data.** Every action goes through a card the mother taps. This keeps the AI safe and auditable, and keeps the existing services as the only writers.

Model choice: Claude via the Anthropic API from the Cloud Function. Use `claude-sonnet-5-5` for the chat and `claude-haiku-5-5` for the short notification copy in §4.4. The API key lives in Firebase Secret Manager and is never in the app.

### 4.3 Recommendation types

| Type | In-chat trigger | Proactive (notification) trigger | Guardrails |
|---|---|---|---|
| **Subscription** | Mother asks about a locked feature or hits the capsule quota | Quota ≥ 80 % used | Max 1 per 14 days. Never during `recentLoss`. Always shows what she gets, not pressure. |
| **Album** | "Fais-moi un album de la grossesse" → album card with suggested capsules → opens the album builder | A chapter just completed (birth, 1st birthday, 20+ bump photos) | One per chapter |
| **Doctor appointments** | "Quand est le prochain vaccin ?", pregnancy-week check-up reminders | Vaccine due in 7 days with no appointment; pregnancy-week visit (e.g., T2 ultrasound window) | **The AI never decides to move a medical date.** It only says "this vaccine is overdue/upcoming according to the official calendar; contact your doctor to schedule it". Anything about symptoms gets a "consult a doctor / emergency" escalation. Validate the wording with a health professional. |
| **Weather outing** | "Que faire aujourd'hui ?" | Good weather on a weekend (temp/UV/rain within thresholds for the child's age) | Heat/UV warnings for babies. Not for `pregnantFirst` in the 3rd trimester during heat waves. |
| **Marketplace** | "Idée de jouet pour Amine (6 ans)" → 1–3 product cards, each with **why it helps** ("développe la communication", "motricité fine") | Child enters a new age bracket; a stage changes (2nd trimester → maternity products) | Clearly labelled "Notre boutique". Max 2 commercial pushes per week. Never inside a medical or emotional distress conversation. Explain benefits honestly (from product data, never invented by the model). |

### 4.4 Proactive recommendations (notifications)

- A scheduled Cloud Function (`onSchedule`, daily at 09:00 Africa/Algiers) runs **deterministic rules** (cheap, testable) to choose at most one candidate per user per day, then asks the LLM to write a short, warm, localised message.
- It writes `/users/{uid}/aiRecommendations/{id}` `{type, payload, status: new|seen|accepted|dismissed, createdAt}` and sends via the existing FCM pipeline (`fcm_service.dart`) using a new `NotificationType.ai`.
- Tapping the notification opens `/assistant` with that recommendation shown as the first card.
- **User controls** (in `notifications_screen.dart`): one toggle per recommendation type, plus a global "Suggestions de l'assistant" switch. Commercial suggestions are opt-in by default (Law 18-07 / good practice).
- Track `accepted`/`dismissed` for analytics (`ai_reco_shown`, `ai_reco_accepted`) and to stop repeating dismissed suggestions.

### 4.5 Marketplace data needed (prerequisite)

Add these to `marketplace_products` (admin panel `luckymam_admin` + `MarketplaceProduct`):

```
audience: 'child' | 'mother' | 'pregnancy'
ageMinMonths: int?          ageMaxMonths: int?
pregnancyTrimesters: [1,2,3]?
skills: ['communication','motricite_fine','motricite_globale','cognitif','sensoriel','autonomie','sommeil', ...]
benefitsFr / benefitsAr / benefitsEn: [String]   # the "why it helps" text the AI quotes
```

Without these fields the AI would have to guess from free text, which is unreliable and risks false claims.

### 4.6 Compliance & safety (must-have before launch)

- **Law 18-07**: the assistant processes **health data** (pregnancy, child health) and sends it to a processor **outside Algeria**. You need:
  (1) a **separate explicit consent** screen before first use, logged in `consent_logs` like `Law1807ConsentScreen`;
  (2) data minimisation (aliases instead of names, ages instead of birth dates);
  (3) **legal review of the cross-border transfer requirements** (ANPDP authorisation). This is a blocker to check with counsel, not something to decide in code.
- Conversation retention: a "Supprimer mes conversations" option in Privacy, and automatic deletion after N months.
- A medical disclaimer in the chat header ("L'assistant ne remplace pas un médecin"), plus red-flag detection (bleeding, fever in a newborn, reduced fetal movement…) that returns a fixed escalation message and suppresses all recommendations.
- Usage quota: e.g., free = 10 messages/day, premium/vip = higher. Hitting it is a legitimate subscription touchpoint.

---

## 5. Animated avatar: the `CHARACTER_AI` kit

### 5.1 What the kit actually is

- A **procedural 2D character engine**: a squircle body, 3D-projected eyes, blinking, particles, 11 states (idle, working, thinking, searching, approval, question, error, finished, ratelimit, sleeping, dizzy) and emotes (love, surprised, proud, wink, yawn, annoyed). It has no Lottie/Rive and no images, only maths on a canvas.
- Source: **Swift/SwiftUI for macOS** (`BotEngine.swift`, 1 503 lines; `SoundEngine.swift` uses `AppKit`) plus a **JS web prototype** (`web_prototype/index.html`, which you can open in a browser to try every state).
- 28 WAV sounds (3.1 MB).
- **It is not Flutter and not a bird.** It's a "Mochi" blob driven by the mouse cursor.

### 5.2 Licence: read before integrating

The spec says: *"The mathematical engine… originate from the open-source project **Coucou** by Louis Raillé (MIT). The visual persona 'Mochi' and associated brand assets remain copyright (c) Louis Raillé."*

Consequences:
- ✅ We can **port the engine** (keep the MIT notice in a `THIRD_PARTY_NOTICES` file and in the app's licences page; Flutter's `LicenseRegistry` can register it).
- ❌ We **must not ship the Mochi look** as-is. A distinct bird design is required anyway, and it also fixes this problem.
- ⚠️ **Sounds**: their licence isn't stated. They may count as "brand assets". Confirm against the original Coucou repository before shipping, or replace them with our own or CC0 sounds.

### 5.3 Integration plan: port to Flutter as a bird

Port the engine to Dart (it's pure maths, so it maps 1:1 onto `CustomPainter`), then reshape it:

```
lib/features/assistant/
  avatar/
    bird_engine.dart       # state, tweens, blink, particles, physics (port of BotEngine update())
    bird_painter.dart      # CustomPainter (port of draw(); new bird geometry)
    bird_avatar.dart       # StatefulWidget + Ticker, gestures, RepaintBoundary
    bird_sounds.dart       # audioplayers (already a dependency), short OGG files
  screens/assistant_screen.dart
  widgets/ (message_bubble, reco_cards/*, suggestion_chips, chat_input)
  providers/ services/ models/
```

Bird design (reusing engine parts):

| Engine part | Becomes |
|---|---|
| Superellipse body (n = 2.7) | Rounder, slightly pear-shaped body (n ≈ 2.2, taller `ry`) with a lighter belly patch |
| 3D spherical eyes, gaze, blink | **Kept as-is**: they carry most of the charm |
| Cheeks / blush | Kept |
| "Hands" (overhead/behind) | **Wings**: flap on greet/finished, cover eyes on "shy", one wing waves hello |
| Badges (`•••`, `!`, `?`) | Kept, re-skinned |
| Particles (hearts, stars, Zzz) | Kept, plus **feathers** on celebration |
| *(new)* | **Beak**: opens and closes while the answer streams (one tick per token chunk), the main "talking" signal |
| *(new)* | Head tuft that bounces with idle breathing, and a small tail |

Brand colours (from `AppColors`): body gradient `hitPink #FAB187` → `coral #E85A71`, belly `negroni #FEE4C1`, beak `casablanca #F9AD4A`, state tints mapped to the brand (thinking `smaltBlue`, celebrating `goldenrod`, love `magentaPink`). Dark mode uses a softer glow.

### 5.4 Chat → avatar behaviour mapping

| Chat event | Bird state / emote |
|---|---|
| Screen opens | `greet`: wing wave and a happy hop |
| Mother is typing | `listening`: leans toward the input, eyes look down at the text field |
| Waiting for the first token | `thinking`: eyes up-right, `•••` badge |
| Tool call (search products / weather) | `searching`: eyes scan left and right |
| Streaming answer | `speaking`: beak animates |
| AI asks a clarifying question | `question`: head tilt, `?` badge |
| Recommendation accepted (album created, product added to cart) | `proud`: star eyes, feather burst |
| Mother says thanks / shares a baby photo | `love`: heart eyes, blush |
| Sensitive or health-worry topic | **`gentle`** (new): calm, slow blink, soft tint. Don't reuse `error` (red shake) or celebratory emotes. |
| Network error | `confused`: small head shake (soft, not the red `error`) |
| 60 s idle / night (22:00–06:00) | `yawn` → `sleeping` with Zzz |
| Tapped | Small hop and chirp. Tapped 5× quickly → `dizzy` (easter egg) |
| `recentLoss` flag | Only calm states. No celebrations, particles or sounds. |

Mobile adaptations (the kit is desktop/mouse based):
- Gaze follows **touch/drag** and looks at the newest message. An optional subtle gyroscope parallax would need `sensors_plus` (a new dependency).
- **Performance**: `RepaintBoundary`, pause the ticker when the screen isn't visible, and reduce to 30 fps on low-end devices.
- **Accessibility**: respect `MediaQuery.disableAnimations` (static pose) and give it a semantic label.
- **Sounds**: off by default, toggled in settings. Convert WAV to OGG (3.1 MB → ~300 KB). Respect silent mode.

Name: give the bird a name the mother can call it, in all 3 languages (e.g., "Lucky"). It's a branding decision.

---

## 6. Proposed tickets (to create in `docs/updates/issues/` after validation)

| ID | Title | Prio | SP | Depends on |
|---|---|---|---|---|
| LM2-140 | `MotherStage` model + `pregnancies` collection + migration | Must | 8 | – |
| LM2-141 | Refactor home/status consumers to stage capabilities (fixes pregnant + children) | Must | 8 | 140 |
| LM2-142 | New onboarding questions (children? pregnant? TTC?) | Must | 5 | 140 |
| LM2-143 | Expected child (`lifecycle`, `gender: unknown`, nullable birthDate) | Must | 8 | 140 |
| LM2-144 | Birth wizard (expected → born) + "gender reveal" capsule | Must | 5 | 143 |
| LM2-145 | Pregnancy end / loss flow (sensitive) | Must | 5 | 140 |
| LM2-146 | Capsule subjects (`childIds`, `withMother`, `space`) + migration + indexes + rules | Must | 8 | – |
| LM2-147 | Mother journey screen + "Qui est sur ce souvenir ?" picker + family filter | Must | 8 | 146 |
| LM2-148 | Mother-level appointments | Should | 3 | – |
| LM2-149 | Marketplace product fields (age, skills, benefits) in admin + app | Must (for AI) | 5 | – |
| LM2-150 | Bird avatar: Dart engine port + bird design + states | Should | 13 | – |
| LM2-151 | Assistant screen UI (chat, cards, chips, i18n, RTL, dark mode) | Must | 8 | 150 (can start with a static avatar) |
| LM2-152 | `aiChat` Cloud Function + tools + streaming + quota | Must | 13 | 149 |
| LM2-153 | AI consent (Law 18-07) + conversation retention/deletion | Must | 5 | legal review |
| LM2-154 | Proactive recommendations (scheduler, rules, FCM, settings toggles) | Should | 8 | 152 |
| LM2-155 | Weather (Open-Meteo, wilaya centroids) | Could | 3 | 152 |

Suggested order: **140 → 146 → 143 → 141/142 → 144/145 → 147** (fixes the data model first), then **149 → 152 → 151 → 150 → 153 → 154/155**.

---

## 7. Open decisions for the product owner

1. **Free tier and expected babies**: do expected babies count toward `childLimit`? (Recommendation: no, until birth. See §2.6.)
2. **Legal**: can health data go to a non-Algerian AI provider under Law 18-07, and under which authorisation? This blocks the AI launch.
3. **Bird name and final illustration**: a designer should validate the shape before the 13-SP port.
4. **Sounds**: confirm the licence of the kit's WAV files, or commission or replace them.
5. **Commercial frequency**: confirm the caps (≤ 2 marketplace pushes/week, ≤ 1 subscription push/14 days).
6. **Medical wording**: have a doctor or midwife review the appointment and red-flag messages.
