# Keystore & SHA Fingerprints

## Debug Keystore

**Path:** `~/.android/debug.keystore`  
**Alias:** `androiddebugkey`  
**Password:** `android`  
**Valid until:** 2056-03-04

| Hash   | Value |
|--------|-------|
| SHA-1  | `BC:21:DC:32:18:C0:B3:0F:9F:3A:3B:34:07:85:46:12:4B:75:13:83` |
| SHA-256 | `35:9D:1F:73:1D:4D:3B:AD:06:62:EC:EC:D5:83:CF:5E:A9:23:33:DE:BA:87:6E:C3:3E:DD:8C:76:A4:B6:EB:68` |

> Add the SHA-1 above to **Firebase Console → Project Settings → Your Android app (`com.luckmam.luckmam_mvp`) → SHA certificate fingerprints**, then re-download `google-services.json`.

---

## Release Keystore (Local Upload Key)

**Path:** `android/luckymam-release.keystore`  
**Alias:** `luckymam`  
**Config:** `android/key.properties`

| Hash | Value |
|------|-------|
| SHA-1 | `A3:3B:F0:F9:43:51:D2:9E:5B:9E:B3:BD:29:E6:AE:3D:E3:E4:FB:CC` |
| SHA-256 | `8B:4D:28:B9:D8:37:A8:0B:6C:A8:04:4E:EC:B2:69:7A:27:DC:25:27:84:27:21:D9:43:5C:72:E7:E5:69:B9:01` |

---

## Google Play App Signing (Production Key for Play Store)

When uploaded to Google Play, Google re-signs the APK using Play App Signing.
To make Google Sign-In work in production:

1. Open **Google Play Console** → Your App (**LuckyMam**).
2. Go to **Release** → **Setup** → **App integrity** → **App signing** tab.
3. Under **App signing key certificate**, copy the **SHA-1** (and SHA-256).
4. Go to **Firebase Console** → Project Settings → Android App (`com.luckmam.luckmam_mvp`) → **SHA certificate fingerprints**.
5. Add BOTH:
   - The **App signing key certificate SHA-1** (from Play Console).
   - The **Upload key certificate SHA-1** (`A3:3B:F0:F9:43:51:D2:9E:5B:9E:B3:BD:29:E6:AE:3D:E3:E4:FB:CC`).
6. Download the updated `google-services.json` and place it in `android/app/google-services.json`.

---

## How to regenerate fingerprints at any time

```bash
# Debug
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
  -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android

# Release (once keystore exists)
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
  -list -v \
  -keystore ~/luckymam_release.keystore \
  -alias luckymam
```
