# Luckymam - Application Documentation

> **Version**: 1.0  
> **Date**: February 2026  
> **Type**: Mobile Application (Flutter)

---

## 📋 Executive Summary

**Luckymam** is a premium mobile application designed for mothers in **Algeria**, providing a complete lifecycle companion from **pre-pregnancy to childhood**. The app enables mothers to:

- 📸 **Capture emotional moments** as "Capsules" (photo + audio memories)
- 📅 **Track milestones** through an intelligent timeline
- 💉 **Manage vaccination schedules** based on the Algerian national calendar
- 👨‍👩‍👧 **Share memories** with family members
- 📖 **Create printed photo albums**

The application targets both **French** and **Arabic (RTL)** speaking users with a focus on cultural traditions and religious events.

---

## 🎯 Product Vision

```mermaid
mindmap
  root((Luckymam))
    Emotional Journaling
      Capsules (Photo + Audio)
      Milestone Tracking
      Memory Preservation
    Health Management
      Vaccination Calendar
      Medical Appointments
      Growth Tracking
    Family Sharing
      Multi-child Profiles
      Family Access
      Privacy Controls
    Monetization
      Freemium Model
      Premium Annual
      VIP Subscription
      Printed Albums
```

---

## 📊 Data Architecture

### 1. Vaccination Database

The vaccination schedule follows the **Algerian National Vaccination Calendar** with comprehensive coverage from birth to adulthood.

| Age Range | Vaccine | Details |
|-----------|---------|---------|
| **Naissance** | BCG-HBV | Tuberculosis + Hepatitis B protection |
| **2 mois** | DTCaVPI-Hib-HBV + VPOb + VPC | Diphtheria, Tetanus, Pertussis, Polio, Haemophilus, Hepatitis B, Pneumococcal |
| **4 mois** | DTCaVPI-Hib-HBV + VPOb + VPC | Booster dose |
| **11 mois** | ROR | Measles, Mumps, Rubella |
| **12 mois** | DTCaVPI-Hib-HBV + VPOb + VPC | Final infant dose |
| **18 mois** | ROR | Booster dose |
| **6 ans** | DTCa-VPI | School-age booster |
| **11-13 ans** | dT | Adolescent booster |
| **16-18 ans** | dT | Teen booster |
| **Every 10 years (18+)** | dT | Adult decennial booster |

#### Vaccine Coverage Details

| Abbreviation | Full Name | Protection Against |
|--------------|-----------|-------------------|
| **BCG** | Bacille Calmette et Guérin | Tuberculosis complications |
| **HBV** | Hepatitis B Vaccine | Hepatitis B virus |
| **DTCaVPI-Hib** | Hexavalent | Diphtheria, Tetanus, Pertussis, Polio, Haemophilus |
| **VPOb** | Oral Polio Vaccine type b | Poliomyelitis |
| **VPC** | Pneumococcal Conjugate | Pneumococcal infections |
| **ROR** | Rougeole-Oreillons-Rubéole | Measles, Mumps, Rubella |
| **dT** | Reduced diphtheria toxoid | Tetanus, Diphtheria |

---

### 2. Life Events Timeline Database

The timeline covers **70 unique events** across **5 life phases**:

```mermaid
timeline
    title Life Phases Coverage
    section Pré-Gestation
        M-12 to M0 : Decision to have a child
    section Gestation (M1-M9)
        M1-M3 : First trimester milestones
        M4-M6 : Second trimester monitoring
        M7-M9 : Third trimester preparation
    section Post Partum (J0-12 mois)
        J0-S4 : Birth and first weeks
        0-6 mois : Early development
        6-12 mois : Motor and speech development
    section Enfance (1-18 ans)
        12-30 mois : Toddler milestones
        2-6 ans : Pre-school years
        6-18 ans : School vaccinations
    section Adulte
        18+ : Decennial vaccine reminders
```

#### Event Categories

| Category | Count | Description |
|----------|-------|-------------|
| **Émotion** | 22 | Emotional moments to capture |
| **Santé** | 34 | Health milestones and medical visits |
| **Culture** | 8 | Cultural celebrations and traditions |
| **Religion** | 5 | Religious events (Aïd, Akika, Circoncision, Quran) |

