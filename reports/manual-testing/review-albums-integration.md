# Album and integration review

Read-only source review of `review-albums-integration.diff`, current source including `safe_log.dart`, and FIX-008–023 / FIX-029. No tests or UI runs were performed or repeated. Official 69-wilaya mapping and JO 40 (3 June 2026), p.5 verification were supplied by the coordinating agent; this review does not re-assert an independent source check.

## Material findings

### [P2] String logging bypasses sensitive-field redaction

`lib/core/services/safe_log.dart:15–18,31–32` and `lib/core/services/notification_service.dart:70`.

`safeDebugPrint` receives an already interpolated string and calls only `SafeLog.text`; that function removes email addresses, URLs and matching phones, but never applies `_sensitiveKey`. A notification payload such as `{"token":"abc-secret","nested":{"password":"pass123"}}` therefore appears verbatim in debug output when the notification is tapped. Similarly, `AnalyticsService.logTechnicalError(rawMessage: 'Authorization: Bearer abc-secret', ...)` persists that credential in Firestore through `analytics_service.dart:81,87` because the surrounding key is `message`. Recursive map sanitization cannot recover field boundaries after interpolation. FIX-029 is incomplete. Redact/omit payloads at their call sites and define credential handling for raw message strings before claiming a universal logging boundary.

### [P2] French album confirmation dialogs still display English

`lib/features/memory_book/screens/standard_album_detail_screen.dart:1407–1426,1690–1712`.

With French selected, clear a populated page or delete a standard album. Both dialogs branch only on Arabic and show English titles, explanations and destructive action labels (`Clear Page`, `Remove`, `Delete Album`, `Delete`). These are existing omissions left by this task, rather than new regressions. FIX-012 requires all text in the French album path to be French; its acceptance criterion is not met. Use localized resources for these remaining dialogs (also the Clear tooltip at line 1940).

### [P2] Existing free albums bypass the new six-page maximum

`lib/features/memory_book/models/standard_album.dart:44`.

The new maximum is enforced on create/update/add operations, but Firestore loading still accepts the persisted `pageCount` unchanged. An album created before this patch with 12/24 pages opens with all those pages, and the editor and print preparation continue iterating `album.pageCount`. Thus max-six is enforced only for newly modified capacity, rather than existing free albums. Define and implement legacy handling (without silently discarding memories) if the requested maximum applies to all free albums. This is a gap in the new limit implementation, not a claim that data should be truncated.

## Album task verdict

**Spec compliance: changes requested.** The source implements the bounded slideshow header, removes the full-screen navigation hit layer at the end, provides one share action within the end content, retains header exit, removes the PDF preview path while keeping order navigation, adds existing-photo lists and secondary capture, removes the comparison recommendation badge, and constrains new free-album capacity. French confirmations and legacy capacity remain incomplete as above. Modern cover quality, narrow-phone layout and actual native-share behavior require the coordinating agent's UI evidence; source inspection alone cannot certify them. The share implementation opens native sharing with localized promotional text only, matching its previous payload; it does not export slides or a playable link. Whether a media export is required is outside the supplied explicit native-share acceptance criterion.

**Code quality: changes requested.** Shared photo-list extraction and transaction-based page increments are reasonable. No additional album correctness regression was established by this review beyond the capacity gap. The remaining manual language branches are the concrete source of incomplete localization.

## Integration task verdict

**Spec compliance: changes requested.** Recursive Map/Iterable sanitization and removal of raw response bodies/FCM tokens are improvements, but FIX-029 still leaks arbitrary credential-bearing strings/payloads through the advertised safe output boundary.

**Code quality: changes requested.** A string-only output API named `safeDebugPrint` makes unsafe interpolation appear protected. Preserve structured fields until sanitization or explicitly suppress opaque payloads; keep raw-message credential rules and their limitations explicit. No tests were run by this reviewer; use the coordinating agent's verification results separately.
