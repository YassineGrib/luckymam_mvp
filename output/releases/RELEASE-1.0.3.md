# LuckyMam - Google Play delivery

- Date: 2026-11-07.
- Version: 1.0.3.
- Android versionCode: 4 (previous local release: 3).
- Package: com.luckmam.luckmam_mvp.
- Release file: `LuckyMam-1.0.3-build4.aab`.
- Size: 91,867,087 bytes.
- SHA256: `E594178B2DC7CB4A178E20C6DF626997B51A7951DF2FC9D4AA8AAECAA4C71088`.
- Signing certificate SHA256: `8B4D28B9D837A80B6CA8044EECB2697A27DC2527842721D9435C72E7E569B901`.
- Minimum Android SDK: 24. Target Android SDK: 36.

## Verification

- Flutter release App Bundle build succeeded (exit 0).
- JAR signature verification succeeded; the certificate matches the existing local release certificate. The verifier reports the expected self-signed-certificate trust warning.
- Parsed the actual bundle manifest using Android's AAPT protobuf classes: package, versionName, versionCode and SDK values match the release above; bundle config present; application not marked debuggable.
- PDF report: one A4 page, rendered and visually reviewed; version and validation details checked by text extraction.
- Version metadata and the bundle-build option are the only application/build-script changes for this packaging step. No product behavior changed after the final phone-test round.

## Delivery

- Upload the AAB through the intended release track in Google Play Console.
- French release notes: `Google-Play-release-notes-fr.txt` (396 characters).
- Client report: `../pdf/LuckyMam_Rapport_Client_1.0.3_2026-11-07.pdf`.
- This delivery does not upload, publish or obtain Google Play approval. Play Console's currently used version codes and upload-certificate settings were not inspected.

## Evidence

- `../../reports/manual-testing/play-release-1.0.3-build.log`
- `../../reports/manual-testing/play-release-1.0.3-signature.log`
- `../../reports/manual-testing/play-release-1.0.3-manifest.log`
