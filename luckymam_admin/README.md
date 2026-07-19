# Luckymam Admin

Tableau de bord backoffice — React + Vite + TypeScript + Tailwind + Firebase.

Ce README couvre la mise en route technique pas à pas. Pour l'architecture,
le modèle de données, le modèle de sécurité et la feuille de route complète,
voir [`DOCUMENTATION.md`](./DOCUMENTATION.md).

## Prérequis (à faire une seule fois, par un développeur avec accès à la
console Firebase du projet `luckymam-app-dv`)

### 1. Enregistrer une Web App Firebase

L'app Android existe déjà dans ce projet Firebase, mais aucune Web App n'est
enregistrée. Sans ça, `firebase/app`'s `initializeApp()` n'a pas de config
valide.

1. [Console Firebase](https://console.firebase.google.com/) → `luckymam-app-dv`
   → ⚙️ Paramètres du projet → onglet Général
2. Sous "Vos applications" → cliquer l'icône Web `</>`
3. Nom : `Luckymam Admin` — **ne pas** cocher "Configurer aussi Firebase Hosting"
   ici (on le fait via CLI, voir plus bas)
4. Copier les valeurs `firebaseConfig` affichées

```bash
cp .env.example .env.local
# éditer .env.local avec les valeurs copiées (apiKey, appId — le reste est déjà pré-rempli)
```

### 2. Compte de service (pour le script d'attribution des droits admin)

1. Console Firebase → Paramètres du projet → Comptes de service
2. "Générer une nouvelle clé privée" → télécharge un JSON
3. Sauvegarder ce fichier sous `scripts/service-account.json`
   (⚠️ gitignored — ne jamais committer)

### 3. Créer le site Hosting dédié à l'admin (nécessite `firebase login`)

```bash
npm install -g firebase-tools   # si pas déjà installé
firebase login
firebase hosting:sites:create luckymam-admin --project luckymam-app-dv
firebase target:apply hosting admin luckymam-admin --project luckymam-app-dv
```

Cette dernière commande écrit l'entrée `"targets"` manquante dans
`.firebaserc` (racine du repo) — elle n'a volontairement pas été pré-remplie
ici car le site n'existait pas encore.

### 4. Déployer les règles Firestore mises à jour

`firestore.rules` (racine du repo) a été modifié pour ajouter `isAdmin()` et
les permissions backoffice. **Vérifier le diff avant de déployer** :

```bash
cd ..   # racine du repo
firebase deploy --only firestore:rules --project luckymam-app-dv
```

### 5. Créer le premier compte admin

1. Console Firebase → Authentication → Users → "Add user" (email + mot de
   passe, distinct de tout compte "maman")
2. Copier son UID
3. Depuis `luckymam_admin/` :

```bash
npm run set-admin-claim -- <uid>
```

4. Se connecter avec ce compte dans l'app — **si déjà connecté au moment de
   l'attribution du droit, se déconnecter/reconnecter** (le claim custom
   n'apparaît qu'après un rafraîchissement du token).

## Développement

```bash
npm install
npm run dev        # http://localhost:5173
npm run lint
npm run build       # tsc -b && vite build → dist/
```

## Déploiement

```bash
npm run build
cd ..
firebase deploy --only hosting:admin --project luckymam-app-dv
```

## Structure

```
src/
  lib/
    firebase.ts       # init Firebase (Auth + Firestore) depuis les env vars
    enums.ts           # statuts de commande, miroir manuel des enums Dart
    orderTypes.ts       # types miroir des modèles Dart (print_order.dart, etc.)
  features/
    auth/               # login, garde de route (useAuth, RequireAdmin)
    orders/              # file de commandes générique (print/album/marketplace)
  components/
    AppShell.tsx         # layout authentifié (nav + déconnexion)
scripts/
  setAdminClaim.mjs       # script local, jamais déployé — voir Prérequis §2/§5
```

## Notes de synchronisation avec l'app Flutter

`src/lib/enums.ts` et `src/lib/orderTypes.ts` sont des **miroirs manuels**
des modèles Dart (`lib/features/print_album/models/print_order.dart`,
`lib/features/marketplace/models/marketplace_order.dart`,
`lib/features/subscription/models/subscription_models.dart`). Toute
modification des champs ou des valeurs d'énumération côté Flutter doit être
répercutée ici — ce sont deux petits fichiers à tenir à jour à la main, pas
un package partagé.
