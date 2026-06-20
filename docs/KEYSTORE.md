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

## Release Keystore

No release keystore has been created yet. To generate one:

```bash
keytool -genkey -v \
  -keystore ~/luckymam_release.keystore \
  -alias luckymam \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Then create `android/key.properties`:

```
storeFile=/Users/<you>/luckymam_release.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=luckymam
keyPassword=YOUR_KEY_PASSWORD
```

Get the release SHA-1 after creating the keystore:

```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
  -list -v \
  -keystore ~/luckymam_release.keystore \
  -alias luckymam
```

> Add the release SHA-1 to Firebase Console as well, under the same Android app entry.

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
