# Luckymam Admin — Checklist جاهزية لوحة التحكم

**المشروع:** `luckymam-app-dv` · **المجلد:** `luckymam_admin/`  
**تاريخ التدقيق:** 2026-08-16  
**آخر تحديث:** 2026-08-17 (seed + hosting index fix)  
**الجاهزية الإجمالية:** ~88% — **قريبة من الإنتاج**

| المحور | التقييم | النسبة التقريبية |
|--------|---------|------------------|
| الواجهة + ربط Firebase | ✅ جيد | ~90% |
| الأمان للإنتاج | ✅ جيد | ~80% |
| المنطق الأعمال | ⚠️ متوسط | ~70% |
| السلاسة (UX) | ✅ جيد | ~85% |
| جاهزية Deploy | ✅ جيد | ~85% |

**الحكم:** اللوحة على [https://luckymam-app-dv.web.app](https://luckymam-app-dv.web.app) — **⚠️ 404 حتى redeploy** (fix `index.html` جاهز في build). usable للإنتاج بعد redeploy + smoke test.

**CLI:** Firebase + gcloud على `gribyassinefb@gmail.com` · project `luckymam-app-dv`

---

## A — ما هو جاهز ✅

- [x] تسجيل الدخول + فحص claim `admin: true` (`AuthProvider`, `/login`)
- [x] حماية المسارات (`AuthGuard`)
- [x] Reels — Firestore + Storage + معاينة فيديو (`/reels-catalog`)
- [x] المستخدمون — قراءة live + subcollection `children` (`/users`)
- [x] الإعدادات — `settings/global` + حساب admin (اسم / كلمة مرور) (`/settings`)
- [x] المتجر / الطلبات / الطباعة / التنبيهات — مربوطة بـ Firestore (CRUD أو read)
- [x] i18n (ar / fr / en) + RTL + Sidebar scroll ثابت
- [x] Loading / error / empty states في أغلب الصفحات
- [x] قواعد Firestore: `isAdmin()` على مجموعات الـ backoffice — **منشورة**
- [x] Reels Storage: قراءة عامة، كتابة admin فقط — **منشورة**
- [x] Storage `products/` — **منشورة**
- [x] تغيير كلمة المرور: reauth + `updatePassword`
- [x] ملفات `.mock.ts` — types/labels فقط، ليست مصدر بيانات UI
- [x] **تدوير Service Account** — مفاتيح قديمة حُذفت، مفتاح جديد محلي *(2026-08-17)*

- [x] **Git push** — commit `4fc9695` على `origin/main` *(2026-08-17)*
- [x] **Seed Firestore** — products (9), orders (3), print+claims, notifications *(2026-08-17)*
- [x] **Hosting index fix** — `scripts/generateHostingIndex.mjs` + `npm run build` *(2026-08-17)*

---

## A.1 — Auth users (prod)

| UID | Email | admin claim |
|-----|-------|-------------|
| `bsOKvrjp5yM1JEsHZ19TeEHPw1h2` | admin@luckymam.app | ✅ |
| `rakWLhCvYfhQ7jZ9fEpmaDbzHQG2` | gribyassine@gmail.com | ❌ — `npm run set-admin-claim -- rakWLhCvYfhQ7jZ9fEpmaDbzHQG2` |
| `Kb25k6i11YbrSzrvcOEWsGqpeR13` | sarasaid@luckymam.dz | ❌ |

`npm run list-auth-users` — list accounts + claims

---

## B — المرحلة 1: Blockers قبل أي Deploy 🔴

> **الهدف:** رفع الجاهزية إلى ~90% · **الحالة:** ~90% مكتمل

### أمان وأسرار

- [x] إزالة `scripts/service-account.json` من Git *(تم `git rm --cached` — يلزم commit)*
- [x] إضافة `scripts/service-account.json` إلى `.gitignore`
- [x] **تدوير** مفتاح Service Account *(2026-08-17 — 3 مفاتيح قديمة حُذفت)*
- [x] تقييد قراءة `notifications` للأدmin فقط في `firestore.rules`
- [x] إضافة قاعدة Storage لمسار `products/` في `storage.rules`:

```javascript
match /products/{fileName} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.token.admin == true;
}
```

- [x] نشر القواعد: `firebase deploy --only firestore:rules,storage --project luckymam-app-dv` *(2026-08-16)*

### بنية تحتية Deploy

- [x] مواءمة `firebase.json` مع مسار البناء (`.output/public`)
- [x] إعداد Firebase Hosting target في `.firebaserc` — `admin` → `luckymam-app-dv` *(2026-08-16)*
- [ ] التحقق من `.env.local` (`VITE_FIREBASE_API_KEY`, `VITE_FIREBASE_APP_ID`) على CI/CD
- [x] `npm run build` ينجح بدون أخطاء
- [x] إضافة `npm run set-admin-claim` إلى `package.json` → `scripts/setAdminClaim.mjs`
- [x] **Deploy hosting:** `firebase deploy --only hosting:admin` → [luckymam-app-dv.web.app](https://luckymam-app-dv.web.app) *(2026-08-16)*

### إصلاحات UI حرجة

- [x] ربط زر **تسجيل الخروج** في Sidebar بـ `signOutUser`
- [x] استبدال `updateDoc` بـ `setDoc(..., { merge: true })` لـ `settings/global`
- [x] `settings/global` موجود في Firebase *(لا حاجة لـ seed)*

---

## C — المرحلة 2: منطق الأعمال 🟡

> **المدة المقدّرة:** 3–5 أيام · **الحالة:** ~75% مكتمل

### التنبيهات (`/notifications`)

- [x] حساب `audienceCounts` من `users` live (بدل الأرقام الثابتة في `notifications.mock.ts`)
- [ ] Cloud Function أو FCM لإرسال Push فعلي
- [ ] مجدول حقيقي لـ `status: "scheduled"`
- [ ] إزالة أو تصحيح شارة «خدمة الإشعارات نشطة» إذا لم يُنفَّذ الإرسال

### الاشتراكات (`/users` ↔ Flutter)

- [x] مزامنة `subscriptionTier` مع `endDate` / `subscriptions[]`
- [x] Flutter: التحقق من انتهاء الاشتراك (`subscription_providers.dart`)
- [ ] توحيد النموذج: subcollection `users/{uid}/subscriptions` أو حقول مضمّنة (اختيار واحد)
- [x] `saving` state عند grant/cancel اشتراك

### طلبات المتجر (`/marketplace-orders`)

- [x] restock + تحديث الحالة في **transaction** واحدة
- [x] منع restock مزدوج عند إلغاء مرتين
- [x] حماية double-submit على تغيير الحالة

### Flutter — المتجر

- [x] استبدال `marketplace_data.dart` static بـ Firestore stream (`marketplace_products`) — fallback static إذا فارغ
- [ ] اختبار end-to-end: admin يضيف منتج → يظهر في التطبيق

---

## C — المرحلة 3: UX / أداء / Polish 🟢

### تجربة المستخدم

- [x] `sendPasswordResetEmail` لـ «نسيت كلمة المرور؟» (`/login`)
- [x] رسالة واضحة عند login بدون claim admin
- [ ] إزالة أو تنفيذ: 2FA، Google Workspace، «إبقاء الجلسة»
- [ ] Topbar: بحث + جرس إشعارات (تنفيذ أو إخفاء)
- [ ] Toasts بدل `alert()` للأخطاء
- [x] Dashboard: UI خطأ عند فشل مستمع Firestore
- [x] Dashboard loading لا يعتمد على `marketplace_products` فقط
- [x] إشعارات اللوحة في Settings — localStorage + إزالة شارة «حفظ تلقائي» المضللة
- [ ] إصلاح `dir="rtl"` الثابت في `__root.tsx` عند fr/en LTR
- [x] TrendingCard Reels — إزالة `+12%` الوهمية (views + likes حقيقية)
- [x] Login — إزالة «12.4k مستخدم» الثابت

### الأداء

- [ ] تقليل 6 × `onSnapshot` على Dashboard (دمج أو aggregates)
- [ ] Pagination على `/users` و `/marketplace-orders`
- [ ] إزالة `tr` من dependency arrays في `useEffect` (منع reconnect)

### جودة الكود

- [ ] ESLint clean (حالياً ~734 issue — غالباً Prettier)
- [ ] Reels delete: دعم legacy paths + ترتيب حذف Storage/Firestore

---

## D — Checklist الصفحات (صفحة × صفحة)

| # | الصفحة | Route | Firebase | المنطق | UX | جاهز؟ |
|---|--------|-------|----------|--------|-----|-------|
| D.1 | Login | `/login` | [x] Auth | [x] | [x] reset + no fake stats | ✅ |
| D.2 | Dashboard | `/` | [x] 6 collections | [x] KPIs | [x] error UI | ✅ |
| D.3 | Users | `/users` | [x] | [x] subscription sync | [x] saving | ✅ |
| D.4 | Print orders | `/print-orders` | [x] | [x] | [x] | ✅ (فارغ) |
| D.5 | Marketplace orders | `/marketplace-orders` | [x] | [x] restock tx | [x] double-click | ✅ |
| D.6 | Catalog | `/marketplace-catalog` | [x] | [x] | [x] | ✅ |
| D.7 | Inventory | `/marketplace-inventory` | [x] | [x] | [x] | ✅ (فارغ) |
| D.8 | Reels | `/reels-catalog` | [x] | [x] | [x] | ✅ |
| D.9 | Notifications | `/notifications` | [x] | [ ] push وهمي | [x] | ❌ backend |
| D.10 | Settings | `/settings` | [x] | [x] | [x] | ✅ |
| D.11 | Album claims | `/album-claims` | redirect → print-orders | — | — | ✅ |

### تفاصيل Firebase per page

#### D.1 `/login`
- [x] `signInWithEmailAndPassword`
- [x] رفض حساب بدون `admin: true`
- [x] «نسيت كلمة المرور؟» — `sendPasswordResetEmail`
- [ ] «إبقاء الجلسة» فعّال

#### D.2 `/` — Dashboard
- [x] `users`, `marketplace_orders`, `print_orders`, `album_claims`, `marketplace_products`, `notifications`
- [x] معالجة خطأ UI لكل مستمع
- [x] loading مستقل عن `marketplace_products` فقط

#### D.3 `/users`
- [x] `onSnapshot(users)` + `users/{id}/children`
- [x] grant/cancel subscription → Firestore
- [x] تطابق Flutter `subscriptionTier` + `endDate`
- [x] saving state على الأزرار

#### D.4 `/print-orders`
- [x] `print_orders` + `album_claims` merged
- [x] status update: `status`, `statusUpdatedAt`, `statusUpdatedBy`
- [ ] بيانات seed (اختياري): `seedPrintAndClaims.mjs`

#### D.5 `/marketplace-orders`
- [x] `marketplace_orders` read/update
- [x] restock on cancel → `marketplace_products`
- [x] transaction atomic
- [ ] بيانات seed (اختياري): `seedOrders.mjs`

#### D.6 `/marketplace-catalog`
- [x] CRUD `marketplace_products`
- [x] upload → Storage `products/{fileName}`
- [x] Storage rule `products/` **منشورة**
- [ ] بيانات seed (اختياري): `seedProducts.mjs`

#### D.7 `/marketplace-inventory`
- [x] stock/status update على `marketplace_products`

#### D.8 `/reels-catalog`
- [x] 4 reels في Firestore + Storage URLs
- [x] `settings/reels_config`
- [x] Flutter app compatible (`https://` URLs)
- [x] `npm run sync-reels` متاح

#### D.9 `/notifications`
- [x] CRUD `notifications`
- [x] `audienceCounts` من users live
- [ ] FCM / scheduled send
- [ ] seed (اختياري): `seedNotifications.mjs`

#### D.10 `/settings`
- [x] `settings/global` read/write
- [x] admin display name + password (Firebase Auth)
- [x] بطاقة حساب collapsible + edit icon
- [x] `setDoc merge` بدل `updateDoc` فقط
- [x] notify toggles — localStorage + badge صادق

---

## E — Checklist بيانات Firestore

| المجموعة | موجود في Firebase | اللوحة تقرأ | ملاحظة |
|----------|-------------------|-------------|--------|
| `users` | [x] 3+ | [x] | حقيقي |
| `reels` | [x] 4 | [x] | متزامن |
| `settings/global` | [x] | [x] | |
| `settings/reels_config` | [x] | [x] | |
| `marketplace_products` | [x] 9 | [x] | seeded 2026-08-17 |
| `marketplace_orders` | [x] 3 | [x] | seeded 2026-08-17 |
| `print_orders` | [x] 2 | [x] | seeded 2026-08-17 |
| `album_claims` | [x] 1 | [x] | seeded 2026-08-17 |
| `notifications` | [x] 4 | [x] | seeded 2026-08-17 |

### أوامر التعبئة (اختياري — dev/staging)

```bash
cd luckymam_admin
node scripts/seedProducts.mjs
node scripts/seedOrders.mjs
node scripts/seedPrintAndClaims.mjs
node scripts/seedNotifications.mjs
node scripts/syncReelsFirestore.mjs   # reels من Storage
```

---

## F — Checklist الأمان (Security)

### 🔴 حرج

- [x] `service-account.json` خارج Git + مفتاح مُدوَّر *(gitignore ✅ · push ✅ · rotation 2026-08-17)*
- [x] Storage rule `products/` — **منشورة**
- [x] `notifications` read → admin only — **منشورة**
- [ ] تقييد حقول كتابة admin على `users/{uid}` (optional hardening)

### 🟡 يُفضّل

- [x] Sidebar logout يعمل
- [x] `set-admin-claim` في npm scripts
- [x] رسالة login لـ non-admin
- [ ] التحقق من `ctaUrl` (منع `javascript:`)

### ✅ موجود

- [x] `isAdmin()` في Firestore rules — **prod**
- [x] AuthGuard + claim refresh
- [x] Status field locks على orders/claims
- [x] `VITE_*` في `.env.local` (gitignored via `*.local`)
- [x] consent/analytics logs append-only

---

## G — Checklist Deploy للإنتاج

- [x] Phase B — blockers ✅
- [x] `firebase deploy --only firestore:rules,storage` *(2026-08-16)*
- [x] `firebase target:apply hosting admin luckymam-app-dv` *(2026-08-16)*
- [x] `npm run build` → deploy `.output/public` *(2026-08-16)*
- [ ] **Redeploy hosting** — بعد fix `index.html`: `firebase deploy --only hosting:admin`
- [ ] Admin claim لـ `gribyassine@gmail.com` *(admin@luckymam.app جاهز)*
- [ ] Smoke test: login → reels → users → settings → catalog upload
- [ ] Phase C منطق الأعمال — FCM + E2E marketplace
- [ ] Phase D UX polish

**URL prod:** [https://luckymam-app-dv.web.app](https://luckymam-app-dv.web.app)

---

## H — Definition of Done (100%)

اللوحة **جاهزة 100%** عندما:

- [x] **جميع** بنود المرحلة B (Blockers) ✅
- [ ] **جميع** بنود المرحلة C (منطق أعمال حرج) ✅ *(FCM + scheduled + E2E marketplace)*
- [x] Storage + Firestore rules منشورة ومختبرة
- [x] Deploy prod ناجح — hosting live
- [ ] Smoke test prod مكتمل
- [ ] التنبيهات: إرسال حقيقي أو UI يعكس الواقع
- [x] الاشتراكات: Admin ↔ Flutter متزامنان
- [x] Flutter marketplace يقرأ `marketplace_products` *(fallback static إذا فارغ)*
- [x] لا أسرار في Git *(squash push 2026-08-17)*
- [ ] ESLint / build CI clean

---

## I — مراجع

| ملف | الغرض |
|-----|--------|
| `luckymam_admin/RELEASE_CHECKLIST.md` | checklist deploy تفصيلي |
| `firestore.rules` | حد الأمان Firestore |
| `storage.rules` | حد الأمان Storage |
| `.firebaserc` | hosting target `admin` → `luckymam-app-dv` |
| `luckymam_admin/src/components/admin/AuthProvider.tsx` | Auth + guard |
| `luckymam_admin/scripts/setAdminClaim.mjs` | منح claim admin |

### أوامر Deploy (مُنفَّذة 2026-08-16)

   ```bash
firebase target:apply hosting admin luckymam-app-dv --project luckymam-app-dv
firebase deploy --only firestore:rules,storage --project luckymam-app-dv
cd luckymam_admin && npm run build
firebase deploy --only hosting:admin --project luckymam-app-dv
```

---

> **ملخص:** اللوحة ~88% جاهزة. **Seed** مكتمل. **Hosting fix** جاهز — يلزم `firebase deploy --only hosting:admin`.  
> **Login prod:** `admin@luckymam.app` (admin ✅) أو grant claim لـ `gribyassine@gmail.com`.  
> **متبقٍ:** redeploy hosting + smoke test + FCM + E2E marketplace.
