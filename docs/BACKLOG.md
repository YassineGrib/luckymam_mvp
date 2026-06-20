# Luckymam — Product Backlog V2 (29-01-2026)

> **Légende priorités :** 🔴 Must · 🟠 Should · 🟡 Could  
> **Phases :** M1-M3 · M4-M6 · M7-M9 · M10-M12  
> **SP** = Story Points

---

## 1. Onboarding & Compte

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-001 | Création de compte | 🔴 Must | 8 | M1-M3 |
| LM2-002 | Connexion | 🔴 Must | 5 | M1-M3 |
| LM2-003 | Reset mot de passe | 🔴 Must | 5 | M1-M3 |
| LM2-004 | Consentements granulaires | 🔴 Must | 8 | M1-M3 |
| LM2-006 | Suppression compte | 🔴 Must | 13 | M4-M6 |
| LM2-007 | Export données (ZIP chiffré) | 🔴 Must | 8 | M4-M6 |
| LM2-008 | 2FA SMS/OTP | 🟡 Could | 8 | M4-M6 |
| LM2-009 | SSO Apple/Google | 🟠 Should | 8 | M4-M6 |
| LM2-010 | Mode invité (capsules locales) | 🟡 Could | 8 | M7-M9 |

### LM2-001 — Création de compte
**User Story :** En tant qu'utilisatrice, je veux créer un compte (email/tel)  
**Description :** Compte + vérification OTP + mot de passe fort  
**Critères d'acceptation :**
- Given nouvelle utilisatrice When je saisis email/tel + mdp fort Then OTP envoyé et compte créé non-vérifié

**Données personnelles :** Email / Tel  
**Sécurité :** Hash mdp + OTP expirable + rate-limit  
**Analytics :** `signup_started`, `signup_completed`  
**i18n :** FR / AR

---

### LM2-002 — Connexion
**User Story :** En tant qu'utilisatrice, je veux me connecter  
**Description :** Sessions + logout  
**Critères d'acceptation :**
- Given compte vérifié When login Then jeton délivré
- And lock après 5 échecs

**Dépendances :** LM2-001  
**Données personnelles :** Email / Tel  
**Sécurité :** JWT + refresh + lockout  
**Analytics :** `login_success`, `login_failed`  
**i18n :** FR / AR

---

### LM2-003 — Reset mot de passe
**User Story :** En tant qu'utilisatrice, je veux réinitialiser mon mot de passe  
**Description :** Lien/OTP expirable one-time  
**Critères d'acceptation :**
- Given oubli When je demande reset Then lien/OTP expirable one-time

**Dépendances :** LM2-001  
**Données personnelles :** Email / Tel  
**Sécurité :** Token one-time  
**Analytics :** `pw_reset_requested`, `pw_reset_done`  
**i18n :** FR / AR

---

### LM2-004 — Consentements granulaires
**User Story :** En tant qu'utilisatrice, je veux gérer mes consentements  
**Description :** Consentements granulaires (analytics, push, IA)  
**Critères d'acceptation :**
- Given 1er lancement When je choisis Then seules finalités acceptées actives
- And retrait stoppe collecte immédiatement

**Dépendances :** LM2-001  
**Données personnelles :** Consentement  
**Sécurité :** Preuve consentement horodatée  
**Analytics :** `consent_saved`  
**i18n :** FR / AR

---

### LM2-006 — Suppression compte
**User Story :** En tant qu'utilisatrice, je veux supprimer mon compte  
**Description :** Suppression + période de grâce + purge  
**Critères d'acceptation :**
- Given je confirme Then état pending delete
- And purge après N jours

**Dépendances :** LM2-004  
**Données personnelles :** Toutes données  
**Sécurité :** Purge + audit  
**Analytics :** `account_delete_requested`  
**i18n :** FR / AR

---

### LM2-007 — Export données
**User Story :** En tant qu'utilisatrice, je veux exporter mes données  
**Description :** ZIP chiffré + lien expirable  
**Critères d'acceptation :**
- Given export When prêt Then lien signé expirable
- And ZIP chiffré

**Dépendances :** LM2-004  
**Données personnelles :** Toutes données  
**Sécurité :** Chiffrement + URL signée  
**Analytics :** `data_export_requested`  
**i18n :** FR / AR

---

### LM2-008 — 2FA
**User Story :** En tant qu'utilisatrice, je veux activer une 2FA  
**Description :** 2FA SMS/OTP  
**Critères d'acceptation :**
- Given 2FA active When nouvel appareil Then 2e facteur requis

**Dépendances :** LM2-002  
**Données personnelles :** Tel  
**Sécurité :** MFA  
**Analytics :** `2fa_enabled`  
**i18n :** FR / AR

---

### LM2-009 — SSO Apple/Google
**User Story :** En tant qu'utilisatrice, je veux me connecter via Apple/Google  
**Description :** OAuth SSO  
**Critères d'acceptation :**
- Given SSO When j'autorise Then compte créé/lié avec données minimales

