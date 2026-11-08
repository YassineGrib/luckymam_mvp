# Capsules/onboarding and reels review

Read-only source review of `review-capsules-reels.diff`, current implementations, and new reels files against FIX-001–007 and FIX-024–028. No tests run; no application source changed. Device behavior is not certified by this review.

## Important findings

1. **FIX-005: the primary/secondary hierarchy remains visible after saving.** `lib/features/capsules/screens/capsule_detail_screen.dart:301–344` renders the first selected emotion as a large 32px icon and bold 18px heading, then renders all remaining emotions separately as small chips. Trigger: choose three emotions in the new unified picker, save, and open the capsule. The arbitrary first click is still promoted to a main emotion in the user-facing details. This misses the explicit final requirement that the old data split must not be exposed to users. Render the combined deduplicated emotions uniformly in details (and audit other capsule presentations).

2. **FIX-024: playback buffering has no timeout or recovery UI.** `lib/features/reels/widgets/reel_player.dart:89` limits only `initialize()`, while `_onVideoChanged` at lines 109–117 reacts only to `hasError`. Trigger: initialize a network reel successfully, then lose connectivity before the next unbuffered portion; native playback can remain buffering without reporting an error. `_initialized` stays true indefinitely, leaving a frozen frame with no explanation or Retry button. Observe buffering/progress stalls, bound the wait, and expose the existing retry state when playback cannot continue.

3. **Recorded drafts can still be silently discarded on Back.** `lib/features/capsules/screens/create_capsule_screen.dart:450` immediately pops, with no PopScope/draft guard; `dispose` at lines 116–121 now deletes every completed local recording when not saving. Trigger: record a valid clip and press the app back arrow or system Back before saving. The screen exits and the recording is deleted without warning or recovery. Add a common leave/discard guard for both navigation paths, preserving the draft until discard is explicit. This is a missed quality requirement from the review brief, independent of the successful removal of separate audio validation.

## Separate verdicts

- **Capsules/onboarding spec:** Language selection now exposes a selected option and Continue; mother status gives actionable child guidance; completed audio is attached without a hidden confirmation; delete/re-record remain available; photo and minimum-three validation are enforced. Existing four-emotion capacity is preserved. FIX-005 is incomplete because details still expose the hierarchy.
- **Capsules/onboarding quality:** Changes are not ready to call fully complete because recorded drafts still disappear on navigation. Audio uploads propagate failures through the service/provider rather than saving a successful capsule without its clip; persistence/playback after reopening still needs the planned device check.
- **Reels spec:** Watermark is above the scrim; localized fields and legacy translations are wired; sharing uses share_plus and saving uses Gal with progress/success/error feedback; app lifecycle and route visibility gate playback. FIX-024 remains incomplete for stalls after initialization.
- **Reels quality:** Important network recovery gap above. Native gallery/share-sheet and lock-screen/route pause require device verification; no unsupported claim of passing them is made here.

No Critical findings identified by this source review.
