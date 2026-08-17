

ll;jl;jl-pljlj
# Luckymam Web Landing Page — Release Checklist

Checklist for taking the **public marketing site** (`luckymam_web/`) to production.

> **Scope:** This covers the React/Vite landing page only — **not** the Flutter mobile app and **not** the admin backoffice (`luckymam_admin/`).  
> Last audited: **2026-08-16**

---

## What this project is

| Project | Role |
|---------|------|
| `luckymam_web/` | Public landing page — APK download, vaccine calculator, product showcase |
| `luckymam_admin/` | Private admin dashboard (see [`../luckymam_admin/RELEASE_CHECKLIST.md`](../luckymam_admin/RELEASE_CHECKLIST.md)) |
| `lib/` (Flutter) | Android mobile app |

The landing page is a **static SPA** — no Firebase, no backend API. All content is client-side React.

---

## Phase 1 — Infrastructure & deploy

| # | Item | Status | Notes |
|---|------|--------|-------|
| 1.1 | Production build passes | ✅ | `npm run build` → `dist/` |
| 1.2 | TypeScript check passes | ✅ | `tsc -b` runs as part of build |
| 1.3 | Firebase Hosting target for landing site | ❌ | Root `firebase.json` only defines `hosting:admin` — no `landing` / `web` target for `luckymam_web/dist` |
| 1.4 | `.firebaserc` hosting target | ❌ | `"targets": {}` — need `firebase hosting:sites:create` + `target:apply` for the public site |
| 1.5 | `node_modules` installed | ⚠️ | Run `npm install` on fresh clone |
| 1.6 | No env vars required | ✅ | Static site — no `.env` needed |
| 1.7 | Cache headers for static assets | ⚠️ | Not configured in `firebase.json` yet (recommended for JS/CSS/images) |
| 1.8 | SPA rewrite rule (`** → index.html`) | ⚠️ | Must be added when hosting target is created |

### Phase 1 commands

```bash
# From luckymam_web/
npm install
npm run build          # outputs to dist/

# From repo root — one-time hosting setup (example site name)
firebase hosting:sites:create luckymam-web --project luckymam-app-dv
firebase target:apply hosting web luckymam-web --project luckymam-app-dv
```

Add to root `firebase.json`:

```json
{
  "target": "web",
  "public": "luckymam_web/dist",
  "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
  "headers": [
    {
      "source": "**/*.@(js|css|woff2|woff|png|jpg|jpeg|webp|svg|ico)",
      "headers": [{ "key": "Cache-Control", "value": "public,max-age=31536000,immutable" }]
    },
    {
      "source": "/index.html",
      "headers": [{ "key": "Cache-Control", "value": "no-cache" }]
    },
    {
      "source": "**/*.apk",
      "headers": [
        { "key": "Cache-Control", "value": "no-cache" },
        { "key": "Content-Type", "value": "application/vnd.android.package-archive" }
      ]
    }
  ],
  "rewrites": [{ "source": "**", "destination": "/index.html" }]
}
```

Deploy:

```bash
cd luckymam_web && npm run build
cd .. && firebase deploy --only hosting:web --project luckymam-app-dv
```

---

## Phase 2 — APK download (critical for go-live)

| # | Item | Status | Notes |
|---|------|--------|-------|
| 2.1 | APK file present at deploy path | ❌ | Expected: `public/luckymam-v1.0.0.apk` → copied to `dist/` on build |
| 2.2 | APK filename matches constant | ⚠️ | `src/constants/download.ts` → `luckymam-v1.0.0.apk` |
| 2.3 | APK version label matches build | ⚠️ | UI shows "v1.0.0" — sync with actual Flutter release version |
| 2.4 | Download flow (desktop) | ⬜ | Stream download with progress overlay |
| 2.5 | Download flow (mobile Android) | ⬜ | Falls back to native browser download for large files |
| 2.6 | `Accept-Ranges: bytes` header | ✅ | Set in `vite.config.ts` for dev/preview; confirm on Firebase Hosting |
| 2.7 | Build fresh APK before deploy | ⬜ | `flutter build apk --release --split-per-abi` from repo root, copy to `public/` |

### APK setup steps

```bash
# Build release APK (repo root)
flutter build apk --release --split-per-abi

# Copy the appropriate ABI APK (or universal) to the landing page public folder
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk \
   luckymam_web/public/luckymam-v1.0.0.apk

# Rebuild landing page
cd luckymam_web && npm run build
```

> APK is gitignored (`luckymam_web/public/luckymam-v1.0.0.apk`) — must be copied manually before each release deploy.

---

## Phase 3 — Content & legal accuracy