**Données personnelles :** Email SSO  
**Sécurité :** OAuth nonce  
**Analytics :** `sso_done`  
**i18n :** FR / AR

---

### LM2-010 — Mode invité
**User Story :** En tant qu'utilisatrice, je veux tester sans compte  
**Description :** Capsules locales only  
**Critères d'acceptation :**
- Given invité When je crée capsule Then stockage local
- And import possible après signup

**Données personnelles :** Médias locaux  
**Sécurité :** Isolation locale  
**Analytics :** `guest_mode_start`  
**i18n :** FR / AR

---

## 2. Onboarding & Profil

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-005 | Profil maman | 🔴 Must | 8 | M1-M3 |

### LM2-005 — Profil maman
**User Story :** En tant qu'utilisatrice, je veux compléter mon profil  
**Description :** Statut enceinte/maman + dates + langue  
**Critères d'acceptation :**
- Given profil When je saisis dates Then phase calculée et timeline personnalisée

**Dépendances :** LM2-001  
**Données personnelles :** Données santé (dates)  
**Sécurité :** Chiffrement au repos  
**Analytics :** `profile_completed`  
**i18n :** FR / AR

---

## 3. Famille

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-011 | Créer profil enfant | 🔴 Must | 8 | M1-M3 |
| LM2-012 | Modifier profil enfant | 🔴 Must | 5 | M1-M3 |
| LM2-013 | Niveau de confidentialité | 🟠 Should | 8 | M7-M9 |
| LM2-014 | Inviter un proche (lecture seule) | 🟠 Should | 13 | M7-M9 |
| LM2-015 | Localisation capsule (opt-in) | 🟠 Should | 5 | M4-M6 |
| LM2-016 | Floutage visage avant partage | 🟡 Could | 8 | M10-M12 |

### LM2-011 — Créer profil enfant
**User Story :** En tant que maman, je veux créer un profil enfant  
**Description :** Multi-enfants + profil par défaut Lucky  
**Critères d'acceptation :**
- Given onboarding fini When j'ajoute enfant Then profil créé
- If skip Then profil Lucky par défaut

**Dépendances :** LM2-005  
**Données personnelles :** Données enfant (dates)  
**Sécurité :** Chiffrement + RBAC  
**Analytics :** `child_added`  
**i18n :** FR / AR

---

### LM2-012 — Modifier profil enfant
**User Story :** En tant que maman, je veux modifier un profil enfant  
**Description :** Recalcul automatique des jalons  
**Critères d'acceptation :**
- Given profil When je modifie date Then timeline se recalcule

**Dépendances :** LM2-011  
**Données personnelles :** Données enfant  
**Sécurité :** Audit trail  
**Analytics :** `child_updated`  
**i18n :** FR / AR

---

### LM2-013 — Niveau de confidentialité
**User Story :** En tant que maman, je veux définir la confidentialité par enfant  
**Description :** Privé / famille / partage limité  
**Critères d'acceptation :**
- Given niveau When je change Then options partage s'ajustent

**Dépendances :** LM2-011  
**Sécurité :** RBAC  
**Analytics :** `privacy_level_set`  
**i18n :** FR / AR

---

### LM2-014 — Inviter un proche
**User Story :** En tant que maman, je veux inviter le papa en lecture seule  
**Description :** Accès famille avec révocation possible  
**Critères d'acceptation :**
- Given invite When acceptée Then accès limité
- And révocation possible à tout moment

**Dépendances :** LM2-001  
**Données personnelles :** Email invité  
**Sécurité :** RBAC + audit  
**Analytics :** `family_invite_sent`  
**i18n :** FR / AR

---

### LM2-015 — Localisation capsule
**User Story :** En tant que maman, je veux activer/désactiver la localisation  
**Description :** Lieu optionnel, opt-in  
**Critères d'acceptation :**
- Given toggle off Then aucun GPS collecté
- Given toggle on Then précision choisie par l'utilisatrice

**Dépendances :** LM2-031  
**Données personnelles :** GPS  
**Sécurité :** Opt-in strict  
**Analytics :** `location_toggle`  
**i18n :** FR / AR

---

### LM2-016 — Floutage partage
**User Story :** En tant que maman, je veux flouter un visage avant partage  
**Description :** Protection de l'enfant, traitement local  
**Critères d'acceptation :**
- Given partage social When flou actif Then export flouté

**Dépendances :** LM2-004  
**Données personnelles :** Images enfants  
**Sécurité :** Traitement local  
**Analytics :** `share_blur_enabled`  
**i18n :** FR / AR

---

## 4. Timeline

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-017 | Vue timeline | 🔴 Must | 8 | M1-M3 |
| LM2-018 | Détails jalon | 🔴 Must | 5 | M1-M3 |
| LM2-019 | Jalons personnalisés | 🟠 Should | 8 | M7-M9 |
| LM2-020 | Mode offline | 🟠 Should | 8 | M4-M6 |
| LM2-021 | Règles jalons (admin) | 🔴 Must | 13 | M4-M6 |
| LM2-022 | Rollback règles (admin) | 🔴 Must | 8 | M4-M6 |

