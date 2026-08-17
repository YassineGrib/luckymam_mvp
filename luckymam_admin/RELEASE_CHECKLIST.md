# Luckymam Admin — Release Checklist

Checklist for taking the admin dashboard from dev to production.  
Last audited: **2026-08-16**

---

## Phase 1 — Infrastructure & deploy (must fix before release)

| # | Item | Status | Notes |
|---|------|--------|-------|
| 1.1 | Production build passes | ✅ | `npm run build` succeeds |
| 1.2 | Build output path matches Firebase Hosting | ❌ | Build outputs to `.output/public/` but `firebase.json` points to `luckymam_admin/dist` (folder missing) |
| 1.3 | Firebase Hosting target configured | ❌ | `.firebaserc` has `"targets": {}` — run `firebase hosting:sites:create luckymam-admin` + `firebase target:apply hosting admin luckymam-admin` |
| 1.4 | `.env.local` with Firebase Web config | ✅ | File exists (required for dev/prod builds) |
| 1.5 | Firebase Web App registered | ⚠️ | `.env.local` exists → likely done; confirm `VITE_FIREBASE_API_KEY` and `VITE_FIREBASE_APP_ID` are filled |
| 1.6 | Deploy Firestore rules | ⚠️ | Rules look correct (`isAdmin()`); run `firebase deploy --only firestore:rules --project luckymam-app-dv` |
| 1.7 | Deploy Storage rules | ❌ | Missing `products/` path — marketplace image uploads use `products/` but rules only allow `/reels/` |
| 1.8 | `service-account.json` not in git | ❌ | **Tracked in git** — rotate key and add to `.gitignore` |
| 1.9 | Admin user + custom claim | ⚠️ | Script exists at `scripts/setAdminClaim.mjs` but `npm run set-admin-claim` is missing from `package.json` |

### Phase 1 commands

```bash
# From luckymam_admin/
cp .env.example .env.local   # if not already done
npm run build

# From repo root — one-time hosting setup
firebase hosting:sites:create luckymam-admin --project luckymam-app-dv
firebase target:apply hosting admin luckymam-admin --project luckymam-app-dv

# Deploy rules + hosting (after fixing paths in firebase.json)
firebase deploy --only firestore:rules,storage --project luckymam-app-dv
firebase deploy --only hosting:admin --project luckymam-app-dv
```

---

## Phase 2 — Security & auth

| # | Item | Status | Notes |
|---|------|--------|-------|
| 2.1 | Admin-only route guard | ✅ | `AuthProvider` + `AuthGuard` check `admin` custom claim |
| 2.2 | Non-admin sign-in blocked | ✅ | Login page rejects accounts without `admin: true` |
| 2.3 | Firestore admin boundary | ✅ | `isAdmin()` on all backoffice collections in `firestore.rules` |
| 2.4 | Storage admin write for reels | ✅ | `/reels/{fileName}` — admin write, public read |
| 2.5 | Storage admin write for products | ❌ | No rule for `/products/` — image uploads will fail in prod |
| 2.6 | Secrets not committed | ❌ | `scripts/service-account.json` is tracked in git |

### Storage rule to add (root `storage.rules`)

```javascript
match /products/{fileName} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.token.admin == true;
}
```

---

## Phase 3 — Feature completeness (all pages live)

Mock files (`src/data/*.mock.ts`) are still imported for **types and constants only** — live data comes from Firestore. That is acceptable for release.

| # | Page | Route | Firestore wired | Status |
|---|------|-------|-----------------|--------|
| 3.1 | Overview | `/` | ✅ | Real-time KPIs from Firestore |
| 3.2 | Marketplace Catalog | `/marketplace-catalog` | ✅ | CRUD + image upload |
| 3.3 | Inventory | `/marketplace-inventory` | ✅ | Live stock updates |
| 3.4 | Marketplace Orders | `/marketplace-orders` | ✅ | Status machine + stock restore on cancel |
| 3.5 | Print Orders | `/print-orders` | ✅ | Includes album claims |
| 3.6 | Reels Catalog | `/reels-catalog` | ✅ | Upload + validation (15 MB / 60 s) |
| 3.7 | Notifications | `/notifications` | ✅ | Create + list |
| 3.8 | Users | `/users` | ✅ | Subscription + children subcollection |
| 3.9 | Settings | `/settings` | ✅ | Global settings doc |
| 3.10 | Login | `/login` | ⚠️ | Works, but has placeholder UI (see Phase 5) |

---

## Phase 4 — Code quality

| # | Item | Status | Notes |
|---|------|--------|-------|
| 4.1 | ESLint clean | ❌ | ~734 issues (mostly Prettier formatting); run `npm run format` then `npm run lint` |
| 4.2 | Bundle size | ⚠️ | `users` chunk ~614 KB — consider code-splitting |
| 4.3 | Dead code cleanup | ⚠️ | Old overview components (`KpiHero`, `RevenueChart`, etc.) still use mock data but are not used by `/` |

---

## Phase 5 — UX / polish (should fix)

| # | Item | Status |
|---|------|--------|
| 5.1 | Login “Google Workspace” button | ❌ Non-functional |
| 5.2 | Login “2FA protected” badge | ❌ Misleading — no 2FA implemented |
| 5.3 | Login fake stats (12.4k users, 99.9%) | ❌ Hardcoded marketing numbers |
| 5.4 | “Forgot password” link | ❌ No handler |
| 5.5 | i18n (AR / FR / EN) | ✅ Present across pages |

---

## Phase 6 — Manual QA (before go-live)

| # | Test | Status |
|---|------|--------|
| 6.1 | Admin login with real account | ⬜ |
| 6.2 | Create / edit / archive product + image upload | ⬜ |
| 6.3 | Update order status (marketplace + print) | ⬜ |
| 6.4 | Upload reel video | ⬜ |
| 6.5 | Send notification | ⬜ |
| 6.6 | Change user subscription tier | ⬜ |
| 6.7 | End-to-end deploy to Firebase Hosting | ⬜ |

---

## Critical blockers (fix first)

1. **Deploy path mismatch** — `firebase.json` expects `dist`, build produces `.output/public`
2. **Hosting target not configured** — empty `.firebaserc` targets
3. **Storage rules** — add `/products/{fileName}` for marketplace image uploads
4. **Secrets in git** — remove, gitignore, and rotate `service-account.json`
5. **Lint** — run formatter before release

---

## Recommended fix order

```
1. Fix firebase.json output path (+ .firebaserc hosting target)
2. Add products/ to storage.rules and deploy rules
3. Remove service-account.json from git, add to .gitignore, rotate key
4. Add set-admin-claim script to package.json
5. Run npm run format && npm run lint
6. Clean login placeholders (Google / 2FA / fake stats)
7. Manual QA on http://localhost:8080
8. firebase deploy --only hosting:admin,firestore:rules,storage
```

---

## Status legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done / verified |
| ❌ | Blocker or failed |
| ⚠️ | Partial / needs confirmation |
| ⬜ | Not yet tested |

---

## Related docs

- [`README.md`](./README.md) — setup and first admin account
- [`DOCUMENTATION.md`](./DOCUMENTATION.md) — architecture and data model
- [`DASHBOARD_SPEC.md`](./DASHBOARD_SPEC.md) — feature specifications
- Root [`firestore.rules`](../firestore.rules) and [`storage.rules`](../storage.rules)