#### Key Events by Phase

##### Gestation Phase (30 events)
- Monthly belly photos (M1-M9)
- 7 medical visits with ultrasounds
- Food cravings documentation ("WHAM")
- Baby gender reveal
- First fetal movements
- Nursery preparation

##### Post Partum Phase (26 events)
- First cry and breastfeeding
- Vaccination milestones (2, 4, 11, 12 months)
- Religious ceremonies (Circoncision, Akika)
- Developmental milestones (sitting, crawling, walking, first words)
- Dental development tracking

##### Childhood Phase (14 events)
- First day of preschool/school
- Religious milestones (Sourate Fatiha memorization)
- School-age vaccinations (6, 11-13, 16-18 years)

---

### 3. Product Backlog (User Stories)

The backlog contains **117 user stories** organized into **17 Epics** across a **12-month roadmap**.

```mermaid
pie title User Stories by Priority (MoSCoW)
    "Must Have" : 62
    "Should Have" : 38
    "Could Have" : 17
```

---

## 🏗️ Feature Architecture

### Epic Overview

| Epic ID | Epic Name | Stories | Priority Focus |
|---------|-----------|---------|----------------|
| **1** | Onboarding & Compte | 10 | Account management, authentication |
| **2** | Onboarding & Profil | 1 | Profile setup |
| **3** | Famille | 6 | Child profiles, family sharing |
| **4** | Timeline | 6 | Milestone tracking, custom events |
| **5** | Capsules | 11 | Photo/audio memory capture |
| **6** | Reels | 3 | Educational video content |
| **7** | Admin Reels | 3 | Content management |
| **8** | Santé | 4 | Vaccination calendar, reminders |
| **9** | Monétisation | 12 | Subscriptions, payments |
| **10** | Admin Plateforme | 15 | Backoffice operations |
| **11** | Qualité & Compliance | 20 | GDPR, security, accessibility |
| **12** | Engagement | 5 | Notifications, lifecycle messaging |
| **13** | Paramètres | 5 | App settings, storage |
| **14** | Découverte | 4 | Search, recommendations |
| **15** | Privacy | 3 | Privacy controls |
| **16** | Security | 2 | Device security |
| **17** | Album papier | 4 | Printed album ordering |

---

## 🚀 Roadmap Phases

### Phase 1: MVP (M1-M3)

**Focus**: Core functionality launch

| Feature | Story Points |
|---------|--------------|
| Account creation & login | 18 |
| Consent management | 8 |
| Mother profile | 8 |
| Child profiles | 13 |
| Timeline view | 13 |
| Capsule creation | 21 |
| Gallery & filters | 16 |
| Plan display | 5 |
| Accessibility (WCAG AA) | 5 |
| RTL support (Arabic) | 5 |
| Performance optimization | 5 |

**Total: ~117 story points**

---

### Phase 2: Growth (M4-M6)

**Focus**: Health features, monetization, offline support

| Feature | Story Points |
|---------|--------------|
| Account deletion & export | 21 |
| 2FA authentication | 8 |
| SSO (Apple/Google) | 8 |
| Timeline offline mode | 8 |
| Admin milestone rules | 21 |
| Capsule editing & trash | 16 |
| Vaccination calendar | 8 |
| Vaccine reminders | 8 |
| Payment checkout (CIB/Edahabia) | 18 |
| Storage quotas | 8 |

**Total: ~124 story points**

---

### Phase 3: Engagement (M7-M9)

**Focus**: Social features, advanced content

| Feature | Story Points |
|---------|--------------|
| Custom milestones | 8 |
| Privacy levels per child | 8 |
| Family invitations | 13 |
| Social sharing with blur | 8 |
| Reels content | 13 |
| Admin reels workflow | 26 |
| Premium renewal | 8 |
| VIP subscription | 16 |
| Lifecycle campaigns | 8 |
| Remote config | 8 |
| Feature flags | 8 |

**Total: ~124 story points**

---

### Phase 4: Premium (M10-M12)

**Focus**: VIP features, printed albums