### LM2-017 — Vue timeline
**User Story :** En tant que maman, je veux voir les jalons du jour et à venir  
**Description :** Timeline adaptative selon profil  
**Critères d'acceptation :**
- Given profil actif When ouverture Then jalon du jour affiché

**Dépendances :** LM2-011  
**Données personnelles :** Dates  
**Sécurité :** Règles signées  
**Analytics :** `timeline_opened`  
**i18n :** FR / AR

---

### LM2-018 — Détails jalon
**User Story :** En tant que maman, je veux ouvrir un jalon  
**Description :** Description + CTA capsule  
**Critères d'acceptation :**
- Given jalon When open Then description + bouton créer capsule

**Dépendances :** LM2-017  
**Analytics :** `milestone_opened`  
**i18n :** FR / AR

---

### LM2-019 — Jalons personnalisés
**User Story :** En tant que maman, je veux ajouter mes propres événements  
**Description :** Custom milestones avec notification optionnelle  
**Critères d'acceptation :**
- Given ajout When validé Then événement apparaît dans la timeline
- And peut déclencher une notification

**Dépendances :** LM2-017  
**Données personnelles :** Titre / notes  
**Sécurité :** Validation input  
**Analytics :** `custom_milestone_added`  
**i18n :** FR / AR

---

### LM2-020 — Mode offline
**User Story :** En tant que maman, je veux accéder à l'app sans connexion  
**Description :** Cache timeline & capsules, sync au retour  
**Critères d'acceptation :**
- Given no network When open Then cache affiché
- And sync automatique au retour réseau

**Dépendances :** LM2-031  
**Sécurité :** Chiffrement local  
**Analytics :** `offline_mode`  
**i18n :** FR / AR

---

### LM2-021 — Règles jalons (admin)
**User Story :** En tant qu'admin, je veux publier des règles de jalons  
**Description :** CMS règles versionné  
**Critères d'acceptation :**
- Given publish When live Then clients rafraîchissent
- And rollback possible

**Admin/Backoffice :** Oui  
**Données personnelles :** Pays / culture  
**Sécurité :** RBAC + versioning  
**Analytics :** `rules_published`  
**i18n :** FR / AR

---

### LM2-022 — Rollback règles (admin)
**User Story :** En tant qu'admin, je veux effectuer un rollback de version  
**Description :** Rollback instantané vers version N-1  
**Critères d'acceptation :**
- Given incident When rollback Then version N-1 appliquée immédiatement

**Dépendances :** LM2-021  
**Admin/Backoffice :** Oui  
**Sécurité :** Audit log  
**Analytics :** `rules_rollback`  
**i18n :** FR / AR

---

## 5. Capsules

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-023 | Créer capsule | 🔴 Must | 13 | M1-M3 |
| LM2-024 | Importer photo galerie | 🔴 Must | 8 | M1-M3 |
| LM2-025 | Favoris | 🟠 Should | 3 | M1-M3 |
| LM2-026 | Galerie (grille + timeline) | 🔴 Must | 8 | M1-M3 |
| LM2-027 | Filtres (date/émotion/enfant) | 🔴 Must | 8 | M1-M3 |
| LM2-028 | Édition capsule | 🟠 Should | 8 | M4-M6 |
| LM2-029 | Corbeille (soft delete 30j) | 🔴 Must | 8 | M4-M6 |
| LM2-030 | Partage lien expirable | 🟠 Should | 8 | M4-M6 |
| LM2-031 | Partage social (sans EXIF) | 🟠 Should | 8 | M7-M9 |
| LM2-032 | Coffre (PIN/biométrie) | 🟡 Could | 13 | M10-M12 |

### LM2-023 — Créer capsule
**User Story :** En tant que maman, je veux créer une capsule photo + audio + émotion  
**Description :** 1 photo + 1 audio (≤ 25 s) + émotion/tags. Lecture audio via bouton Play sur la photo.  
**Critères d'acceptation :**
- Given je suis sur "Nouvelle capsule" When je prends une photo Then une prévisualisation s'affiche
- And When j'enregistre un audio Then la durée est bloquée à 25 s max
- And When je valide Then la capsule est sauvegardée localement puis synchronisée
- And Then si quota capsules OU quota stockage atteint Then création bloquée + message + CTA upgrade
- And Then l'audio est lu uniquement quand j'appuie sur le bouton "Lecture" sur la photo

**Dépendances :** LM2-002  
**Données personnelles :** Photo + audio  
**Sécurité :** Upload signé + chiffrement  
**Analytics :** `capsule_created`  
**i18n :** FR / AR

---

### LM2-024 — Importer photo
**User Story :** En tant que maman, je veux utiliser une photo existante de ma galerie  
**Critères d'acceptation :**
- Given permission accordée When import Then capsule créée avec la photo

**Dépendances :** LM2-016  
**Données personnelles :** Photo  
**Sécurité :** Permission minimale  
**Analytics :** `capsule_imported`  
**i18n :** FR / AR

---

