# Task: 👑 Subscription & VIP Overhaul (باقات الاشتراك والدفع الفاخر)

**Status:** IN_PLANNING  
**Target:** `lib/features/subscription/`  
**Lead Agent:** `mobile-developer`  

---

## 1. Overview & Objective
Transform the subscription experience from a basic tier list into a high-converting, luxury **Squircle Bento Paywall & VIP Checkout Flow** specifically tailored for Algerian mothers:
- Highlight the **VIP Diamond Plan** as the ultimate luxury package (including the physical printed photo album shipped to the home).
- Replace misleading manual credit card fields with a streamlined, 100% secure direct checkout via **Chargily Pay (Edahabia / CIB)**.
- Include a comprehensive Feature Comparison Matrix, Trust & Security Badges (Algérie Poste & SATIM), and an FAQ Accordion.

---

## 2. Technical Architecture & File Changes

| Component / Screen | File Path | Scope of Work |
|---|---|---|
| **Subscription Plans Screen** | `lib/features/subscription/screens/subscription_plans_screen.dart` | Full overhaul with `TopAmbientGradient`, hero VIP spotlight, comparison matrix, trust badges, and FAQ. |
| **Plan Card Widget** | `lib/features/subscription/widgets/plan_card.dart` | Luxury Squircle Bento redesign, gold/amber gradient for VIP, glowing badges, haptic feedback. |
| **Feature Matrix Widget** | `lib/features/subscription/widgets/plan_comparison_table.dart` | New side-by-side interactive comparison matrix for Free vs Premium vs VIP. |
| **FAQ Accordion Widget** | `lib/features/subscription/widgets/subscription_faq_section.dart` | New expandable FAQ accordion answering questions about payment, delivery, and album claim. |
| **Payment & Checkout Screen** | `lib/features/subscription/screens/payment_screen.dart` | Streamlined Algerian checkout (Order summary, Edahabia/CIB selector, direct Chargily Pay button, celebration success dialog). |
| **Localization Files** | `lib/l10n/app_ar.arb`, `app_fr.arb`, `app_en.arb` | Add new localized keys for comparison matrix, FAQ, trust badges, and VIP celebration. |

---

## 3. Step-by-Step Implementation Plan

### Phase 1: Localization & Copywriting
- Add clear Arabic, French, and English keys for:
  - FAQ questions & answers (Delivery of album, security of payment, renewal).
  - Feature matrix rows (Capsules, Children, Health tools, Physical album, Support).
  - Trust reassurance phrases (100% Secure via GIE Monétique & Algérie Poste).

### Phase 2: Plan Cards & Comparison Matrix
- Build `PlanComparisonTable` showing clean check/cross/value cells for each tier.
- Update `PlanCard` with luxury squircle borders, subtle glows, and the "الأكثر قيمة / Most Popular" ribbon on VIP.
- Add `SubscriptionFaqSection` with smooth expandable tiles.

### Phase 3: Subscription Plans Screen Overhaul
- Assemble `SubscriptionPlansScreen` with:
  - Ambient background gradient.
  - Plan cards carousel/list with VIP hero prominence.
  - Comparison table.
  - Trust guarantee badges.
  - FAQ section.

### Phase 4: Streamlined Algerian Payment Screen
- Remove misleading raw credit card input fields.
- Present clean order summary with selected plan details and DZD pricing.
- Add direct secure button linking to `ChargilyPaymentService.createCheckout`.
- On successful payment, trigger celebratory congratulations modal with direct button to `AlbumClaimScreen` for VIP members.

### Phase 5: Verification & Quality Assurance
- Run `flutter analyze lib/features/subscription/ lib/l10n/`.
- Test responsiveness and theme support (Dark & Light modes).
- Ensure smooth haptic feedback and animations.

---

## 4. Edge Cases & Validation
1. **Payment Cancellation / Failure**: Provide clear, non-intrusive feedback and allow immediate one-tap retry without re-entering details.
2. **Current Subscriber Upgrades**: Detect active tier; disable downgraded re-purchases and provide clean upgrade pathway.
