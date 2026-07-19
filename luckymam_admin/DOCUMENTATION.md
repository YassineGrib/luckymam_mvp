# Luckymam Admin — Documentation technique

Tableau de bord backoffice pour l'application mobile Luckymam.
Projet indépendant, situé dans `luckymam_admin/` à la racine du monorepo.

> Pour la mise en route rapide (installation, variables d'environnement,
> premier déploiement), voir [`README.md`](./README.md). Ce document couvre
> l'architecture, le modèle de données, le modèle de sécurité et la feuille
> de route complète.

---

## Table des matières

1. [Contexte et objectif](#1-contexte-et-objectif)
2. [Architecture](#2-architecture)
3. [Structure du projet](#3-structure-du-projet)
4. [Fonctionnalités](#4-fonctionnalités)
5. [Modèle de données](#5-modèle-de-données)
6. [Modèle de sécurité](#6-modèle-de-sécurité)
7. [Installation et configuration](#7-installation-et-configuration)
8. [Workflow de développement](#8-workflow-de-développement)
9. [Déploiement](#9-déploiement)
10. [Synchronisation avec l'app Flutter](#10-synchronisation-avec-lapp-flutter)
11. [Feuille de route](#11-feuille-de-route)
12. [Dépannage](#12-dépannage)

---

## 1. Contexte et objectif

L'application mobile Luckymam (Flutter, `lib/` à la racine du repo) génère
des commandes réelles dans Firestore — impression d'albums photo, demandes
d'album VIP offert, commandes du marketplace partenaire — mais **aucune
interface n'existait pour les traiter**. Les règles Firestore originales
bloquaient toute modification de statut (`allow update, delete: if false`),
laissant chaque commande figée à l'état `pending` indéfiniment.

`luckymam_admin` résout ce problème en premier lieu (Phase 1 de la feuille
de route), puis sert de fondation pour un backoffice plus large : gestion du
catalogue marketplace, des publicités internes, du contenu Reels, etc.

**Décisions structurantes validées** (voir le plan d'implémentation complet
pour le raisonnement détaillé) :
- **Stack** : React + Vite + TypeScript, projet indépendant de `luckymam_web/`
  (la landing page marketing), mais reprenant ses conventions d'outillage
- **Hébergement** : Firebase Hosting multi-site, même projet Firebase
  (`luckymam-app-dv`) que l'app mobile, plan **Spark** (gratuit) suffisant —
  aucune Cloud Function n'est nécessaire pour ce périmètre
- **Remote config / feature flags** (besoins futurs) : adopter **Firebase
  Remote Config** nativement plutôt que construire des écrans sur mesure

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Firebase Project                         │
│                     luckymam-app-dv                          │
│                                                                │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────────┐  │
│  │ Firebase Auth│   │  Firestore   │   │ Firebase Hosting │  │
│  │  (1 seul pool│   │ (1 seule base│   │  (multi-site)    │  │
│  │  d'utilisa-  │   │  de données) │   │                  │  │
│  │  teurs pour  │   │              │   │  ┌────────────┐  │  │
│  │  mamans +    │   │              │   │  │ site: admin│  │  │
│  │  admins)     │   │              │   │  └────────────┘  │  │
│  └──────┬───────┘   └──────┬───────┘   └────────┬─────────┘  │
└─────────┼──────────────────┼────────────────────┼────────────┘
          │                  │                     │
          │   lecture/écriture directe (SDK JS)     │  sert le
          │   gated par firestore.rules             │  bundle
          │                                          │  statique
   ┌──────┴──────────────────┴──────────┐            │
   │        luckymam_admin (React)      │◄───────────┘
   │  - Auth email/mdp                  │
   │  - Claim personnalisé `admin: true`│
   │  - CRUD Firestore direct           │
   └─────────────────────────────────────┘

   ┌─────────────────────────────────────┐
   │     App mobile Flutter (lib/)        │
   │  - Même Firebase Auth pool           │
   │  - Écrit les commandes (create-only) │
   │  - Lit son propre statut en temps    │
   │    réel via des StreamProvider       │
   └─────────────────────────────────────┘
```

**Points clés :**
- **Aucun backend intermédiaire.** Le frontend admin parle directement au
  SDK Firestore JS — pas d'API REST/GraphQL à maintenir. La sécurité est
  entièrement portée par `firestore.rules`.
- **Aucune Cloud Function.** Auth, Firestore et Hosting sont tous gratuits
  sur le plan Spark. Le seul geste "serveur" est le script d'attribution du
  rôle admin (`scripts/setAdminClaim.mjs`), exécuté localement une fois par
  administrateur — jamais déployé.
- **Même projet Firebase que l'app mobile.** Les admins sont des comptes
  Firebase Auth ordinaires, distingués uniquement par un custom claim, avec
  des adresses email dédiées, jamais liées au flux d'inscription mobile.

### Stack technique

| Couche | Choix | Version |
|---|---|---|
| Framework UI | React | 19.x |
| Build tool | Vite | 8.x |
| Langage | TypeScript | 6.x (strict) |
| Style | Tailwind CSS | 4.x (`@theme` inline, pas de config JS séparée) |
| Routing | React Router | 7.x (`BrowserRouter`) |
| Backend | Firebase JS SDK | 12.x (`firebase/app`, `firebase/auth`, `firebase/firestore`) |
| Lint | ESLint (flat config) | miroir de `luckymam_web/eslint.config.js` |

---

## 3. Structure du projet

```
luckymam_admin/
├── scripts/
│   └── setAdminClaim.mjs        # script local (jamais déployé), attribue le claim admin
│                                  # nécessite scripts/service-account.json (gitignored)
├── src/
│   ├── lib/
│   │   ├── firebase.ts           # initializeApp() + exports auth/db, lit les env vars
│   │   ├── enums.ts               # statuts de commande — MIROIR MANUEL des enums Dart
│   │   └── orderTypes.ts           # interfaces TS — MIROIR MANUEL des modèles Dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── useAuth.ts          # hook : état Firebase Auth + claims (admin, role)
│   │   │   ├── LoginScreen.tsx      # formulaire email/mot de passe
│   │   │   └── RequireAdmin.tsx      # garde : n'affiche les enfants que si admin===true
│   │   │
│   │   └── orders/
│   │       ├── useOrderQueue.ts       # hook générique : flux temps réel d'une collection
│   │       ├── updateOrderStatus.ts    # écrit {status, statusUpdatedAt, statusUpdatedBy}
│   │       ├── StatusBadge.tsx          # pastille colorée de statut
│   │       ├── OrderQueueScreen.tsx      # composant générique liste + détail + transitions
│   │       ├── PrintOrdersScreen.tsx      # branche OrderQueueScreen sur print_orders
│   │       ├── AlbumClaimsScreen.tsx       # branche OrderQueueScreen sur album_claims
│   │       └── MarketplaceOrdersScreen.tsx  # branche OrderQueueScreen sur marketplace_orders
│   │
│   ├── components/
│   │   └── AppShell.tsx             # layout authentifié : nav latérale + déconnexion
│   │
│   ├── App.tsx                        # assemble RequireAdmin > BrowserRouter > routes
│   ├── main.tsx                        # point d'entrée React
│   ├── index.css                        # `@import "tailwindcss"` + palette de marque
│   └── vite-env.d.ts                     # typage des variables VITE_FIREBASE_*
│
├── public/
│   └── favicon.svg
│
├── .env.example                # gabarit des variables d'environnement (valeurs à copier)
├── .env.local                   # (gitignored) vraies valeurs Firebase — à créer localement
├── .gitignore                    # exclut node_modules, dist, .env*, service-account.json
├── package.json
├── vite.config.ts
├── tsconfig.json / tsconfig.app.json / tsconfig.node.json
├── eslint.config.js
├── README.md                       # guide de mise en route pas à pas
└── DOCUMENTATION.md                 # ce fichier
```

### Pourquoi un composant `OrderQueueScreen` générique ?

Les trois collections de commandes (`print_orders`, `album_claims`,
`marketplace_orders`) partagent exactement le même **pattern d'interaction**
(liste filtrable par statut → sélection → panneau détail → boutons de
transition) mais ont des **champs différents**. Plutôt que dupliquer la
liste/le filtre/les transitions trois fois, `OrderQueueScreen<T>` factorise
la partie commune et reçoit deux "render props" (`summaryLine`,
`renderDetails`) pour la partie spécifique à chaque type. Les trois écrans
concrets (`PrintOrdersScreen`, etc.) ne contiennent que la configuration
propre à leur collection — aucune duplication de logique UI.

---

## 4. Fonctionnalités

### 4.1 Authentification

- Connexion par email/mot de passe (`src/features/auth/LoginScreen.tsx`).
  Pas d'inscription publique, pas de connexion Google — les comptes admin
  sont créés manuellement dans la console Firebase (voir §7).
- `RequireAdmin` bloque l'accès à toute l'app tant que le token ID Firebase
  ne porte pas `admin: true`. Un compte connecté mais sans ce claim voit un
  message explicite avec un bouton de déconnexion — jamais un écran blanc
  ou une erreur Firestore silencieuse.
- Cette garde est **une aide UX, pas la sécurité réelle** — celle-ci vit
  dans `firestore.rules` (voir §6). Un bug dans `RequireAdmin` ne pourrait
  jamais exposer les données, seulement l'interface.

### 4.2 Console de traitement des commandes (Phase 1)

Trois écrans identiques dans leur structure, chacun branché sur sa
collection Firestore :

| Écran | Route | Collection | Statuts possibles |
|---|---|---|---|
| Commandes d'impression | `/` (index) | `print_orders` | pending → processing → shipped → delivered |
| Albums imprimés VIP | `/album-claims` | `album_claims` | pending → processing → shipped → delivered |
| Commandes Marketplace | `/marketplace-orders` | `marketplace_orders` | pending → confirmed → shipped → delivered, ou cancelled |

Pour chaque écran :
- **Colonne de gauche** — liste des commandes (temps réel via `onSnapshot`),
  triée par date de création décroissante, avec chips de filtre par statut
  et un badge de statut coloré par ligne.
- **Panneau de droite** — coordonnées client (nom, téléphone, wilaya,
  adresse) communes aux trois types, puis les champs spécifiques
  (ex. titre de l'album et nombre de pages pour une impression ; liste des
  articles et total pour une commande marketplace).
- **Boutons de transition de statut** — un bouton par statut valide de la
  collection ; le statut actuel est désactivé. Un clic écrit
  `{status, statusUpdatedAt, statusUpdatedBy}` sur le document.

**Répercussion côté mobile** : pour `marketplace_orders`, le changement est
visible instantanément dans l'app (le provider `myOrdersProvider` y est déjà
abonné en flux). Pour `print_orders` et `album_claims`, **aucun écran mobile
n'affiche le statut à ce jour** — l'app ne montre qu'un toast de succès à la
soumission. Le changement de statut est donc effectif côté données, mais
invisible pour la maman tant qu'un écran "Mes commandes" équivalent n'est
pas ajouté côté Flutter (fast-follow identifié, non planifié).

---

## 5. Modèle de données

Ce projet ne définit aucun schéma — il **consomme** les collections déjà
écrites par l'app Flutter, plus quelques collections préparées pour les
phases futures.

### 5.1 Collections consommées (Phase 1, déjà en production)

Les trois collections top-level suivantes sont écrites en `create` par
l'app mobile et lues/mises à jour en `status` uniquement par l'admin :

```ts
// src/lib/orderTypes.ts

interface BaseOrder {
  id: string
  userId: string
  fullName: string
  phone: string
  wilaya: string
  address: string
  status: string
  createdAt: string // ISO 8601
}

interface PrintOrder extends BaseOrder {
  childId: string
  childName: string
  albumId: string
  albumType: 'predefined' | 'standard'
  albumTitle: string
  pageCount: number
  isVipFree: boolean
}
// Source Dart : lib/features/print_album/models/print_order.dart

interface AlbumClaim extends BaseOrder {
  childId: string
  childName: string
  dateRange: string
}
// Source Dart : lib/features/subscription/models/subscription_models.dart (classe AlbumClaim)

interface MarketplaceOrderLine {
  productId: string
  productName: string
  partnerId: string
  unitPriceDZD: number
  quantity: number
  lineTotalDZD: number
}

interface MarketplaceOrder extends BaseOrder {
  lines: MarketplaceOrderLine[]
  totalDZD: number
}
// Source Dart : lib/features/marketplace/models/marketplace_order.dart
```

Après une transition de statut, l'admin ajoute deux champs supplémentaires
(non présents dans les modèles Dart d'origine, ajoutés uniquement par le
côté admin) :
- `statusUpdatedAt` (Firestore `serverTimestamp()`)
- `statusUpdatedBy` (uid de l'admin ayant fait la transition)

### 5.2 Collections préparées mais non encore utilisées (Phase 2)

Les règles Firestore (`firestore.rules`, racine du repo) déclarent déjà ces
quatre collections en lecture-authentifiée / écriture-admin, en prévision
du backoffice de contenu — **aucun code (admin ou mobile) ne les lit ou
écrit encore** :

- `marketplace_products`, `marketplace_partners` — remplaceront à terme
  `lib/features/marketplace/data/marketplace_data.dart` (données statiques
  aujourd'hui)
- `house_ads` — remplacera `lib/features/ads/data/house_ads_data.dart`
- `reels` — remplacera la liste statique initiale de
  `lib/features/reels/providers/reels_provider.dart`

Ces règles étant additives et inertes tant qu'aucune donnée n'existe dans
ces collections, les avoir préparées maintenant évite un second cycle de
revue/déploiement de règles lors de la Phase 2.

---

## 6. Modèle de sécurité

### 6.1 Principe : custom claim, vérifié côté serveur

```js
// firestore.rules — racine du repo
function isAdmin() {
  return request.auth != null && request.auth.token.admin == true;
}
```

- Le claim `admin: true` est attribué via Firebase Admin SDK
  (`setCustomUserClaims`), jamais par un document Firestore — impossible à
  falsifier depuis le client, contrairement à un champ `role` dans
  `users/{uid}`.
- **Un seul point d'attribution** : `scripts/setAdminClaim.mjs`, exécuté
  localement avec une clé de compte de service. Aucune interface (mobile ou
  admin) ne peut s'auto-attribuer ce claim.
- Le claim n'apparaît dans le token ID qu'après un rafraîchissement
  (déconnexion/reconnexion, ou `getIdTokenResult(true)` — c'est ce que fait
  `useAuth.ts` à chaque changement d'état d'authentification).

### 6.2 Règle en défense en profondeur sur les commandes

Un admin peut **lire** l'intégralité d'une commande, mais ne peut **écrire**
que trois champs précis, jamais le contenu métier :

```js
allow update: if isAdmin()
  && request.resource.data.diff(resource.data).affectedKeys()
       .hasOnly(['status', 'statusUpdatedAt', 'statusUpdatedBy'])
  && request.resource.data.status in ['pending', 'processing', 'shipped', 'delivered'];
allow delete: if false;
```

Deux garanties combinées :
1. `affectedKeys().hasOnly([...])` — même avec un bug côté client (un champ
   en trop envoyé par erreur dans l'objet de mise à jour), Firestore rejette
   l'écriture si elle touche un champ hors de la liste blanche.
2. `status in [...]` — impossible d'écrire une valeur de statut arbitraire ;
   la liste correspond exactement à l'enum Dart de la collection concernée
   (`marketplace_orders` a en plus `confirmed` et `cancelled`).
3. `allow delete: if false` — **absolu, aucune exception admin**. Une
   commande ne peut jamais être supprimée depuis le client, admin ou non :
   c'est une trace d'audit immuable.

### 6.3 Ce que ce modèle ne couvre pas encore

- **Un seul rôle** (`admin`, booléen). Le champ `role` est déjà écrit par le
  script (`{admin: true, role: 'admin'}`) mais n'est lu nulle part dans les
  règles actuelles — préparation pour la Phase 4 (RBAC), pas encore
  appliqué.
- **Pas de journal d'audit général.** `statusUpdatedBy` donne une traçabilité
  minimale par document, mais pas d'historique consultable des actions
  admin dans le temps (voir Phase 4).
- **Pas de limitation de débit ni de détection d'anomalie** sur les actions
  admin — acceptable pour une équipe d'un seul admin, à revisiter avant
  d'ouvrir l'accès à plusieurs personnes.

---

## 7. Installation et configuration

Voir [`README.md`](./README.md) pour la procédure complète pas à pas
(enregistrement de la Web App Firebase, clé de compte de service, création
du site Hosting, premier compte admin). Résumé :

```bash
cd luckymam_admin
npm install
cp .env.example .env.local   # puis éditer avec les vraies valeurs Firebase
npm run dev
```

Variables d'environnement requises (`.env.local`, jamais commité) :

| Variable | Où la trouver |
|---|---|
| `VITE_FIREBASE_API_KEY` | Console Firebase → Web App enregistrée |
| `VITE_FIREBASE_AUTH_DOMAIN` | pré-rempli : `luckymam-app-dv.firebaseapp.com` |
| `VITE_FIREBASE_PROJECT_ID` | pré-rempli : `luckymam-app-dv` |
| `VITE_FIREBASE_STORAGE_BUCKET` | pré-rempli : `luckymam-app-dv.firebasestorage.app` |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | pré-rempli : `834179717761` |
| `VITE_FIREBASE_APP_ID` | Console Firebase → Web App enregistrée |

`src/lib/firebase.ts` lève une erreur explicite au démarrage si `apiKey` ou
`appId` sont vides, plutôt que d'échouer silencieusement plus loin dans
l'app.

---

## 8. Workflow de développement

```bash
npm run dev       # serveur de dev Vite, http://localhost:5173, HMR
npm run lint       # ESLint (flat config), doit rester à 0 erreur
npm run build        # tsc -b (vérification de types stricte) puis vite build → dist/
npm run preview        # sert dist/ localement, pour valider un build de prod
npm run set-admin-claim -- <uid> [role]   # voir §6.1
```

**Conventions** :
- Un fichier = un composant ou un hook, nommé en `PascalCase.tsx` pour les
  composants, `camelCase.ts` pour les hooks/utilitaires.
- Pas de gestion d'état globale (Redux/Zustand) — la portée du projet ne le
  justifie pas. Chaque écran gère son propre état via `useState`/hooks
  locaux ; Firestore lui-même sert de source de vérité partagée via
  `onSnapshot`.
- Tailwind utilisé directement dans le JSX (pas de CSS Modules ni de
  styled-components) — cohérent avec `luckymam_web/`.
- Les couleurs de marque (`magenta-pink`, `smalt-blue`, etc.) sont définies
  dans `src/index.css` via `@theme`, en miroir de
  `lib/core/theme/app_colors.dart` côté Flutter.

---

## 9. Déploiement

```bash
npm run build
cd ..   # racine du repo
firebase deploy --only hosting:admin --project luckymam-app-dv
```

Après toute modification de `firestore.rules` (racine du repo) :

```bash
firebase deploy --only firestore:rules --project luckymam-app-dv
```

⚠️ **Toujours relire le diff de `firestore.rules` avant de déployer** — une
règle mal formée peut soit bloquer l'app mobile en production, soit ouvrir
un accès non désiré. Aucun déploiement n'est automatisé (pas de CI/CD sur ce
repo à ce jour).

Le site Hosting `admin` doit avoir été créé une fois au préalable
(`firebase hosting:sites:create luckymam-admin` puis
`firebase target:apply hosting admin luckymam-admin`) — voir README §3.

---

## 10. Synchronisation avec l'app Flutter

Ce projet ne partage **aucun code** avec l'app Flutter (pas de package
partagé, pas de génération de types automatique). Deux fichiers portent
volontairement des commentaires pointant vers leur source Dart, à mettre à
jour à la main en cas de changement :

| Fichier TS | Source Dart | Contenu à garder synchronisé |
|---|---|---|
| `src/lib/enums.ts` | `print_order.dart`, `subscription_models.dart`, `marketplace_order.dart` | valeurs d'énumération des statuts de commande |
| `src/lib/orderTypes.ts` | idem | noms et types des champs des modèles |

**Pourquoi pas un package partagé ?** Évalué et écarté pour l'instant : le
repo est un unique `pubspec.yaml` monolithique (pas de workspace melos), et
extraire les modèles en package partagé aurait retardé la Phase 1 (urgente)
pour un bénéfice limité à ~6 champs de statut au total. À reconsidérer si le
nombre de types synchronisés grandit significativement.

**En pratique** : toute modification d'un des trois modèles Dart concernés
(ajout de champ, renommage, nouvelle valeur de statut) doit être répercutée
manuellement dans ces deux fichiers TypeScript. Aucun test automatisé ne
détecte une désynchronisation aujourd'hui — vérification visuelle requise
lors de la revue de code.

---

## 11. Feuille de route

État actuel : **Phase 0 et Phase 1 livrées.** Le plan complet (raisonnement,
alternatives écartées, liste des tickets différés) est conservé dans
l'historique de planification du projet ; résumé ici :

| Phase | Contenu | Statut |
|---|---|---|
| 0 — Fondations | Scaffold, auth, garde de route, règles `isAdmin()`, config Hosting | ✅ Livré |
| 1 — Console de commandes | 3 files de traitement (impression, albums VIP, marketplace) | ✅ Livré |
| 2 — Backoffice contenu | CRUD Marketplace (produits/partenaires), Publicités internes, Reels — migration des données statiques Dart vers Firestore | ⬜ Non démarré |
| 3 — CMS Calendrier Vaccinal | Édition du calendrier vaccinal algérien sans release app, versionnement léger | ⬜ Non démarré |
| 4 — RBAC léger + audit log | Rôles `admin`/`ops`, collection `admin_audit_logs` | ⬜ Non démarré, à ne lancer qu'avec un 2ᵉ admin réel |

**Fast-follow identifié (hors phases)** : ajouter un écran "Mes commandes"
côté Flutter pour `print_orders` et `album_claims`, sur le modèle de
`my_orders_screen.dart` (marketplace) — aujourd'hui ces deux types de
commande n'ont aucune visibilité de statut côté maman.

**Explicitement différé** (nécessite une décision produit/légale/business
séparée, hors périmètre de ce projet) : codes promo, campagnes push,
demandes DSAR, politiques de rétention, observabilité/crash reporting,
gestion de versions forcée, tickets support, modération de contenu,
rotation de secrets/clés KMS, système d'entitlements généralisé, console
d'abonnements liée à un paiement. Raison détaillée pour chacun dans le plan
d'implémentation d'origine.

---

## 12. Dépannage

**"Missing Firebase config" au démarrage** — `.env.local` absent ou
incomplet. Copier `.env.example` → `.env.local` et renseigner `apiKey` et
`appId` depuis la console Firebase (§7).

**Connexion réussie mais message "droits d'administration" refusés** — le
claim n'a pas été attribué, ou l'a été *après* la dernière connexion. Lancer
`npm run set-admin-claim -- <uid>` puis se déconnecter/reconnecter dans
l'app (le token n'est pas rafraîchi automatiquement en continu).

**Une commande n'apparaît pas dans la liste** — vérifier que le document a
bien un champ `createdAt` au format ISO 8601 (`useOrderQueue` trie par ce
champ ; un document sans `createdAt` valide peut être exclu du tri ou
provoquer une erreur de requête si un index composite est requis).

**Erreur "Missing or insufficient permissions" en écrivant un statut** —
vérifier (1) que le claim `admin` est bien présent dans le token actuel
(`useAuth` doit renvoyer `status: 'admin'`), et (2) que la mise à jour
n'envoie *que* `status`/`statusUpdatedAt`/`statusUpdatedBy` — tout champ
supplémentaire fait échouer la règle `hasOnly(...)` (voir §6.2).

**`firebase deploy --only hosting:admin` échoue avec "no target" ou
similaire** — le site Hosting n'a pas encore été créé/associé. Revoir
README §3 (`firebase hosting:sites:create` + `firebase target:apply`).