### LM2-025 — Favoris
**User Story :** En tant que maman, je veux ajouter une capsule aux favoris  
**Critères d'acceptation :**
- Given cœur When toggle Then favoris mis à jour

**Dépendances :** LM2-023  
**Analytics :** `favorite_toggled`  
**i18n :** FR / AR

---

### LM2-026 — Galerie
**User Story :** En tant que maman, je veux voir mes capsules en grille et timeline  
**Description :** Pagination + cache  
**Critères d'acceptation :**
- Given galerie When open Then chargement progressif

**Dépendances :** LM2-023  
**Sécurité :** Caching  
**Analytics :** `gallery_opened`  
**i18n :** FR / AR

---

### LM2-027 — Filtres
**User Story :** En tant que maman, je veux filtrer mes capsules  
**Description :** Filtres combinés par date / émotion / enfant  
**Critères d'acceptation :**
- Given filtre When appliqué Then liste mise à jour

**Dépendances :** LM2-024  
**Analytics :** `filter_applied`  
**i18n :** FR / AR

---

### LM2-028 — Édition capsule
**User Story :** En tant que maman, je veux éditer une capsule existante  
**Description :** Versioning  
**Critères d'acceptation :**
- Given edit When save Then nouvelle version créée + possibilité d'annuler

**Dépendances :** LM2-023  
**Données personnelles :** Médias  
**Sécurité :** Versioning  
**Analytics :** `capsule_edited`  
**i18n :** FR / AR

---

### LM2-029 — Corbeille
**User Story :** En tant que maman, je veux supprimer et restaurer une capsule  
**Description :** Soft delete 30 jours  
**Critères d'acceptation :**
- Given delete When confirm Then mise en corbeille
- And restore possible dans les 30 jours

**Dépendances :** LM2-023  
**Données personnelles :** Médias  
**Sécurité :** Retention policy  
**Analytics :** `capsule_deleted`, `capsule_restored`  
**i18n :** FR / AR

---

### LM2-030 — Partage lien
**User Story :** En tant que maman, je veux partager via un lien expirable  
**Description :** Lecture seule, lien signé 7 jours  
**Critères d'acceptation :**
- Given share When 7 j Then lien signé
- And après expiration accès refusé

**Dépendances :** LM2-023  
**Données personnelles :** Contenu partagé  
**Sécurité :** URL signée  
**Analytics :** `share_link_created`  
**i18n :** FR / AR

---

### LM2-031 — Partage social
**User Story :** En tant que maman, je veux partager sur les réseaux sociaux  
**Description :** Export sans EXIF + watermark  
**Critères d'acceptation :**
- Given social share When confirm Then export nettoyé (sans EXIF)
- And audio opt-in

**Dépendances :** LM2-028  
**Données personnelles :** Médias  
**Sécurité :** Strip EXIF  
**Analytics :** `share_social`  
**i18n :** FR / AR

---

### LM2-032 — Coffre
**User Story :** En tant que maman, je veux verrouiller des capsules sensibles  
**Description :** PIN / biométrie  
**Critères d'acceptation :**
- Given coffre When open Then biométrie requise

**Dépendances :** LM2-002  
**Données personnelles :** Médias  
**Sécurité :** Keystore / Secure Enclave  
**Analytics :** `vault_enabled`  
**i18n :** FR / AR

---

## 6. Reels

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-033 | Flux reels | 🟠 Should | 8 | M7-M9 |
| LM2-034 | Filtrer par thème | 🟠 Should | 5 | M7-M9 |
| LM2-035 | Signaler un reel | 🔴 Must | 5 | M7-M9 |
| LM2-036 | Admin — Uploader reel | 🔴 Must | 13 | M7-M9 |
| LM2-037 | Admin — Valider reel | 🔴 Must | 13 | M7-M9 |
| LM2-038 | Admin — Planifier publication | 🟡 Could | 5 | M10-M12 |

### LM2-033 — Flux reels
**User Story :** En tant que maman, je veux scroller des reels validés  
**Description :** Lecture auto + sous-titres activables  
**Critères d'acceptation :**
- Given reels When scroll Then autoplay
- And sous-titres activables

**Données personnelles :** Usage  
**Sécurité :** CDN / DRM  
**Analytics :** `reel_view`  
**i18n :** FR / AR

---

### LM2-034 — Filtrer reels
**User Story :** En tant que maman, je veux filtrer par thème  
**Critères d'acceptation :**
- Given filtre When sélection Then flux mis à jour

**Dépendances :** LM2-033  
**Analytics :** `reel_filter`  
**i18n :** FR / AR

---

### LM2-035 — Signaler un reel
**User Story :** En tant que maman, je veux signaler un reel inapproprié  
**Critères d'acceptation :**
- Given report When envoyé Then ticket créé

**Sécurité :** Audit  
**Analytics :** `reel_reported`  
**i18n :** FR / AR

---

### LM2-036 — Admin : Uploader reel
**User Story :** En tant qu'admin, je veux uploader un reel  
**Critères d'acceptation :**
- Given upload When fini Then preview généré

