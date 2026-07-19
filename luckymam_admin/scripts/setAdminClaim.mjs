#!/usr/bin/env node
// One-off, local-only script to grant the `admin` custom claim to a Firebase
// Auth user. Never deployed, never run automatically — a developer runs this
// by hand once per new admin.
//
// Setup:
//   1. Firebase Console → luckymam-app-dv → Project settings → Service accounts
//      → "Generate new private key" → save as scripts/service-account.json
//      (gitignored — never commit this file)
//   2. npm run set-admin-claim -- <uid> [role]
//
// The uid is the target user's Firebase Auth UID (Console → Authentication →
// Users), NOT their email. `role` defaults to "admin" (used by later RBAC
// phases; ignored by today's isAdmin() rule, which only checks `admin: true`).
//
// The granted claim only appears in the user's ID token after they sign out
// and back in (or the app forces a token refresh) — this is a Firebase
// platform behavior, not a bug in this script.

import { readFileSync, existsSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, join } from 'node:path'
import admin from 'firebase-admin'

const __dirname = dirname(fileURLToPath(import.meta.url))
const serviceAccountPath = join(__dirname, 'service-account.json')

if (!existsSync(serviceAccountPath)) {
  console.error(
    `Missing ${serviceAccountPath}.\n` +
      'Download it from Firebase Console → Project settings → Service accounts ' +
      '→ "Generate new private key", and save it at that exact path.',
  )
  process.exit(1)
}

const [uid, role = 'admin'] = process.argv.slice(2)

if (!uid) {
  console.error('Usage: npm run set-admin-claim -- <uid> [role]')
  console.error('Find the uid in Firebase Console → Authentication → Users.')
  process.exit(1)
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'))
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) })

try {
  const user = await admin.auth().getUser(uid)
  await admin.auth().setCustomUserClaims(uid, { admin: true, role })
  console.log(`✓ Granted admin claim (role="${role}") to ${user.email ?? uid}`)
  console.log('  This user must sign out and back in for it to take effect.')
} catch (err) {
  console.error('Failed to set custom claim:', err.message)
  process.exit(1)
}
