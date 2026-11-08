# Capsules, onboarding and mother-status implementation

Implemented scope: FIX-001 to FIX-005 and visible emotion icons in capsule/details profile cards (FIX-006 partial global scope). Phone retesting is still required; no manual pass claimed.

Files changed:
- lib/features/capsules/widgets/emotion_picker.dart: one selectable emotion-chip group; at least three explained in Arabic, English and French; retains four-emotion storage capacity, fifth selection disabled.
- lib/features/capsules/screens/create_capsule_screen.dart: minimum three unique emotions gates save; maps unified selection to existing emotion/secondaryEmotions fields; mandatory photo preserved. Valid recorded file automatically included on create/update, independently of the old confirmation state. Missing/empty recordings produce a visible save error rather than silent omission. Preview remains visible with rerecord/delete callbacks. Discarded screen recordings are cleaned up when no upload is active.
- lib/features/capsules/widgets/audio_recorder.dart: new recordings default to ready; visible labeled delete and rerecord buttons wrap at narrow widths; guards recording startup/release and duplicate stop races; saveability helper used by save path.
- lib/features/capsules/screens/capsule_detail_screen.dart: secondary-emotion glyphs replaced by Material icons.
- lib/features/profile/child_profile_screen.dart: capsule emotion glyph replaced by Material icon.
- lib/features/profile/edit_mother_profile_screen.dart: adds official JO40 June3 2026 codes 59–69 to existing bilingual selector, coordinated with parent/album task; explains that adding a born child activates Mother status; blocks Mother save with no born child before any writes or false success; removes literal decorative emoji in success/pregnancy guidance.
- lib/features/onboarding/language_selection_screen.dart: replaces hardcoded French step text with selected language native name; adds selected/button semantics to language cards; preserves visible selection and localized continue action/RTL navigation.
- test/capsule_audio_preview_test.dart: automatic-ready preview regression; helper checks valid, missing and empty files; existing explicit-confirmation compatibility tests retained.
- test/capsule_unified_emotion_test.dart: chips select three together; fourth fits existing persistence capacity; fifth disabled; deselection reopens capacity.

Verification:
- Bundled dart.exe format completed successfully for all changed Dart/test files.
- Direct dart analyze completed with no errors/warnings; six informational lints. Four owned-file lints were corrected afterwards (unneeded services import, null-aware elements, mounted check). Two existing image_crop_screen.dart informational lints remain outside this change. Parent coordinates final escalated analysis and Flutter test batch.
- No phone/device retest or Firebase upload/playback integration performed here.

Remaining integration checks:
- Parent runs focused tests (capsule_audio_preview_test.dart, capsule_unified_emotion_test.dart, capsule_multi_emotion_and_thumbnail_test.dart, capsule_subjects_test.dart) and analysis before marking task DONE.
- Parent owns global localization emoji cleanup and other UI domains. Legacy emoji model getters remain for compatibility and do not render in this scope.
- Device verifies record -> save -> reopen -> playback, replacement/deletion, three-emotion validation, selected language/RTL, and Mother guidance followed by child addition.

Deviation/ruling: persisted service caps secondary emotions at three, so unified selection retains four total maximum as explicitly permitted by FIXING.md; no persistence migration introduced. Localized scoped strings used for new instructions without editing generated localization files.