**Admin/Backoffice :** Oui  
**Sécurité :** Antivirus + RBAC  
**Analytics :** `admin_reel_uploaded`  
**i18n :** FR / AR

---

### LM2-037 — Admin : Valider reel
**User Story :** En tant que reviewer, je veux approuver ou refuser un reel  
**Critères d'acceptation :**
- Given review When approuvé Then publié
- And refus avec commentaire obligatoire

**Admin/Backoffice :** Oui  
**Sécurité :** RBAC + audit  
**Analytics :** `reel_approved`  
**i18n :** FR / AR

---

### LM2-038 — Admin : Planifier publication
**User Story :** En tant qu'admin, je veux planifier une publication  
**Critères d'acceptation :**
- Given planif When date atteinte Then publié automatiquement

**Dépendances :** LM2-037  
**Admin/Backoffice :** Oui  
**Sécurité :** RBAC  
**Analytics :** `reel_scheduled`  
**i18n :** FR / AR

---

## 7. Santé

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-039 | Calendrier vaccinal (DZ) | 🔴 Must | 8 | M4-M6 |
| LM2-040 | Rappel RDV vaccins | 🔴 Must | 8 | M4-M6 |
| LM2-041 | Marquer vaccin effectué | 🟠 Should | 8 | M7-M9 |
| LM2-042 | Admin — Gérer calendriers | 🔴 Must | 13 | M7-M9 |

### LM2-039 — Calendrier vaccinal
**User Story :** En tant que maman, je veux voir le calendrier vaccinal par âge  
**Description :** Calendrier Algérie par défaut  
**Critères d'acceptation :**
- Given âge de l'enfant When open Then doses listées

**Dépendances :** LM2-011  
**Données personnelles :** Données santé  
**Sécurité :** Contenu versionné  
**Analytics :** `vax_calendar_open`  
**i18n :** FR / AR

---

### LM2-040 — Rappel RDV vaccins
**User Story :** En tant que maman, je veux des rappels pour les vaccins  
**Description :** Notification + snooze  
**Critères d'acceptation :**
- Given rappel When snooze Then reprogrammé

**Dépendances :** LM2-033  
**Données personnelles :** Dates  
**Sécurité :** Opt-in push  
**Analytics :** `vax_reminder_set`  
**i18n :** FR / AR

---

### LM2-041 — Marquer vaccin effectué
**User Story :** En tant que maman, je veux marquer un vaccin comme effectué  
**Description :** Photo carnet optionnelle  
**Critères d'acceptation :**
- Given done When confirm Then statut mis à jour

**Dépendances :** LM2-023  
**Données personnelles :** Photo doc médical  
**Sécurité :** Chiffrement  
**Analytics :** `vax_marked_done`  
**i18n :** FR / AR

---

### LM2-042 — Admin : Gérer calendriers
**User Story :** En tant qu'admin, je veux éditer les calendriers par pays  
**Description :** CRUD + version  
**Critères d'acceptation :**
- Given publish When live Then clients mis à jour

**Admin/Backoffice :** Oui  
**Sécurité :** RBAC + audit  
**Analytics :** `admin_vax_published`  
**i18n :** FR / AR

---

## 8. Monétisation

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-043 | Offre premium (comparatif plans) | 🔴 Must | 5 | M1-M3 |
| LM2-044 | Checkout abonnement | 🔴 Must | 13 | M4-M6 |
| LM2-045 | Code promo | 🟠 Should | 5 | M4-M6 |
| LM2-107 | Quotas & règles (enforcement) | 🔴 Must | 13 | M4-M6 |
| LM2-108 | Statut abonnement | 🔴 Must | 5 | M4-M6 |
| LM2-109 | Renouvellement Premium | 🔴 Must | 8 | M7-M9 |
| LM2-110 | VIP année 1 | 🔴 Must | 8 | M7-M9 |
| LM2-111 | Renouvellement VIP | 🔴 Must | 8 | M7-M9 |
| LM2-112 | Expiration & downgrade | 🔴 Must | 13 | M7-M9 |
| LM2-115 | Voucher album VIP | 🟠 Should | 13 | M10-M12 |

### LM2-043 — Offre premium
**User Story :** En tant qu'utilisatrice, je veux voir les plans disponibles  
**Description :** Comparatif clair des 3 plans + quotas + avantages  
**Critères d'acceptation :**
- Given j'ouvre l'écran Plans Then je vois 3 offres :
  - **Freemium** : 25 capsules
  - **Premium (annuel)** : 1 990 DA/an, 100 capsules
  - **VIP** : 150 000 DA la 1ère année (capsules illimitées + 1 album offert), puis 3 990 DA/an
- And Then les conditions de renouvellement/expiration sont affichées clairement

**Analytics :** `plan_viewed`  
**i18n :** FR / AR

---

### LM2-044 — Checkout abonnement
**User Story :** En tant qu'utilisatrice, je veux payer (CIB / Edahabia / CCP / code)  
**Description :** Paiement local — gestion pending/success/fail + reçu  
**Critères d'acceptation :**
- Given je choisis un plan payant When je valide Then je sélectionne un moyen (CIB / Edahabia / CCP / code)
- And Given paiement success Then statut → Actif + reçu généré
- And Given paiement pending Then statut Pending ; features payantes non activées
- And Given paiement fail Then je reste sur mon plan actuel + erreur claire

