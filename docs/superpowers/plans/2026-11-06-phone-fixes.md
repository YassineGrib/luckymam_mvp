# Phone testing fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Resolve the numbered phone-testing findings and replace the active manual guide with focused retests.

**Architecture:** Keep Flutter/Riverpod/Firebase boundaries. Preserve stored capsule compatibility while presenting a unified emotion selection. Split independent implementation scopes across capsules/onboarding, albums/orders, reels, and slideshow/logging integration.

**Tech Stack:** Flutter, Dart, Riverpod, Firebase, share_plus, video_player.

**Spec:** FIXING.md and reports/manual-testing/2026-11-06-*.md; latest user decisions in FIXING.md override original testing guide.

## Global Constraints

- Capsule photo is mandatory. Crop/replacement/prices accepted; do not independently retest these.
- Unified emotions: minimum three, no primary/secondary labels. Preserve existing persisted compatibility.
- Remove PDF preview UI; retain print-order internals as needed.
- No emoji in app UI. Use existing logo and icons, no new dependencies.
- Free album max six. French UI stays French. Keep user's existing changes untouched.

## Review Focus

- A recorded clip must not silently disappear at capsule save.
- End-card buttons must receive taps above navigation zones.
- Video initialization failure/offline must terminate loading with retry.
- Videos must stop when the route or app is inactive.
- Raw nested log context and URLs must not expose sensitive values.

## Task 1 — Capsules, onboarding and global icon pass

- [x] Fix audio ownership/validation and visible controls in create_capsule_screen.dart and audio_recorder.dart; regression tests for saved audio and controls.
- [x] Replace emotion_picker.dart presentation with unified selection, validate minimum three in create screen while retaining stored fields.
- [x] Add mother-status instructions and improve language selection clarity using existing patterns.
- [x] Replace visible emoji renderers and literals in this scope; report remaining sites for integration.

## Task 2 — Albums and orders

- [x] Fix template badges and headers, existing-photo-first picker, cover and locale consistency, Livre-only preview.
- [x] Remove order badge, improve success icon and verify official wilaya source before updating data.
- [x] Preserve accepted photo/crop/pricing behavior and six-photo free-album limit; test affected behavior.

## Task 3 — Reels

- [x] Implement share/save actions and locale-dependent content with existing data compatibility.
- [x] Add bounded initialization/retry and lifecycle/route stopping; move large watermark above scrim bottom left.
- [x] Test parsing/action state and failure behavior; inspect existing ad/video route use.

## Task 4 — Slideshow, comparison and logs

- [x] Add minimum-three hint; redesign covers/end and photo captions, fix hit testing/share; regression test tap interactions.
- [x] Remove recommended badge only in comparison.
- [x] Add recursive log sanitizer and replace raw logging paths; test nested email/phone/url/token data.

## Task 5 — Integration and retesting

- [x] Generate localizations, format changed Dart, run analyze and focused/full tests as warranted.
- [x] Review task diffs and resolve meaningful findings; independent final review.
- [x] Update FIXING.md statuses/evidence and replace MANUAL_TESTING_TASKS.md with only changed behavior, archived original preserved.
- [x] Report build/test limitations and provide updated APK.
- [ ] Phone acceptance: user installs updated APK, then runs the focused manual checklist.