| # | Item | Status | Notes |
|---|------|--------|-------|
| 3.1 | Hero copy & value proposition | ✅ | French marketing copy in place |
| 3.2 | Vaccine calculator (Algerian schedule) | ✅ | Client-side, 6 milestones |
| 3.3 | Interactive demo sections | ✅ | Capsules, phone walkthrough, pricing |
| 3.4 | Pricing matches mobile app | ⚠️ | Landing says "10 capsules/month" free — app uses **25 capsules / 1 child** (`CLAUDE.md`) |
| 3.5 | Premium price matches app | ⚠️ | Landing: "2 490 DZD / mois (facturé annuellement)" — app: **2 490 DZD/year** |
| 3.6 | VIP tier mentioned | ❌ | App has VIP (9 890 DZD/year) — not on landing page |
| 3.7 | Marquee "Play Store & App Store" | ❌ | Misleading — only direct APK download exists today |
| 3.8 | Contact email | ✅ | `contact@luckymam.com.dz` in `src/constants/contact.ts` |
| 3.9 | Privacy policy page | ❌ | Footer link is `#` placeholder |
| 3.10 | Terms of use page | ❌ | Footer link is `#` placeholder |
| 3.11 | Law 18-07 compliance page | ❌ | Footer link is `#` placeholder |
| 3.12 | Loi 18-07 badge in hero/marquee | ✅ | Mentioned in copy |

---

## Phase 4 — SEO, performance & accessibility

| # | Item | Status | Notes |
|---|------|--------|-------|
| 4.1 | `<title>` and meta description | ✅ | Set in `index.html` |
| 4.2 | `lang="fr"` on `<html>` | ✅ | French-only site |
| 4.3 | Open Graph / Twitter cards | ❌ | Not configured |
| 4.4 | Favicon | ⚠️ | Points to `/src/assets/logo.png` — works via Vite; verify in production |
| 4.5 | Image optimization | ⚠️ | Hero/illustration PNGs ~225–780 KB each — consider WebP |
| 4.6 | JS bundle size | ✅ | ~241 KB (~72 KB gzip) — acceptable |
| 4.7 | Mobile responsive layout | ✅ | Sticky mobile download bar, hamburger menu |
| 4.8 | Arabic / English i18n | ❌ | French only (mobile app supports fr/ar/en) |
| 4.9 | Keyboard / screen reader on download | ⚠️ | Download overlay has `aria-live`; full a11y audit not done |

---

## Phase 5 — Code quality

| # | Item | Status | Notes |
|---|------|--------|-------|
| 5.1 | ESLint clean | ❌ | 6 errors (React hooks + `any` type) |
| 5.2 | No Firebase dependency | ✅ | Static site — simpler deploy surface |
| 5.3 | No secrets in repo | ✅ | No API keys needed |
| 5.4 | `DOCUMENTATION.md` accurate | ❌ | File is a copy of admin docs — should be rewritten for landing page |
| 5.5 | `README.md` project-specific | ❌ | Still default Vite template README |

### Known lint issues

| File | Issue |
|------|-------|
| `src/App.tsx` | `setState` in `useEffect` (vaccine schedule); `any` on timeout ref |
| `src/components/DownloadLink.tsx` | `setState` in `useEffect` |
| `src/context/DownloadContext.tsx` | Fast refresh export warning |

---

## Phase 6 — Manual QA (before go-live)

| # | Test | Status |
|---|------|--------|
| 6.1 | Page loads on desktop Chrome / Safari / Firefox | ⬜ |
| 6.2 | Page loads on mobile Android browser | ⬜ |
| 6.3 | All nav anchor links scroll correctly | ⬜ |
| 6.4 | Mobile hamburger menu opens/closes | ⬜ |
| 6.5 | Vaccine calculator updates dates on date change | ⬜ |
| 6.6 | Capsule audio simulation plays | ⬜ |
| 6.7 | Phone walkthrough tabs switch content | ⬜ |
| 6.8 | APK download completes (desktop) | ⬜ |
| 6.9 | APK download works on Android mobile | ⬜ |
| 6.10 | Sticky mobile download bar visible | ⬜ |
| 6.11 | Contact mailto link works | ⬜ |
| 6.12 | Production deploy + custom domain (if any) | ⬜ |

---

## Critical blockers (fix first)

1. **No Firebase Hosting target** for `luckymam_web/dist`
2. **APK file missing** from `public/` — download buttons will 404 in production
3. **Pricing / feature copy out of sync** with the real mobile app tiers
4. **Legal pages missing** — privacy, terms, Law 18-07 (required for public launch in DZ context)
5. **"Play Store & App Store" claim** in marquee — remove or replace until store listings exist

---

## Recommended fix order

```
1. Add Firebase Hosting target (web) + firebase.json entry
2. Build Flutter APK and copy to luckymam_web/public/luckymam-v1.0.0.apk
3. Align pricing/features copy with app subscription model
4. Add legal pages (or link to hosted PDFs)
5. Fix ESLint errors
6. Remove or correct "Play Store & App Store" marquee text
7. Manual QA on desktop + Android
8. firebase deploy --only hosting:web
9. (Optional) Add OG tags, WebP images, AR/EN i18n
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

- [`../CLAUDE.md`](../CLAUDE.md) — monorepo overview (Flutter app + web projects)
- [`../luckymam_admin/RELEASE_CHECKLIST.md`](../luckymam_admin/RELEASE_CHECKLIST.md) — admin dashboard release checklist
- [`package.json`](./package.json) — scripts: `dev`, `build`, `lint`, `preview`