**Données personnelles :** Paiement  
**Sécurité :** Tokenisation PSP  
**Analytics :** `payment_success`  
**i18n :** FR / AR

---

### LM2-045 — Code promo
**User Story :** En tant qu'utilisatrice, je veux appliquer un code promo  
**Critères d'acceptation :**
- Given code When valide Then réduction appliquée

**Dépendances :** LM2-062  
**Sécurité :** Anti-fraude  
**Analytics :** `promo_applied`  
**i18n :** FR / AR

---

### LM2-107 — Quotas & règles
**User Story :** En tant qu'utilisatrice, je veux que mon quota soit appliqué automatiquement  
**Description :** Enforcement du quota mixte (capsules)  
**Critères d'acceptation :**
- Given Freemium When j'atteins 25 capsules Then bouton créer bloqué + CTA upgrade
- Given Premium When j'atteins 100 capsules Then même comportement
- Given VIP Then aucune limite affichée (fair-use interne)

**Dépendances :** LM2-023, LM2-085, LM2-043  
**Sécurité :** Contrôle serveur + cohérence client  
**Analytics :** `quota_blocked`  
**i18n :** FR / AR

---

### LM2-108 — Statut abonnement
**User Story :** En tant qu'utilisatrice, je veux voir le statut de mon abonnement  
**Critères d'acceptation :**
- Given je suis dans Compte When j'ouvre Abonnement Then je vois statut + date fin + plan
- And When abonnement expiré Then message + options renouveler

**Dépendances :** LM2-044  
**Analytics :** `subscription_status_viewed`  
**i18n :** FR / AR

---

### LM2-109 — Renouvellement Premium
**User Story :** En tant qu'utilisatrice, je veux renouveler mon Premium annuel  
**Description :** 1 990 DA/an  
**Critères d'acceptation :**
- Given Premium actif When J-30 / J-7 / J-1 Then notification envoyée
- When je renouvelle et paiement success Then nouvelle date fin = +1 an

**Dépendances :** LM2-044  
**Sécurité :** Idempotence paiement  
**Analytics :** `premium_renewed`  
**i18n :** FR / AR

---

### LM2-110 — VIP année 1
**User Story :** En tant qu'utilisatrice, je veux souscrire au VIP la première année  
**Description :** VIP 1ère année : 150 000 DA — capsules illimitées + 1 album offert (voucher unique) + perks VIP  
**Critères d'acceptation :**
- Given je choisis VIP (année 1) When paiement success Then statut VIP actif 12 mois
- And Then capsules deviennent illimitées (fair-use interne)
- And Then un voucher "Album offert" (1 utilisation) est créé (album + livraison Algérie) et visible dans Compte
- And Then les entitlements VIP année 1 sont appliqués

**Dépendances :** LM2-044, LM2-043  
**Note :** Album offert UNIQUEMENT la 1ère année (150 000 DA)  
**Données personnelles :** Paiement  
**Sécurité :** Tokenisation PSP  
**Analytics :** `vip_year1_started`  
**i18n :** FR / AR

---

### LM2-111 — Renouvellement VIP
**User Story :** En tant qu'utilisatrice, je veux renouveler VIP à un tarif différent  
**Description :** VIP renouvellement : 3 990 DA/an à partir de l'année 2 — pas d'album offert  
**Critères d'acceptation :**
- Given VIP arrive à échéance When je renouvelle Then prix affiché = 3 990 DA/an
- And When paiement success Then VIP renouvelé 12 mois
- And Then capsules restent illimitées (fair-use interne)
- And Then aucun voucher album n'est créé
- And Then seules les entitlements de renouvellement (perks admin) sont appliquées

**Dépendances :** LM2-110, LM2-044  
**Sécurité :** Idempotence + anti-fraude  
**Analytics :** `vip_renewed`  
**i18n :** FR / AR

---

### LM2-112 — Expiration & downgrade
**User Story :** En tant qu'utilisatrice, je veux comprendre ce qui se passe si mon abonnement expire  
**Critères d'acceptation :**
- Given Premium/VIP expire When date fin dépassée Then plan devient Freemium
- And If nb_capsules > 25 Then mode lecture seule + CTA renouveler/exporter
- And If dans les limites Then usage normal Freemium

**Dépendances :** LM2-107, LM2-108  
**Sécurité :** Règles côté serveur  
**Analytics :** `subscription_expired`  
**i18n :** FR / AR

---

### LM2-115 — Voucher album VIP
**User Story :** En tant qu'utilisatrice VIP (année 1), je veux bénéficier d'un album offert  
**Description :** Voucher "1 album offert" (album + livraison) valable uniquement en Algérie  
**Critères d'acceptation :**
- Given je deviens VIP année 1 When activation Then voucher 100% créé (1 usage)
- And Then le voucher couvre album ET livraison en Algérie
- And Given je renouvelle VIP année 2+ Then aucun nouveau voucher créé
- And Given je commande When j'applique le voucher Then total album = 0 et livraison = 0
- And Then après utilisation le voucher passe à "consommé" et ne peut plus être réutilisé