| Feature | Story Points |
|---------|--------------|
| Guest mode | 8 |
| Vault (biometric lock) | 13 |
| Reels scheduling | 5 |
| Offline reels caching | 8 |
| Auto-album suggestions | 8 |
| Home widget | 13 |
| Jailbreak detection | 13 |
| Screenshot protection | 8 |
| Printed album ordering | 34 |
| VIP voucher system | 13 |
| VIP perks management | 8 |

**Total: ~131 story points**

---

## 💰 Monetization Model

### Subscription Plans

```mermaid
graph TB
    subgraph Freemium
        A[Free Forever]
        A1[25 Capsules Max]
        A2[Basic Features]
    end
    
    subgraph Premium
        B[1990 DA/year]
        B1[100 Capsules Max]
        B2[All Features]
    end
    
    subgraph VIP Year 1
        C[150,000 DA/year]
        C1[Unlimited Capsules]
        C2[1 Free Album + Delivery]
        C3[VIP Perks]
    end
    
    subgraph VIP Renewal
        D[3990 DA/year]
        D1[Unlimited Capsules]
        D2[VIP Perks - No Album]
    end
    
    A --> B
    B --> C
    C --> D
```

### Payment Methods (Algeria-specific)

| Method | Type |
|--------|------|
| **CIB** | Algerian bank cards |
| **Edahabia** | Postal cards |
| **CCP** | Postal account |
| **Promo Codes** | Discount codes |

### Quota System

| Plan | Capsule Limit | Storage |
|------|---------------|---------|
| Freemium | 25 | Limited |
| Premium | 100 | Extended |
| VIP | Unlimited* | Unlimited* |

*Fair-use policy applies

---

## 🔐 Security & Compliance

### Data Protection

| Requirement | Implementation |
|-------------|----------------|
| **Password Hashing** | Secure hash + salt |
| **JWT Tokens** | Access + refresh tokens |
| **2FA** | SMS/OTP verification |
| **Encryption at Rest** | All personal data |
| **Local Encryption** | Device media storage |
| **Upload Security** | Antivirus scanning |
| **Rate Limiting** | API abuse protection |

### GDPR Compliance

| Feature | Story ID |
|---------|----------|
| **Consent Management** | LM2-004 |
| **Data Export** | LM2-007 |
| **Account Deletion** | LM2-006 |
| **Privacy Center** | LM2-064 |
| **DSAR Processing** | LM2-051 |
| **Data Retention** | LM2-077 |
| **Audit Logs** | LM2-050 |

### Accessibility (WCAG AA)

- High contrast ratios
- Focus management
- Screen reader support
- Dynamic text sizing
- RTL layout support

---

## 🌍 Internationalization

### Supported Languages

| Language | Direction | Priority |
|----------|-----------|----------|
| **French (FR)** | LTR | Primary |
| **Arabic (AR)** | RTL | Primary |
| **English (EN)** | LTR | Secondary |

### Cultural Considerations

| Category | Events |
|----------|--------|
| **Islamic Calendar** | Aïd el-Fitr, Aïd al-Adha |
| **Traditions** | Akika (feast), Circoncision |
| **Religious Education** | First Quran memorization |

---

## 📱 Technical Architecture

### Core Features

```mermaid
graph TD
    subgraph Frontend [Flutter App]
        A[Onboarding] --> B[Timeline]
        B --> C[Capsules]
        B --> D[Health/Vaccines]
        C --> E[Gallery]
        C --> F[Sharing]
        D --> G[Reminders]
    end
    
    subgraph Backend [Firebase]
        H[Authentication]
        I[Firestore]
        J[Cloud Storage]
        K[Cloud Functions]
        L[Cloud Messaging]
    end
    
    subgraph Admin [Backoffice]
        M[User Management]
        N[Content CMS]
        O[Analytics]
        P[Moderation]
    end
    
    Frontend --> Backend
    Backend --> Admin
```

### Capsule Structure

```
Capsule {
    id: string
    userId: string
    childId: string
    milestoneId?: string
    photo: MediaRef
    audio: MediaRef (max 25 seconds)
    emotion: EmotionTag
    tags: string[]
    location?: GeoPoint (opt-in)
    createdAt: timestamp
    updatedAt: timestamp
    version: number
    isDeleted: boolean
}
```

