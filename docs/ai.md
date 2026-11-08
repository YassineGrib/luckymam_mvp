# AI chat configuration

Production chat uses the authenticated Firebase callable `aiChat` in `europe-west1`.
The provider key belongs only in Firebase Secret Manager as `GEMINI_API_KEY`.
Do not put it in Flutter source, dart-defines, documentation or a chat message.

## Setup

1. Create or obtain a Gemini API key in Google AI Studio: https://aistudio.google.com/api-keys .
2. In your terminal, run `firebase functions:secrets:set GEMINI_API_KEY --project luckymam-app-dv` and paste the key into the masked CLI prompt.
3. Tell the maintainer the secret has been saved; the value is not needed in chat.
4. Validate the credential with a generic request, then deploy only `admin:aiChat` after backend tests: `firebase deploy --only functions:admin:aiChat --project luckymam-app-dv`.
5. Rebuild/install the app to use the callable by default; sign in and test a generic greeting.

Do not redeploy all functions or hosting for this change. No fake/demo response is used in production.

## Confirmed failure on 2026-11-07

- Previous app default selected the direct client with a bundled credential.
- Both configured provider models returned HTTP401 / UNAUTHENTICATED with ACCESS_TOKEN_TYPE_UNSUPPORTED.
- Firebase inventory had only adminSsr, chargilyWebhook and createChargilyCheckout; aiChat was absent.
- Public callable URL returned404 and Secret Manager returned404 for GEMINI_API_KEY.
- The bundled credential has been removed from source and this document. Live service acceptance remains pending until a valid server key is configured and aiChat is deployed.

## Server tool-response correction

The first phone test exposed a provider protocol error that a plain greeting did not exercise. Function-response parts must use role:user, not role:function. This is corrected, regression tested and deployed. A real provider tool call and an authenticated deployed tool request now both succeed. Keep forced-tool and mobile-history coverage when validating future changes; a greeting-only smoke check is insufficient.