**Dépendances :** LM2-110  
**Note :** Album offert + livraison offerte UNIQUEMENT en Algérie  
**Sécurité :** Anti-fraude voucher  
**Analytics :** `vip_voucher_used`  
**i18n :** FR / AR

---

## 9. Admin Promo & Plateforme

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-046 | Créer code promo | 🔴 Must | 13 | M4-M6 |
| LM2-047 | Remote config | 🟠 Should | 8 | M7-M9 |
| LM2-048 | Feature flags | 🟠 Should | 8 | M7-M9 |
| LM2-049 | Push campaigns segmentées | 🟠 Should | 8 | M7-M9 |
| LM2-050 | Audit logs | 🟠 Should | 8 | M7-M9 |
| LM2-051 | DSAR (accès/suppression) | 🟠 Should | 8 | M7-M9 |
| LM2-052 | Rétention données | 🟠 Should | 8 | M7-M9 |
| LM2-053 | Observabilité crash/latence | 🟠 Should | 8 | M7-M9 |
| LM2-054 | Gestion versions (force update) | 🟠 Should | 8 | M7-M9 |
| LM2-055 | Support tickets | 🟠 Should | 8 | M7-M9 |
| LM2-056 | Rôles & permissions RBAC | 🟠 Should | 8 | M7-M9 |
| LM2-057 | Modération signalements | 🟠 Should | 8 | M7-M9 |
| LM2-058 | Gestion commandes albums | 🟠 Should | 8 | M7-M9 |
| LM2-059 | Gestion secrets / rotation | 🟠 Should | 8 | M7-M9 |
| LM2-113 | Entitlements par plan | 🔴 Must | 13 | M7-M9 |
| LM2-114 | Gestion VIP perks | 🟠 Should | 8 | M10-M12 |
| LM2-117 | Console abonnements | 🟠 Should | 13 | M10-M12 |

> Toutes ces features sont **Admin/Backoffice : Oui** avec **RBAC + audit** obligatoire.

---

## 10. Engagement & Notifications

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-080 | Centre de notifications (inbox) | 🟠 Should | 8 | M4-M6 |
| LM2-081 | Snooze rappel | 🔴 Must | 5 | M1-M3 |
| LM2-082 | Fréquence / quiet hours | 🟠 Should | 5 | M4-M6 |
| LM2-083 | Deep links depuis notif | 🔴 Must | 5 | M4-M6 |
| LM2-084 | Campagnes lifecycle | 🟠 Should | 8 | M7-M9 |

### LM2-083 — Deep links
**User Story :** En tant que maman, je veux ouvrir directement une capsule depuis une notification  
**Critères d'acceptation :**
- Given notif When tap Then écran cible s'ouvre même après cold start

**Dépendances :** LM2-023  
**Sécurité :** Validation deep links  
**Analytics :** `deeplink_open`  
**i18n :** FR / AR

---

## 11. Paramètres

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-085 | Gestion stockage & quota | 🔴 Must | 8 | M4-M6 |
| LM2-086 | Wi-Fi only upload | 🟠 Should | 5 | M4-M6 |
| LM2-087 | Cache reels offline | 🟡 Could | 8 | M10-M12 |
| LM2-088 | Langue FR/AR/EN | 🔴 Must | 5 | M1-M3 |
| LM2-089 | Accessibilité taille texte | 🔴 Must | 8 | M1-M3 |

### LM2-085 — Gestion stockage
**User Story :** En tant que maman, je veux voir mon quota et nettoyer  
**Description :** Affichage quota mixte selon plan + alertes + nettoyage  
**Critères d'acceptation :**
- Given je suis dans Paramètres > Stockage When j'ouvre Then je vois X/limite capsules
- And la limite est MIXTE : le premier seuil atteint bloque la création
- And Given j'atteins 80% Then alerte douce
- And Given j'atteins 90% Then alerte forte + actions (nettoyer / supprimer / upgrade)
- And When je supprime des capsules Then compteurs mis à jour

**Dépendances :** LM2-023  
**Analytics :** `storage_viewed`  
**i18n :** FR / AR

---

## 12. Découverte

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-090 | Recherche capsules | 🟠 Should | 8 | M7-M9 |
| LM2-091 | Recommandations albums auto | 🟡 Could | 8 | M10-M12 |
| LM2-092 | Tutoriel interactif (coach marks) | 🟠 Should | 5 | M1-M3 |
| LM2-093 | Widget "moment du jour" | 🟡 Could | 13 | M10-M12 |

---

## 13. Privacy

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-094 | Politique confidentialité in-app | 🔴 Must | 3 | M1-M3 |
| LM2-095 | Journal des accès (security log) | 🟠 Should | 8 | M7-M9 |
| LM2-096 | Consentement avant partage social | 🟠 Should | 3 | M7-M9 |