### Timeline Rules Engine

```
MilestoneRule {
    id: string
    phase: Phase (pre-gestation|gestation|post-partum|childhood|adult)
    triggerAge: AgeCondition
    category: string (emotion|health|culture|religion)
    title: LocalizedString
    description: LocalizedString
    actions: Action[]
    version: number
    country: string (DZ default)
}
```

---

## 📈 Analytics Events

### Key Tracking Events

| Category | Events |
|----------|--------|
| **Onboarding** | `signup_started`, `signup_completed`, `login_success`, `profile_completed` |
| **Core Usage** | `timeline_opened`, `milestone_opened`, `capsule_created`, `gallery_opened` |
| **Health** | `vax_calendar_open`, `vax_reminder_set`, `vax_marked_done` |
| **Monetization** | `plan_viewed`, `payment_success`, `promo_applied`, `quota_blocked` |
| **Engagement** | `notif_snoozed`, `deeplink_open`, `share_link_created` |

---

## 🧪 Quality Assurance

### Test Coverage Requirements

| Type | Focus |
|------|-------|
| **E2E Tests** | Critical user journeys |
| **Unit Tests** | Business logic |
| **Integration Tests** | API contracts |
| **Accessibility Tests** | WCAG AA compliance |
| **Security Tests** | Vulnerability scanning |

### CI/CD Pipeline

```mermaid
graph LR
    A[Code Push] --> B[Lint & Format]
    B --> C[Unit Tests]
    C --> D[Integration Tests]
    D --> E[E2E Tests]
    E --> F[Security Scan]
    F --> G[Accessibility Check]
    G --> H[Build]
    H --> I[Deploy]
```

---

## 👥 User Roles

### Application Roles

| Role | Permissions |
|------|-------------|
| **Mother (User)** | Full CRUD on own data, sharing, purchasing |
| **Family Member** | Read-only access to shared content |
| **Guest** | Local capsules only, no sync |

### Admin Roles

| Role | Permissions |
|------|-------------|
| **Admin** | Full platform access |
| **Content Reviewer** | Reels approval/rejection |
| **DPO** | DSAR, retention policies |
| **Support** | Ticket management |
| **Security Admin** | Secrets, KMS rotation |

---

## 📦 Deliverables Summary

| Deliverable | Description |
|-------------|-------------|
| **Flutter Mobile App** | iOS & Android |
| **Firebase Backend** | Auth, Firestore, Storage, Functions |
| **Admin Backoffice** | Web-based management console |
| **API Documentation** | OpenAPI specs |
| **Privacy Policy** | In-app versioned policy |
| **User Guide** | Interactive onboarding |

---

## 🔗 Key Dependencies

### Story Dependencies Graph

```mermaid
graph TB
    LM2-001[Account Creation] --> LM2-002[Login]
    LM2-001 --> LM2-005[Profile]
    LM2-005 --> LM2-011[Child Profile]
    LM2-011 --> LM2-017[Timeline]
    LM2-017 --> LM2-023[Create Capsule]
    LM2-023 --> LM2-026[Gallery]
    LM2-023 --> LM2-039[Vaccination]
    LM2-004[Consent] --> LM2-044[Payment]
    LM2-044 --> LM2-107[Quotas]
    LM2-044 --> LM2-110[VIP Year 1]
    LM2-110 --> LM2-115[Voucher Album]
```

---

## 📝 Glossary

| Term | Definition |
|------|------------|
| **Capsule** | A memory unit containing photo + audio + metadata |
| **Milestone** | A predefined or custom life event |
| **Timeline** | Visual representation of milestones over time |
| **Jalon** | French for milestone |
| **VPC** | Vaccin Pneumocoque Conjugué |
| **DSAR** | Data Subject Access Request |
| **Entitlement** | A feature or benefit tied to a subscription plan |
| **Akika** | Traditional celebration for newborn in Islamic culture |

---

> **Note**: This documentation is based on the product backlog version **29-01-2026**. Features and priorities may evolve.

---

*Generated from data analysis: `Base des données Vaccin.csv`, `DATA BASE LINE DE VIE.csv`, `Luckymam_Backlog_V29-01-2026.csv`*
