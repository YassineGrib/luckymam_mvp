# AI Assistant (pink bird + Gemini chat) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A dedicated `/assistant` page with a pink animated bird avatar and a chat powered by Gemini that gives in-chat recommendations (subscription, album, appointments, weather outing, marketplace products with their benefits).

**Architecture:** Flutter talks to one callable Cloud Function `aiChat`; the function holds the Gemini key (Secret Manager), reads minimal family context from Firestore, runs a Gemini tool-calling loop whose tools only *read* or *propose* (return cards), and returns `{reply, cards, mood}`. The bird is a pure-Dart procedural engine (port of the CHARACTER_AI kit's maths) drawn with `CustomPainter`; the chat screen depends on an `AssistantBackend` interface so UI and bird are built and tested against a scripted fake before the real backend is wired.

**Tech Stack:** Flutter + Riverpod 2 + go_router; `cloud_functions` (new); Node 20 Cloud Functions v2 (`onCall`, `defineSecret`), `node:test`; Gemini REST API (`generateContent` with function calling); Open-Meteo for weather.

**Spec:** `docs/specs/SPEC_mother_journey_and_ai_assistant.md` §4–§5 (FR/AR: `docs/specs/parcours_maman_ia/`). Builds on branch `feat/mother-journey-foundation` (MotherStage, pregnancies, expected children).

**Out of scope (next plan):** proactive daily notifications; mother-level appointment storage (LM2-148); conversation persistence across app restarts; bird sounds (CHARACTER_AI WAV licence unconfirmed — ship silent); deploying the function (controller step, needs the owner's go-ahead: Blaze plan + live project).

## Global Constraints

- The Gemini API key **never** appears in the Flutter app, in any tracked file, in logs, or in tests. It lives only in Firebase Secret Manager as `GEMINI_API_KEY` (local emulator: `functions/.secret.local`, which MUST be git-ignored — verify `functions/.gitignore`).
- Models, in order, each with up to 2 retries on HTTP 429/500/503 or a 20 s timeout: primary `gemini-flash-lite-latest`; fallbacks `gemini-flash-latest`, then `gemini-3.8-flash`. (`gemini-2.5-flash` is closed to new accounts — do not use.) Model names live in one constant array in `functions/ai/gemini.mjs`.
- Callable: `onCall`, region `europe-west1`, `timeoutSeconds: 60`, `secrets: [GEMINI_API_KEY]`, authentication required (reject `unauthenticated`).
- Daily message quota per user (Africa/Algiers date): free 10, premium 50, vip 100. Exceeding → `HttpsError('resource-exhausted')`.
- Privacy by construction: the context sent to Gemini contains child **aliases** ("enfant 1"), ages in months, pregnancy week, stage, wilaya, tier — never names, birth dates, phone, email.
- Assistant answers in the app locale (`fr` default, `ar`, `en`). All UI strings in `lib/l10n/app_{fr,ar,en}.arb` (template `app_fr.arb`), then `flutter gen-l10n`. Never hard-code user-facing strings in Dart.
- Bird colours come from `AppColors` (coral `#E85A71`, magentaPink `#A7316E`, negroni `#FEE4C1`, casablanca `#F9AD4A`, goldenrod, smaltBlue, oil) plus one soft pink `Color(0xFFFFC9D2)` defined once in `bird_palette.dart`. The bird is pink.
- Assistant display name is the single l10n key `assistantName` = "Lucky" (all 3 locales).
- UI follows the existing look: Squircle Bento cards, light/dark theme, RTL for Arabic.
- Medical safety: the assistant never decides to move or cancel a medical date; it only cites the official schedule and tells the user to contact her doctor.
- `flutter analyze` must stay at "No issues found"; `flutter test` and `cd functions && npm test` green.
- Branch `feat/ai-assistant` (from `feat/mother-journey-foundation`); one commit per task; commit messages end with a blank line then `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Review Focus

1. Gemini returns 503 / times out on every model → user sees one friendly localized message, never a raw error; bird goes `confused` (Task 6 test `all models fail → unavailable error`, Task 8 test `unavailable maps to friendly message`).
2. A message describing a medical red flag ("saignement", "نزيف", "no fetal movement", fever in a newborn) → fixed escalation text, **no model call**, no cards (Task 6 test `red flag skips model`).
3. The model asks to recommend a product id that `search_products` did not return this turn → no card, and the `why` text on a product card always comes from stored product data, never from the model (Task 7 tests `unknown product id is dropped` and `why comes from stored benefits`).
4. A pregnancy that ended in the last 90 days → no product / subscription / album cards and a gentle mood, whatever the model asks for (Task 7 test `sensitive period strips commercial cards`).
5. Arabic (RTL) chat on a 360 dp wide screen: bubbles and cards do not overflow; with reduced motion the bird is a static pose (Task 4 widget tests).

---

### Task 0: Branch + tickets

**Files:**
- Create: `docs/updates/issues/LM2-149.md`, `LM2-150.md`, `LM2-151.md`, `LM2-152.md`, `LM2-155.md` (French, same structure as `docs/updates/issues/LM2-124.md`, Statut `🔄 En cours`; titles: 149 "Champs produit pour l'assistant (âge, compétences, bénéfices)", 150 "Avatar oiseau rose animé", 151 "Écran assistant (chat, cartes, i18n)", 152 "Assistant Gemini — Cloud Function aiChat et outils", 155 "Météo pour les sorties (Open-Meteo)")
- Modify: `docs/updates/TASKS.md` (new section "## 🟣 Addendum Assistant IA — 5 tickets", rows 🔄; count line 26 → 31; date 2026-10-22)

- [ ] **Step 1:** `git checkout -b feat/ai-assistant` (from the current `feat/mother-journey-foundation` HEAD).
- [ ] **Step 2:** Write the 5 issue files and TASKS.md rows. Priorities: 149 Must 5 SP, 150 Should 13 SP, 151 Must 8 SP, 152 Must 13 SP, 155 Could 3 SP.
- [ ] **Step 3:** Also commit `docs/superpowers/plans/2026-10-22-ai-assistant.md` and `CHARACTER_AI/CHARACTER_AI_SPEC.md` + `CHARACTER_AI/web_prototype/index.html` + `CHARACTER_AI/swift/` (reference for the port; NOT `CHARACTER_AI/sounds/`). Commit `docs(backlog): add LM2-149/150/151/152/155 assistant tickets`.

---

### Task 1: Bird engine (pure Dart, pink)

**Files:**
- Create: `lib/features/assistant/avatar/bird_state.dart`, `lib/features/assistant/avatar/bird_palette.dart`, `lib/features/assistant/avatar/bird_engine.dart`
- Test: `test/bird_engine_test.dart`

**Interfaces:**
- Produces:
  - `enum BirdState { idle, greeting, listening, thinking, searching, speaking, question, proud, love, gentle, confused, sleeping, dizzy }`
  - `class BirdPalette { static const Color softPink = Color(0xFFFFC9D2); static Color bodyLight/bodyDark/belly/beak/cheek/eye/glow(BirdState) ... }` built from `AppColors` (see Global Constraints); `Color tintFor(BirdState)`: thinking→smaltBlue, searching→smaltBlue, proud→goldenrod, love→magentaPink, gentle→willowBrook, others→none (`Colors.transparent`).
  - `class BirdEngine` — `BirdEngine({Random? random})`; fields (read by the painter): `double yaw, pitch, roll, tilt, scaleX, scaleY, eyeOpen, blush, wingAngle, beakOpen, breathe; BirdState state; List<BirdParticle> particles`; methods: `void setState(BirdState s)`, `void update(double dtSeconds)`, `void lookAt(double dx, double dy)` (normalised offsets from the bird centre, same tanh compression as the kit: `yaw = tanh(dx/260)*0.62`, `pitch = tanh(dy/200)*0.50`, exponential smoothing `1 - 0.0025^dt`), `void poke()` (squash-and-stretch hop), `void tapMany()` (5 taps within 1.5 s ⇒ `dizzy` for 1.3 s then back to previous state), `void setSpeaking(bool)` (drives `beakOpen` oscillation while true), `void setReducedMotion(bool)` (freezes all motion at the neutral pose, `eyeOpen` stays 1, no particles).
  - `class BirdParticle { double x, y, vx, vy, age, life; ParticleKind kind; }` with `enum ParticleKind { heart, star, feather, zzz }`.
  - Easing helpers `easeOut`, `easeInOut`, `easeBack` exactly as in `CHARACTER_AI_SPEC.md` §6.

- [ ] **Step 1: Write failing tests** (`test/bird_engine_test.dart`; inject `Random(1)`; step `update(1/60)` in loops):
  - `blink closes then reopens within 0.3 s` (force a blink via a test-visible `debugBlinkNow()`; assert `eyeOpen < 0.2` after ~0.07 s and `> 0.95` after 0.3 s).
  - `idle blinks eventually` (simulate 8 s; `eyeOpen` dipped below 0.5 at least once).
  - `gaze is compressed and smoothed` (`lookAt(10000, 0)` then 2 s of updates ⇒ `yaw` within 0.01 of `0.62`, never above `0.62`).
  - `speaking opens and closes the beak` (`setSpeaking(true)`, 1 s ⇒ `beakOpen` takes values both `< 0.2` and `> 0.6`; after `setSpeaking(false)` and 0.5 s ⇒ `< 0.05`).
  - `five quick taps cause dizzy then recover` (`tapMany` ⇒ state `dizzy`; after 1.4 s ⇒ previous state restored).
  - `love emits heart particles; particles die` (setState love, 1 s ⇒ ≥1 heart; after 6 s all gone).
  - `reduced motion freezes the pose` (`setReducedMotion(true)`, `lookAt`, 2 s ⇒ yaw, roll, tilt, beakOpen all 0; particles empty).
  - `gentle never emits particles or shakes` (setState gentle, 3 s ⇒ no particles; `roll == 0`).
  - `palette is pink` (`BirdPalette.bodyLight` red channel > green and blue channels; `bodyDark == AppColors.coral`).
- [ ] **Step 2:** `flutter test test/bird_engine_test.dart` → FAIL (files missing).
- [ ] **Step 3: Implement** the three files. Port the maths from `CHARACTER_AI/web_prototype/index.html` (class around line 548: `setState`, `emote`, `update`) and `CHARACTER_AI/swift/BotEngine.swift` (`update(dt:)`), dropping everything not in the interface (no sounds, no hands/badges). State behaviours: `idle` breathing + random blink every 2.2–5.4 s (22 % double-blink); `greeting` wing wave + hop 1.2 s then idle; `listening` pitch down 0.25; `thinking` gaze fixed up-right (+0.55,+0.55); `searching` yaw `sin(2.6 t)*0.5`; `question` tilt 0.17; `proud` backward tilt + star particles; `love` blush 1 + hearts; `gentle` slow blink (period 4–7 s), no particles; `confused` small head shake once (±0.15 rad, 0.5 s) then idle pose; `sleeping` eyes closed + `zzz` particles + slow breathing; `dizzy` double roll 1.3 s.
- [ ] **Step 4:** `flutter test test/bird_engine_test.dart` → PASS.
- [ ] **Step 5:** `flutter analyze lib/features/assistant test/bird_engine_test.dart` → No issues. Commit `feat(assistant): add pink bird animation engine`.

---

### Task 2: Bird painter + `BirdAvatar` widget

**Files:**
- Create: `lib/features/assistant/avatar/bird_painter.dart`, `lib/features/assistant/avatar/bird_avatar.dart`
- Test: `test/bird_avatar_test.dart`

**Interfaces:**
- Consumes: `BirdEngine`, `BirdState`, `BirdPalette` (Task 1).
- Produces:
  - `class BirdPainter extends CustomPainter { BirdPainter(this.engine, {required Listenable repaint, required bool isDark}) }` — draws, in order: soft radial glow tinted by `BirdPalette.tintFor`; tail; body (superellipse, exponent 2.2, `ry` taller than `rx`, vertical gradient softPink→coral, radial edge shading, specular highlight); belly patch (negroni); wings (two, rotate by `wingAngle`); head tuft bouncing with `breathe`; cheeks (coral, alpha by `blush`); eyes (3D-projected using `yaw/pitch`, scale by `eyeOpen`, horizon clipping when `|yaw|` large; heart/star eyes for `love`/`proud`); beak (casablanca, opening by `beakOpen`); particles (hearts, stars, feathers, zzz).
  - `class BirdAvatar extends StatefulWidget { const BirdAvatar({super.key, required this.state, this.speaking = false, this.size = 140, this.onTap}) }` — owns a `BirdEngine` + `Ticker`; pushes `state`/`speaking` changes into the engine in `didUpdateWidget`; wraps in `RepaintBoundary`; `GestureDetector` for tap (`engine.poke()`, count rapid taps → `tapMany`) and pan/drag (`engine.lookAt` from local position relative to centre); ticker is muted when `TickerMode` is disabled (screen hidden) via `TickerMode.of(context)`; if `MediaQuery.of(context).disableAnimations` ⇒ `engine.setReducedMotion(true)`; `Semantics(label: l10n.assistantName ...)`.

- [ ] **Step 1: Failing widget tests** (`test/bird_avatar_test.dart`, wrap in `MaterialApp` with localization delegates): `renders in every BirdState without exceptions` (loop all states, `pump(Duration(milliseconds: 100))`); `tap triggers poke and does not throw`; `reduced motion renders a static pose` (`MediaQuery(disableAnimations: true)` ⇒ after pumping 1 s the engine `yaw/roll/tilt` are 0 — expose the engine via `BirdAvatarState.debugEngine`); `has a semantics label`; `paints in dark mode` (pump with `ThemeData.dark()`).
- [ ] **Step 2:** run → FAIL. **Step 3:** implement painter + widget. Keep the painter allocation-light (reuse `Paint`/`Path` objects as fields; sample the superellipse with 56 points).
- [ ] **Step 4:** run → PASS. **Step 5:** analyze; commit `feat(assistant): draw the pink bird avatar`.

---

### Task 3: Assistant models, backend interface, controller (fake backend)

**Files:**
- Create: `lib/features/assistant/models/assistant_models.dart`, `lib/features/assistant/services/assistant_backend.dart`, `lib/features/assistant/services/fake_assistant_backend.dart`, `lib/features/assistant/providers/assistant_providers.dart`
- Test: `test/assistant_controller_test.dart`

**Interfaces:**
- Produces:
  - `enum AssistantRole { user, assistant }`; `enum AssistantMood { neutral, gentle, proud, love, question }`.
  - `sealed class AssistantCard` with `factory AssistantCard.fromJson(Map<String,dynamic>)` (unknown `type` ⇒ returns `null` via `AssistantCard.tryParse`); subclasses: `ProductCard{String productId, String name, int priceDZD, String why, String? imageUrl}`, `AppointmentCard{String subject /*child|mother*/, String? childAlias, String title, String? suggestedDate, String reason}`, `AlbumCard{String albumKind /*predefined|standard*/, String title, String reason}`, `SubscriptionCard{String tier /*premium|vip*/, String benefit}`, `WeatherCard{String summary, double tempC, String outingIdea}`.
  - `class AssistantMessage { final String id; final AssistantRole role; final String text; final List<AssistantCard> cards; final DateTime createdAt; final bool isError; }`
  - `class AssistantReply { final String text; final List<AssistantCard> cards; final AssistantMood mood; }`
  - `class AssistantException implements Exception { final AssistantErrorKind kind; }`, `enum AssistantErrorKind { quota, unavailable, network, unauthenticated, unknown }`.
  - `abstract class AssistantBackend { Future<AssistantReply> send({required List<AssistantMessage> history, required String message, required String locale}); }`
  - `class FakeAssistantBackend implements AssistantBackend` — scripted: message containing "vaccin" ⇒ `AppointmentCard`; "jouet|cadeau|toy|لعبة" ⇒ `ProductCard`; "album" ⇒ `AlbumCard`; "sortie|outing|نزهة" ⇒ `WeatherCard`; "abonnement|subscription|اشتراك" ⇒ `SubscriptionCard`; "erreur" ⇒ throws `AssistantException(unavailable)`; else a short reply. Constructor takes `Duration delay = const Duration(milliseconds: 600)`.
  - `class AssistantState { final List<AssistantMessage> messages; final AssistantPhase phase; final BirdState bird; }`, `enum AssistantPhase { idle, thinking, speaking }`.
  - `class AssistantController extends StateNotifier<AssistantState>` — `AssistantController(AssistantBackend backend, {required String locale})`; `Future<void> send(String text)` (trims; ignores empty; appends user message; phase thinking + bird `thinking` (bird `searching` if the previous reply asked for products — keep simple: always `thinking`); on reply appends assistant message, phase `speaking` + bird mapped from mood: neutral→idle, gentle→gentle, proud→proud, love→love, question→question; after `speakingDuration(text)` (= 30 ms per char, min 600 ms, max 4 s; injectable via constructor `Duration Function(String)?`) phase→idle; on `AssistantException` appends an `isError` assistant message with kind-specific l10n **key** stored in `text` (`assistantErrorQuota|Busy|Network|Generic`) and bird `gentle` for quota, `confused` otherwise); `void onUserTyping(bool typing)` ⇒ bird `listening` when typing and phase idle, else `idle`; `void greet()` ⇒ bird `greeting` for 1.2 s then `idle`. History sent to the backend = last 20 messages excluding errors.
  - Providers: `assistantBackendProvider = Provider<AssistantBackend>((ref) => FakeAssistantBackend())` (replaced in Task 7), `assistantControllerProvider = StateNotifierProvider.autoDispose<AssistantController, AssistantState>`, locale from the existing `localeProvider` (`lib/core/providers/`).

- [ ] **Step 1: Failing tests** (`test/assistant_controller_test.dart`, `FakeAssistantBackend(delay: Duration.zero)`, injected `speakingDuration: (_) => Duration.zero`, `ProviderContainer` or direct controller): `AssistantCard.fromJson parses every card type`; `unknown card type is skipped by tryParse`; `send appends user then assistant message`; `empty text is ignored`; `thinking then idle bird mapping` (record `state.bird` over time via listener: `thinking` appears, then mood bird, then `idle`); `fake outing reply carries a weather card`; `backend exception becomes an error message with confused bird`; `quota exception → gentle bird and key assistantErrorQuota`; `history excludes error messages and is capped at 20`; `typing sets listening only when idle`.
- [ ] **Step 2:** FAIL. **Step 3:** implement. **Step 4:** PASS. **Step 5:** analyze; commit `feat(assistant): chat models, backend interface and controller`.

---

### Task 4: Assistant screen, cards, entry points, i18n

**Files:**
- Create: `lib/features/assistant/screens/assistant_screen.dart`, `lib/features/assistant/widgets/message_bubble.dart`, `lib/features/assistant/widgets/assistant_cards.dart`, `lib/features/assistant/widgets/suggestion_chips.dart`, `lib/features/assistant/widgets/chat_input_bar.dart`, `lib/features/home/widgets/assistant_shortcut_card.dart`
- Modify: `lib/core/router/app_router.dart` (route `path: '/assistant', name: 'assistant'`, same transition style as `memory-book`), `lib/features/home/tabs/dashboard_tab.dart` (add `AssistantShortcutCard` right after `HomeBentoGrid`), `lib/features/home/widgets/personal_header.dart` (small `BirdAvatar(size: 44)` that opens the route — place near the avatar), `lib/l10n/app_fr.arb`, `app_ar.arb`, `app_en.arb` (+ regenerate)
- Test: `test/assistant_screen_test.dart`

**Interfaces:**
- Consumes: Task 2 `BirdAvatar`; Task 3 controller/providers/models; existing routes `marketplace`, `subscription`, `album-templates`, `health` (see `lib/core/router/app_router.dart`) and the product detail screen (find how `marketplace_screen.dart` opens `product_detail_screen.dart`).
- Produces:
  - `AssistantScreen` (ConsumerStatefulWidget): collapsing header with `BirdAvatar` (140 dp → 48 dp as the list scrolls), disclaimer line `l10n.assistantDisclaimer`, message list (reverse), suggestion chips (4, shown while the conversation has ≤ 1 message), `ChatInputBar` (text field, send button disabled when empty/thinking; calls `controller.onUserTyping`), calls `controller.greet()` once in `initState`, assistant greeting message from `l10n.assistantGreeting` shown as the first (local, non-backend) message.
  - `MessageBubble` (user: coral-tinted, assistant: surface with border; error messages render `assistantError*` strings resolved from the stored key), directional-aware (`AlignmentDirectional`, `EdgeInsetsDirectional`) so Arabic mirrors correctly.
  - `AssistantCardView(card, onAction)` rendering the 5 card types as Squircle Bento cards: product (name, price `formattedPrice` style `"{n} DZD"`, the `why` benefit line, CTA → opens product detail via the marketplace screen/route), album (CTA → `album-templates`), subscription (CTA → `subscription`), appointment (CTA for `child` → `health`; for `mother` informational only, no CTA), weather (summary + temp + outing idea, no CTA). Cards constrained to `maxWidth` of the bubble column; text wraps, never overflows at 360 dp.
  - l10n keys (fr source values; AR/EN translated naturally): `assistantName` "Lucky", `assistantTitle` "Mon assistante", `assistantGreeting` "Bonjour ! Je suis Lucky. Je peux t'aider pour la santé, les souvenirs, les sorties et les idées cadeaux pour tes enfants.", `assistantDisclaimer` "Lucky ne remplace pas un médecin.", `assistantInputHint` "Écris ton message…", `assistantSend` "Envoyer", `assistantThinking` "Lucky réfléchit…", `assistantSuggestionOutingToday`, `assistantSuggestionNextVaccine`, `assistantSuggestionGiftIdea`, `assistantSuggestionMakeAlbum`, `assistantErrorGeneric`, `assistantErrorQuota`, `assistantErrorBusy`, `assistantErrorNetwork`, `assistantCardProductCta` "Voir le produit", `assistantCardAlbumCta` "Créer l'album", `assistantCardSubscriptionCta` "Découvrir l'offre", `assistantCardAppointmentCta` "Ouvrir la santé", `assistantCardWeatherTitle` "Idée de sortie", `assistantShortcutTitle` "Parle à Lucky", `assistantShortcutSubtitle` "Conseils, albums, sorties et idées cadeaux".
  - `AssistantShortcutCard`: Bento card with a mini static-ish `BirdAvatar(size: 56)`, title/subtitle above, `context.pushNamed('assistant')` on tap.

- [ ] **Step 1: Failing widget tests** (`test/assistant_screen_test.dart`; override `assistantBackendProvider` with `FakeAssistantBackend(delay: Duration.zero)`; wrap with localization delegates + a `ProviderScope`; GoRouter stub or `Navigator` observer for CTA taps): `shows greeting and 4 suggestion chips`; `typing and sending shows the user bubble then the reply`; `outing question renders a weather card`; `product question renders a product card with its benefit and CTA`; `error message is localized (fr and ar)` (message "erreur"); `send button disabled when empty`; **`arabic layout at 360dp does not overflow`** (`tester.view.physicalSize = Size(360*3, 800*3)`, locale `ar`, send "jouet" and "vaccin", `tester.takeException()` is null); **`reduced motion keeps the bird static`** (MediaQuery disableAnimations ⇒ no exceptions after pumping); `shortcut card navigates to assistant`.
- [ ] **Step 2:** FAIL. **Step 3:** implement; add arb keys in all 3 files; `flutter gen-l10n`. **Step 4:** PASS. **Step 5:** `flutter analyze` (whole project) clean; commit `feat(assistant): chat screen, recommendation cards and entry points`.

---

### Task 5: Marketplace product fields for recommendations (LM2-149)

**Files:**
- Modify: `lib/features/marketplace/models/marketplace_product.dart`, `luckymam_admin/src/routes/marketplace-catalog.tsx` (product create/edit form)
- Test: `test/marketplace_product_fields_test.dart`

**Interfaces:**
- Produces on `MarketplaceProduct` (all optional, backward compatible): `String audience` (`'child'|'mother'|'pregnancy'`, default `'child'`), `int? ageMinMonths`, `int? ageMaxMonths`, `List<int> pregnancyTrimesters` (default `[]`), `List<String> skills` (default `[]`; allowed: `communication, motricite_fine, motricite_globale, cognitif, sensoriel, autonomie, sommeil, creativite, langage`), `List<String> benefitsFr`, `benefitsAr`, `benefitsEn` (default `[]`); `List<String> benefitsFor(String locale)` (locale `ar`/`en`/else fr; falls back to `highlights` when the locale list is empty); `bool fitsChildAge(int months)` (true when audience is `child` and months within `[ageMinMonths ?? 0, ageMaxMonths ?? 999]`). Parsed in `fromFirestore` (find it), written in `toFirestore` if the model has one.
- Admin: add inputs for audience (select), age min/max (months), skills (multi-select chips with the 9 ids), and benefits FR/AR/EN (one per line textarea) to the existing create/edit product form; persist to the same Firestore fields. Follow the file's existing form/component style; no new UI libraries.

- [ ] **Step 1: Failing tests:** `legacy product without new fields parses with defaults`; `parses audience, ages, skills and benefits`; `benefitsFor falls back to highlights`; `fitsChildAge respects bounds and audience`; `mother audience never fits a child age`.
- [ ] **Step 2:** FAIL. **Step 3:** implement model + admin form. **Step 4:** `flutter test`; in `luckymam_admin` run its `npm run build` (or the project's type-check script from its `package.json`) → success. **Step 5:** analyze; commit `feat(marketplace): add age, skills and benefits fields for recommendations`.

---

### Task 6: `aiChat` core — Gemini client, quota, red flags, handler

**Files:**
- Create: `functions/ai/gemini.mjs`, `functions/ai/redflags.mjs`, `functions/ai/quota.mjs`, `functions/ai/tier.mjs`, `functions/ai/prompt.mjs`, `functions/ai/handler.mjs`, `functions/ai/aiChat.mjs`
- Modify: `functions/index.mjs` (add `export { aiChat } from "./ai/aiChat.mjs";`), `functions/package.json` (`"scripts": {"test": "node --test"}`; no new runtime deps — use Node 20 global `fetch`), `functions/.gitignore` (ensure `.secret.local` and `node_modules` ignored)
- Test: `functions/ai/gemini.test.mjs`, `redflags.test.mjs`, `quota.test.mjs`, `tier.test.mjs`, `handler.test.mjs`

**Interfaces:**
- Produces:
  - `gemini.mjs`: `export const MODELS = ['gemini-flash-lite-latest','gemini-flash-latest','gemini-3.8-flash']`; `export class GeminiUnavailableError extends Error {}`; `export async function generate({apiKey, contents, systemInstruction, tools, fetchImpl = fetch, models = MODELS, retries = 2, timeoutMs = 20000, sleep = ms => new Promise(r => setTimeout(r, ms))})` → returns the first `candidates[0].content` object (`{role, parts}`); iterates models, retries a model on 429/500/503/timeout with backoff 400 ms × attempt (injectable `sleep`), moves to the next model after retries, throws `GeminiUnavailableError` when all fail; 400/401/403/404 for a model skips to the next model without retrying; request URL `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`, header `X-goog-api-key`; body `{contents, systemInstruction:{parts:[{text}]}, tools, generationConfig:{temperature:0.6, maxOutputTokens:700}}`.
  - `redflags.mjs`: `export function detectRedFlag(text, locale)` → `null | {message}`; patterns (fr/ar/en, case/diacritic-insensitive) for: heavy bleeding / saignement abondant / نزيف; no or reduced fetal movement / "ne bouge plus" / "plus de mouvements" / حركة الجنين; newborn fever / "bébé fièvre" / حمى رضيع; difficulty breathing / "ne respire pas" / ضيق التنفس; seizure / convulsion / تشنج; severe abdominal pain in pregnancy; intent of self-harm (fixed supportive message with the national emergency numbers placeholder `14`/`15` — use "les urgences (14 / 15)" wording). `message` is a fixed localized text: contact the doctor or emergency services now.
  - `tier.mjs`: `export function tierFromUserDoc(data, now = new Date())` → `'free'|'premium'|'vip'`; mirror the Dart logic in `lib/features/subscription/providers/subscription_providers.dart` (read it: field names for tier and `subscriptionEndDate`; expired ⇒ `free`).
  - `quota.mjs`: `export const DAILY_LIMITS = {free:10, premium:50, vip:100}`; `export function algiersDateKey(now)` → `YYYY-MM-DD` in `Africa/Algiers`; `export async function consumeQuota({db, uid, tier, now})` — transaction on `users/{uid}/aiUsage/{dateKey}` field `count`; throws `QuotaExceededError` when `count >= limit`, else increments and returns `{used, limit}`. `db` is the injected minimal interface `{ runTransaction(fn), doc(path) }` wrapping firebase-admin (the adapter lives in `aiChat.mjs`).
  - `prompt.mjs`: `export function buildSystemPrompt({locale, context})` — persona "Lucky" (warm, short, practical, a friendly pink bird); answer in `locale`; never give diagnoses; never decide to move or cancel a medical date, cite the official schedule and tell the user to contact her doctor; use tools for facts instead of guessing; recommend products only through `search_products` and quote only the benefits it returns; keep answers under ~120 words; mention at most one recommendation per reply unless asked; if `context.sensitive` is true, be gentle and make **no** commercial suggestions.
  - `handler.mjs`: `export async function handleChat({uid, message, history, locale, deps, now = new Date()})` where `deps = {apiKey, db, generate, makeTools /* from Task 7: ({uid, context, locale}) => ({definitions, execute(name, args) => Promise<{result, card?}>}) */, loadContext}`; steps: validate `message` (non-empty string ≤ 1000 chars, else `invalid-argument`); `detectRedFlag` → return `{reply: message, cards: [], mood: 'gentle'}` **before** quota and model; load user doc → tier → `consumeQuota`; `context = await loadContext(uid)`; Gemini loop (max 4 rounds): send `contents` (history mapped to `{role:'user'|'model', parts:[{text}]}` + current message), execute any `functionCall` parts via `tools.execute(name, args)` (where `tools = deps.makeTools({uid, context, locale})`, created once per request after `loadContext`) collecting `cards`, append the `functionResponse` turn, continue until a text answer; final `{reply, cards, mood}` where `mood` comes from the model's JSON hint is NOT used — compute `mood` server-side: `gentle` if `context.sensitive`, else `question` if the reply ends with `?`, else `neutral`. `GeminiUnavailableError` → `HttpsError('unavailable', 'assistant_unavailable')`; `QuotaExceededError` → `HttpsError('resource-exhausted', 'daily_quota')`.
  - `aiChat.mjs`: `export const aiChat = onCall({region:'europe-west1', timeoutSeconds:60, secrets:[GEMINI_API_KEY]}, async (request) => ...)` — `request.auth` required else `HttpsError('unauthenticated')`; builds real deps (firebase-admin Firestore adapter, `generate`, `makeTools` from Task 7 via `createMakeTools`); keeps the secret value out of any log.

- [ ] **Step 1: Failing tests** (`node --test`): gemini — `returns first model answer`; `retries a 503 then succeeds`; `falls back to the next model after retries exhausted`; **`all models fail → unavailable error`**; `400 skips to next model without retry`; `timeout counts as retryable` (fetch that never resolves + `timeoutMs: 20` via `AbortController`); redflags — `fr bleeding`, `ar fetal movement`, `en newborn fever`, `normal sentence is null`; tier — `expired subscription is free`, `vip active`; quota — `increments then blocks at the limit`, `Algiers date key uses UTC+1`; handler — **`red flag skips model`** (generate spy never called, no quota consumed), `quota exceeded maps to resource-exhausted`, `tool loop executes functionCall and returns cards`, `loop stops after 4 rounds`, `history is passed to the model`, `message over 1000 chars rejected`, `question mark reply gives mood question`.
- [ ] **Step 2:** `cd functions && npm test` → FAIL. **Step 3:** implement (tools injected as a stub `{definitions: [], execute: async () => ({})}` in tests). **Step 4:** `cd functions && npm test` → PASS. **Step 5:** commit `feat(functions): add aiChat core with Gemini fallback, quota and red-flag guard`.

---

### Task 7: `aiChat` tools — context, schedule, products, weather, proposals

**Files:**
- Create: `functions/ai/tools.mjs`, `functions/ai/context.mjs`, `functions/ai/weather.mjs`, `functions/ai/wilayas.mjs`
- Modify: `functions/ai/aiChat.mjs` (wire `createMakeTools` and `loadContext`)
- Test: `functions/ai/tools.test.mjs`, `context.test.mjs`, `weather.test.mjs`

**Interfaces:**
- Consumes: Task 6 `handler.mjs` deps shape; Firestore layout from `CLAUDE.md` (users/{uid}, children, pregnancies, appointments, vaccinations, `marketplace_products`); Dart models for field names — read `lib/features/profile/models/profile_models.dart`, `pregnancy.dart`, `lib/features/health/models/appointment.dart`, the vaccine model under `lib/features/vaccines/models/`, and `MarketplaceProduct.fromFirestore` (including Task 5 fields).
- Produces:
  - `context.mjs`: `export async function loadContext({db, uid, now})` → `{stage, locale?, wilaya, tier, children:[{alias, ageMonths, expected:boolean}], pregnancy: {week, trimester, daysUntilDue}|null, sensitive:boolean}`; `stage` derived exactly like `deriveMotherStage` (6 values); `alias` = `enfant 1..n` ordered by birth date; **no names or dates**; `sensitive` = a pregnancy with `status == 'ended'` and `endedAt` within 90 days of `now`. Pure helper `deriveStage({bornChildren, hasActivePregnancy, tryingToConceive})` exported and tested.
  - `wilayas.mjs`: `export const WILAYA_COORDS = { "<wilaya name as stored in the app>": {lat, lon}, ... }` for all 58 wilayas (approximate centroids; find the exact spelling list the app stores — see the wilaya picker in `lib/features/profile/widgets/edit_dialogs.dart` or `edit_mother_profile_screen.dart`), plus `export function coordsFor(wilaya)` (case/diacritic-insensitive; default Alger `{lat:36.75, lon:3.06}`).
  - `weather.mjs`: `export async function getOutingWeather({wilaya, fetchImpl = fetch, now})` → `{summary, tempC, rainProbability, uvIndex, isGoodForOuting, advice}` from Open-Meteo (`https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&daily=temperature_2m_max,precipitation_probability_max,uv_index_max&current=temperature_2m&timezone=Africa%2FAlgiers&forecast_days=2`); `isGoodForOuting` = max temp 14–32 °C, rain probability < 40 %, uv < 8; `advice` mentions heat/UV precautions for babies when temp > 30 or uv ≥ 6. Failure ⇒ returns `{unavailable: true}` (never throws).
  - `tools.mjs`: `export function createMakeTools({db, fetchImpl})` → `makeTools({uid, context, locale})` → `{definitions, execute(name, args)}` — one instance **per request**, holding its own `returnedProductIds` Set; `definitions` is the Gemini `functionDeclarations` array for: `get_family_context` ({}), `list_health_schedule` ({childAlias?: string}) — upcoming/overdue vaccines and appointments for children (dates and titles, no names) read from Firestore, `search_products` ({ageMonths?: number, skill?: string, audience?: 'child'|'mother'|'pregnancy', trimester?: number, query?: string}) → up to 3 active products (`marketplace_products` where active) filtered with the Task 5 fields (fallback to `category`/`highlights` text match when the fields are absent), each `{productId, name, priceDZD, benefits:[…up to 3 strings: `benefitsAr|benefitsEn|benefitsFr` chosen by `locale`, falling back to `highlights` when that list is empty — same rule as the Dart `benefitsFor`], imageUrl?}`; it adds the returned ids to `returnedProductIds` and emits **no card**; `recommend_product` ({productId}) emits the product card **only if** `productId ∈ returnedProductIds`, with `why` = the first stored benefit string (never model text), else `{result:{error:'unknown_product'}}` and no card; `get_weather` ({}) using `context.wilaya`, `propose_album` ({kind:'predefined'|'standard', reason}), `propose_subscription` ({tier, benefit}), `propose_appointment` ({subject:'child'|'mother', childAlias?, title, suggestedDate?, reason}). `execute` returns `{result, card?}` and the handler collects `card`s; all `propose_*` tools just echo a card (they never write); if `context.sensitive`, `search_products` returns `{result:{products:[]}}`, and `recommend_product`, `propose_album` and `propose_subscription` return no card.
  - Card JSON shapes (must match Task 3 `AssistantCard.fromJson`): `{type:'product', productId, name, priceDZD, why, imageUrl?}`, `{type:'appointment', subject, childAlias?, title, suggestedDate?, reason}`, `{type:'album', albumKind, title, reason}`, `{type:'subscription', tier, benefit}`, `{type:'weather', summary, tempC, outingIdea}`.

- [ ] **Step 1: Failing tests:** context — `aliases hide names and dates`, `expected child flagged`, `stage D when pregnant with children`, **`sensitive when pregnancy ended 30 days ago, not 120 days ago`**; weather — `maps open-meteo payload to advice`, `hot day adds baby heat advice`, `network failure returns unavailable`, `coordsFor is accent-insensitive and defaults to Alger`; tools — `search_products filters by age and skill`, `falls back to highlights when benefits missing`, **`unknown product id is dropped`** (`recommend_product` with an id `search_products` never returned ⇒ no card), **`why comes from stored benefits`** (the card's `why` equals the product's first stored benefit, even if `args` carries other text), `recommend_product after search emits the card`, **`sensitive period strips commercial cards`** (`search_products` empty, product/album/subscription cards absent, weather card still allowed), `propose_* never touch the db` (db spy), `list_health_schedule returns overdue vaccines without names`, `weather tool returns a weather card`. Use an in-memory fake `db` object implementing only what the code calls.
- [ ] **Step 2:** FAIL. **Step 3:** implement, wire into `aiChat.mjs`. **Step 4:** `cd functions && npm test` → PASS. **Step 5:** commit `feat(functions): add assistant tools (context, schedule, products, weather, proposals)`.

---

### Task 8: Flutter real backend (callable) + wiring

**Files:**
- Modify: `pubspec.yaml` (`flutter pub add cloud_functions` — version resolved by pub against the existing `firebase_core ^3.12.1`), `lib/features/assistant/providers/assistant_providers.dart`
- Create: `lib/features/assistant/services/gemini_assistant_backend.dart`
- Test: `test/gemini_assistant_backend_test.dart`

**Interfaces:**
- Consumes: Task 3 `AssistantBackend`, `AssistantReply`, `AssistantException`, `AssistantCard.tryParse`.
- Produces:
  - `typedef CallableInvoker = Future<Map<String, dynamic>> Function(Map<String, dynamic> payload);`
  - `class GeminiAssistantBackend implements AssistantBackend { GeminiAssistantBackend({CallableInvoker? invoke}) }` — default invoker calls `FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('aiChat', options: HttpsCallableOptions(timeout: const Duration(seconds: 65)))` with payload `{message, locale, history:[{role, text}...]}` and returns the result map; parses `{reply, cards, mood}` (unknown cards skipped via `tryParse`; unknown mood ⇒ neutral); maps `FirebaseFunctionsException.code`: `resource-exhausted`→`quota`, `unavailable`/`deadline-exceeded`→`unavailable`, `unauthenticated`→`unauthenticated`, `unknown` with network errors (`SocketException`/`TimeoutException`)→`network`, else `unknown`.
  - `assistantBackendProvider` now returns `GeminiAssistantBackend()` unless a dart-define `ASSISTANT_FAKE=true` is set (`const bool.fromEnvironment('ASSISTANT_FAKE')`) ⇒ `FakeAssistantBackend()` (for demos without a deployed function).

- [ ] **Step 1: Failing tests** (inject `invoke`): `parses reply and every card type`; `skips unknown cards`; `unknown mood becomes neutral`; **`unavailable maps to friendly message`** — a thrown `FirebaseFunctionsException(code: 'unavailable', message: 'x')` ⇒ `AssistantException(kind: unavailable)` and, through `AssistantController`, an error message with key `assistantErrorBusy` and bird `confused`; `resource-exhausted maps to quota` (controller ⇒ `assistantErrorQuota`, bird `gentle`); `sends history without errors and the locale`; `network failure maps to network`.
- [ ] **Step 2:** FAIL. **Step 3:** implement; `flutter pub get`. **Step 4:** `flutter test` → PASS, then `flutter analyze` → No issues. **Step 5:** commit `feat(assistant): call the aiChat function from the app`.

---

### Task 9: Close tickets (CLAUDE.md workflow)

- [ ] For LM2-149, 150, 151, 152, 155: issue `**Statut**` → `✅ Terminé` (LM2-155 only if the weather tool shipped in Task 7 — it did); TASKS.md rows ✅ and counters; client reports `docs/reports/rapport_client_2026-10-22_LM2-XXX.md` in the exact CLAUDE.md structure (French, plain language), linked on the `> Rapports :` line. In LM2-152's report add "Déploiement : ⏳ À faire — secret `GEMINI_API_KEY` et `firebase deploy --only functions:aiChat` (plan Blaze requis)". In LM2-151/150 add "Vérification manuelle sur téléphone : ⏳ À faire".
- [ ] Commit `docs(reports): LM2-149/150/151/152/155 client reports`.
