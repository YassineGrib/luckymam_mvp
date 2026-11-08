// Generic connectivity check. --authenticated creates a disposable test login,
// calls the deployed function, then removes that login and its quota document.
// Never prints keys, ID tokens, passwords or user conversation data.
import { readFileSync } from 'node:fs';
import { randomBytes } from 'node:crypto';
import { spawnSync } from 'node:child_process';

const endpoint = 'https://europe-west1-luckymam-app-dv.cloudfunctions.net/aiChat';
const project = 'luckymam-app-dv';
const source = readFileSync(new URL('../lib/firebase_options.dart', import.meta.url), 'utf8');
const publicFirebaseKey = source.match(/static const FirebaseOptions web = FirebaseOptions\([\s\S]*?apiKey: '([^']+)'/)?.[1];
if (!publicFirebaseKey) throw new Error('Firebase web configuration not found');

async function post(url, data, token) {
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify(data),
    signal: AbortSignal.timeout(65000),
  });
  return { status: response.status, body: await response.json().catch(() => ({})) };
}

const payload = { data: { message: 'Hello. Please reply with one short greeting without using tools.', locale: 'en', history: [] } };
if (process.argv.includes('--mobile-history')) {
  payload.data.locale = 'fr';
  payload.data.message = 'Bonjour, présente-toi en une phrase courte.';
  payload.data.history = [{ role: 'user', text: payload.data.message }];
}
if (process.argv.includes('--tool-roundtrip')) {
  payload.data.locale = 'fr';
  payload.data.message = 'Appelle get_family_context, puis présente-toi brièvement.';
  payload.data.history = process.argv.includes('--mobile-history')
    ? [{ role: 'user', text: payload.data.message }] : [];
}
const unauthenticated = await post(endpoint, payload);
console.log(JSON.stringify({ check: 'authentication', httpStatus: unauthenticated.status, error: unauthenticated.body.error?.status }));
if (unauthenticated.status !== 401 || unauthenticated.body.error?.status !== 'UNAUTHENTICATED') process.exit(1);

if (process.argv.includes('--authenticated')) {
  if (!process.env.LUCKYMAM_FIREBASE_ENTRY) throw new Error('Firebase CLI entry required for test quota cleanup');
  const email = `ai-smoke-${randomBytes(12).toString('hex')}@example.invalid`;
  const password = `Aa1!${randomBytes(24).toString('base64url')}`;
  const created = await post(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${publicFirebaseKey}`, { email, password, returnSecureToken: true });
  const { idToken, localId } = created.body;
  if (created.status !== 200 || !idToken || !localId) {
    console.log(JSON.stringify({ check: 'test-login', httpStatus: created.status, error: created.body.error?.message }));
    process.exit(1);
  }
  let failed = false;
  try {
    const response = await post(endpoint, payload, idToken);
    const result = response.body.result ?? response.body.data;
    const hasReply = typeof result?.reply === 'string' && result.reply.trim().length > 0;
    console.log(JSON.stringify({ check: 'authenticated-chat', httpStatus: response.status, hasReply, replyLength: result?.reply?.length, error: response.body.error?.status }));
    failed = response.status !== 200 || !hasReply;
  } finally {
    const date = new Intl.DateTimeFormat('en-CA', { timeZone: 'Africa/Algiers', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());
    const cleaned = spawnSync(process.execPath, [process.env.LUCKYMAM_FIREBASE_ENTRY, 'firestore:delete', `users/${localId}/aiUsage/${date}`, '--project', project, '--force', '--non-interactive'], { encoding: 'utf8', timeout: 60000, env: { ...process.env, CI: 'true' } });
    const removed = await post(`https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${publicFirebaseKey}`, { idToken });
    const cleanupOk = cleaned.status === 0 && removed.status === 200;
    console.log(JSON.stringify({ check: 'cleanup', quotaRemoved: cleaned.status === 0, testLoginRemoved: removed.status === 200 }));
    if (!cleanupOk) failed = true;
  }
  if (failed) process.exit(1);
}
