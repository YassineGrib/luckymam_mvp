# Rapport de Livraison — Luckymam
## LM2-118 · Consentement Loi 18-07

---

> **Client :** Luckymam  
> **Date :** 20 Juin 2026  
> **Ticket :** LM2-118  
> **Épic :** Privacy & Compliance  
> **Statut :** Livré ✅

---

## Résumé

La fonctionnalité de collecte de consentement conforme à la **Loi Algérienne n° 18-07** a été intégralement implémentée et vérifiée. L'utilisatrice doit obligatoirement accepter les termes légaux avant d'accéder à l'application, et chaque consentement est enregistré de manière sécurisée et infalsifiable dans Firebase.

---

## Ce qui a été livré

### 1. Écran de consentement dédié

Un écran `Law1807ConsentScreen` affiche le texte légal complet de la Loi 18-07 dans la langue active de l'utilisatrice (FR / AR / EN), avec :

- Texte scrollable dans un conteneur dédié
- **Contrôle de défilement obligatoire (Scroll-to-bottom)** : La case à cocher « J'accepte la Loi 18/07 » reste grisée, verrouillée et désactivée tant que l'utilisatrice n'a pas fait défiler le texte légal jusqu'au bas du conteneur.
- Référence légale officielle en bas du texte, localisée dynamiquement en 3 langues.
- Case à cocher obligatoire « J'accepte la Loi 18/07 » (activée après défilement).
- Bouton « Continuer » activé seulement après acceptation.
- Support RTL complet pour l'arabe.

### 2. Blocage de navigation & Enforcements

Si l'utilisatrice tente de cocher ou de continuer sans respecter les conditions :
- La progression est bloquée.
- Si elle essaie de cliquer sur la case verrouillée avant d'avoir fait défiler jusqu'au bas, un message d'avertissement localisé (SnackBar) s'affiche : *« Veuillez faire défiler le texte légal jusqu'en bas pour pouvoir accepter. »*
- Un message d'erreur localisé s'affiche si elle tente de valider sans cocher : *« L'acceptation de la Loi 18/07 est obligatoire pour continuer. »*
- L'événement analytics `law1807_blocked` est enregistré.

### 3. Enregistrement du consentement

Lors de l'acceptation, deux écritures Firestore sont effectuées :

| Destination | Contenu |
|-------------|---------|
| `/users/{uid}` | `consent1807: true`, `consent1807Timestamp`, `consent1807TextVersion` |
| `/consent_logs` | Audit log complet avec userId, consent, timestamp, texte intégral, version, hash, plateforme |

### 4. Hash d'intégrité (anti-falsification)

Chaque enregistrement d'audit contient un **Hash FNV-1a 64-bit** calculé de façon déterministe à partir de `userId + timestamp + textVersion`. Toute altération du log invalide l'empreinte.

### 5. Règles Firestore (immuabilité)

La collection `/consent_logs` est configurée en **écriture unique** côté serveur :
- `create` : autorisé uniquement par l'utilisateur authentifié
- `update` / `delete` : **interdits définitivement**

### 6. Parcours utilisateur sécurisé

Tous les points d'entrée vérifient le consentement avant redirection vers `/home` :

| Point d'entrée | Comportement |
|----------------|-------------|
| Connexion email | Redirige vers `/law-consent` si pas encore consenti |
| Connexion Google | Redirige vers `/law-consent` si pas encore consenti |
| Démarrage app (Splash) | Redirige vers `/law-consent` si utilisateur connecté sans consentement |

### 7. Tracking analytics

| Événement | Déclencheur |
|-----------|-------------|
| `law1807_viewed` | À l'ouverture de l'écran |
| `law1807_accepted` | Après acceptation et sauvegarde réussie |
| `law1807_blocked` | Tentative de continuer sans cocher |

---

## Critères d'acceptation — Vérification

| Scénario | Résultat |
|----------|----------|
| Blocage sans acceptation de la case | ✅ Vérifié |
| Message d'erreur clair affiché | ✅ Vérifié |
| Progression autorisée après acceptation | ✅ Vérifié |
| `consent=true` sauvegardé | ✅ Vérifié |
| Timestamp sauvegardé | ✅ Vérifié |
| Version du texte sauvegardée (`18-07-v1`) | ✅ Vérifié |
| Audit log immuable côté serveur | ✅ Vérifié |
| Hash d'intégrité présent | ✅ Vérifié |
| Support RTL (arabe) | ✅ Vérifié |
| 3 langues (FR / AR / EN) | ✅ Vérifié |
| Défilement obligatoire (Scroll-to-bottom) | ✅ Activé (case verrouillée tant que le scroll n'est pas au bas) |
| Message d'avertissement de défilement | ✅ Activé (SnackBar localisée en 3 langues) |
| Analytics 3 événements | ✅ Vérifié |

---

## Fichiers modifiés

| Fichier | Rôle |
|---------|------|
| `lib/features/auth/law_1807_consent_screen.dart` | Écran de consentement |
| `lib/core/services/compliance_service.dart` | Logique sauvegarde + hash |
| `lib/core/services/analytics_service.dart` | Événements analytics |
| `lib/features/splash/splash_screen.dart` | Vérification au démarrage |
| `lib/features/auth/login_screen.dart` | Vérification post-connexion email |
| `lib/features/auth/signup_screen.dart` | Vérification post-inscription |
| `firestore.rules` | Règles immuabilité `consent_logs` |
| `lib/l10n/app_fr.arb` · `app_ar.arb` · `app_en.arb` | Textes légaux traduits |