---

## 14. Security

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-097 | Détection jailbreak/root | 🟡 Could | 13 | M10-M12 |
| LM2-098 | Protection screenshots (coffre) | 🟡 Could | 8 | M10-M12 |

---

## 15. Qualité & Compliance

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-060 | Accessibilité WCAG AA | 🔴 Must | 5 | M1-M3 |
| LM2-061 | RTL Arabe parfait | 🔴 Must | 5 | M1-M3 |
| LM2-062 | Performance (3G) | 🔴 Must | 5 | M1-M3 |
| LM2-063 | Crash reporting | 🔴 Must | 5 | M1-M3 |
| LM2-064 | Privacy center | 🔴 Must | 5 | M1-M3 |
| LM2-065 | Consent IA | 🟠 Should | 5 | M1-M3 |
| LM2-066 | Minimisation données | 🔴 Must | 5 | M1-M3 |
| LM2-067 | Chiffrement local médias | 🔴 Must | 5 | M1-M3 |
| LM2-068 | Rate limiting API | 🔴 Must | 5 | M1-M3 |
| LM2-069 | Sécurité uploads (scan) | 🟠 Should | 5 | M1-M3 |
| LM2-070 | Backups & restore testés | 🔴 Must | 5 | M1-M3 |
| LM2-071 | CI/CD (tests + a11y + security) | 🔴 Must | 5 | M1-M3 |
| LM2-072 | Tests E2E clés | 🔴 Must | 5 | M1-M3 |
| LM2-073 | Feature telemetry / KPI | 🟠 Should | 5 | M1-M3 |
| LM2-074 | A/B testing (privacy-friendly) | 🟡 Could | 5 | M1-M3 |
| LM2-075 | RGPD logs traitements | 🟠 Should | 5 | M1-M3 |
| LM2-076 | Politique cookies/SDK | 🔴 Must | 5 | M1-M3 |
| LM2-077 | Data retention automatique | 🔴 Must | 5 | M1-M3 |
| LM2-078 | Mode parental | 🟡 Could | 5 | M1-M3 |
| LM2-079 | Export album PDF (sans commande) | 🟡 Could | 5 | M1-M3 |

---

## 16. Album Papier

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-104 | Prévisualisation PDF | 🟠 Should | 8 | M10-M12 |
| LM2-105 | Sauvegarder brouillon album | 🟠 Should | 5 | M10-M12 |
| LM2-106 | Code promo album | 🟡 Could | 5 | M10-M12 |
| LM2-116 | Commander album imprimé | 🔴 Must | 21 | M10-M12 |

### LM2-116 — Commander album
**User Story :** En tant que maman, je veux commander un album imprimé  
**Description :** Commande avec adresse Algérie, paiement ou voucher VIP, suivi commande  
**Critères d'acceptation :**
- Given j'ai un album prêt When je clique Commander Then je saisis une adresse en Algérie
- And When adresse hors Algérie Then voucher VIP ne peut pas être appliqué
- And When j'ai un voucher VIP année 1 valide Then je peux l'appliquer au checkout
- And When voucher appliqué Then total album = 0 et livraison = 0
- And When paiement success (ou total = 0) Then commande créée (status = Payée) + reçu
- And Then je vois le suivi : Préparation / Expédié / Livré

**Dépendances :** LM2-104, LM2-105, LM2-044  
**Note :** Livraison offerte en Algérie uniquement (voucher VIP)  
**Données personnelles :** Adresse  
**Sécurité :** Chiffrement + RBAC  
**Analytics :** `order_created`  
**i18n :** FR / AR

---

## 17. Admin Release & Analytics

| ID | Feature | Priorité | SP | Phase |
|----|---------|----------|----|-------|
| LM2-099 | Notes de version in-app | 🟠 Should | 5 | M7-M9 |
| LM2-100 | Mode maintenance | 🟠 Should | 8 | M7-M9 |
| LM2-101 | Catalogue events analytics | 🔴 Must | 8 | M1-M3 |
| LM2-102 | Registre traitements (RoPA) | 🟠 Should | 8 | M4-M6 |
| LM2-103 | Gestion clés KMS (rotation) | 🔴 Must | 13 | M4-M6 |

---

## Récapitulatif par phase

| Phase | IDs | SP total estimé |
|-------|-----|----------------|
| **M1-M3** | 001-005, 011-012, 017-018, 023-027, 043, 060-079, 081, 088-089, 092, 094, 101 | ~180 |
| **M4-M6** | 006-008, 015, 020-022, 028-030, 039-040, 044-046, 080, 082-083, 085-086, 102-103, 107-108 | ~195 |
| **M7-M9** | 009, 013-014, 019, 031, 033-037, 041-042, 047-059, 084, 090, 095-096, 099-100, 109-113 | ~270 |
| **M10-M12** | 010, 016, 032, 038, 087, 091, 093, 097-098, 104-106, 114-117 | ~145 |

---

*Dernière mise à jour : 29-01-2026 — Version 2*
