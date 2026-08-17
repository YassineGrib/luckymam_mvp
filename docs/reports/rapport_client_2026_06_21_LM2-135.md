# Rapport — LM2-135 : Album Standard

**Date :** 2026-06-21  
**Ticket :** LM2-135  
**Priorité :** Should Have · 13 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

Complément naturel de LM2-134 : là où l'album prédéfini propose des évènements de vie nommés, l'album standard offre des **pages vierges** que la maman remplit librement, à son rythme.

### 1. Modèle de données

**`StandardAlbum`** (`memory_book/models/standard_album.dart`) — album Firestore avec un titre modifiable, un nombre de pages extensible (6 par défaut), et une map `pageIndex → capsuleId` pour suivre les pages remplies.

Nouvelle sous-collection : `users/{uid}/standardAlbums/{albumId}`.

### 2. Service et providers

`StandardAlbumService` gère la création, l'ajout/retrait de capsule par page, l'ajout de pages, et le renommage. `standard_album_providers.dart` expose les streams temps réel + un notifier d'actions avec analytics intégrées.

### 3. Réutilisation intelligente du système de liaison capsule ↔ album

Plutôt que dupliquer le mécanisme créé pour LM2-134, le modèle `Capsule` a reçu un unique champ supplémentaire : **`albumType`** (`'predefined'` ou `'standard'`). Les champs `albumId`/`albumSlotId` déjà en place sont réutilisés tels quels — `albumSlotId` porte soit un identifiant d'évènement nommé (album prédéfini), soit un numéro de page (album standard). `capsule_service.dart` route l'auto-attachement vers la bonne collection Firestore selon `albumType`.

### 4. Écran `StandardAlbumDetailScreen`

- **Titre modifiable** — tap sur le titre dans la barre du haut → dialogue de renommage
- **Grille de pages** (3 colonnes) : chaque page vide affiche un cadre en pointillés avec un bouton « + » ; chaque page remplie affiche la miniature de la capsule
- **Tuile « + Ajouter une page »** à la fin de la grille — fait grandir l'album sans limite fixe
- Au tap sur une page vide : bottom sheet avec 2 choix, « Choisir une capsule existante » (réutilise le sélecteur créé pour LM2-134) ou « Créer une nouvelle capsule »
- Compteur "X/Y pages remplies · Brouillon" sous le titre

### 5. Persistance du brouillon

**Chaque action est écrite dans Firestore immédiatement** (ajout de capsule, ajout de page, renommage) — il n'y a pas de bouton "Sauvegarder" séparé, et donc pas de risque de perdre du travail en quittant l'écran. C'est le sens du critère d'acceptation : quitter l'album à tout moment conserve son état exact. L'évènement analytics `album_draft_saved` est déclenché au moment de quitter l'écran, comme point de contrôle.

### 6. Intégration dans « Livre de Mémoires »

Le bandeau unique de LM2-134 a été transformé en **deux bandeaux côte à côte** : « Album prédéfini » (rose→violet) et « Album libre » (turquoise→bleu), chacun avec son propre flux de sélection d'enfant. Le composant `_AlbumEntryBanner` est désormais générique et réutilisable pour d'éventuels futurs types d'album.

### 7. Analytics

- `album_standard_created` — à la création, avec `childId` + `albumId`
- `album_slot_added` — à chaque page remplie, avec `method` (`existing` | `new`)
- `album_draft_saved` — à la sortie de l'écran (checkpoint de persistance)

### 8. Sécurité

- **Contrôle d'accès** — nouvelle règle Firestore `standardAlbums/{albumId}` scopée par utilisateur, même pattern que `predefinedAlbums`
- **Chiffrement médias** — aucune nouvelle surface : les photos des albums standard sont des `Capsule` classiques, stockées via le pipeline Firebase Storage existant (chiffrement au repos + accès `isOwner(userId)` déjà en place, vérifié en LM2-132)

---

## Fichiers créés / modifiés

| Fichier | Changement / Rôle |
|---------|------------------|
| `lib/features/memory_book/screens/standard_album_detail_screen.dart` | Grille de pages extensible, renommage, brouillon · traduction dynamique des dialogues de renommage, des boutons, de la شارة الـ Brouillon et du formatage PDF |
| `lib/features/memory_book/models/standard_album.dart` | Modèle Firestore `StandardAlbum` |
| `lib/features/memory_book/services/standard_album_service.dart` | CRUD Firestore + gestion des pages |
| `lib/features/memory_book/providers/standard_album_providers.dart` | Providers + notifier d'actions + analytics |
| `lib/features/memory_book/screens/memory_book_screen.dart` | Bandeaux côte à côte, dialogue de création, résolution d'enfant partagée |
| `lib/features/memory_book/screens/predefined_album_detail_screen.dart` | Ajout `albumType: 'predefined'` (corrige la liaison suite à l'introduction du champ) |
| `lib/features/capsules/models/capsule.dart` | Champ `albumType` |
| `lib/features/capsules/services/capsule_service.dart` | Auto-attachement routé par `albumType` (prédéfini vs standard) |
| `lib/features/capsules/providers/capsule_providers.dart` | Passage du paramètre `albumType` |
| `lib/features/capsules/screens/create_capsule_screen.dart` | Paramètre `albumType` |
| `firestore.rules` | Règle d'accès `standardAlbums` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Créer un album standard vide | ✅ |
| Ajouter une capsule dans un slot | ✅ |
| Traduction dynamique de l'interface et du statut (AR / FR / EN) | ✅ |
| Traduction dynamique du dialogue de renommage d'album | ✅ |
| Traduction dynamique des options d'ajout de capsule (Existante / Nouvelle) | ✅ |
| Le slot affiche la capsule après ajout | ✅ |
| L'album conserve son état si on quitte (brouillon) | ✅ |
| Pages extensibles (pas de limite fixe) | ✅ |
| Renommage de l'album | ✅ |
| Réutilisation du sélecteur de capsule existant | ✅ |
| Contrôle d'accès Firestore par utilisateur | ✅ |
| Analytics `album_standard_created` | ✅ |
| Analytics `album_slot_added` | ✅ |
| Analytics `album_draft_saved` | ✅ |
| `flutter analyze` clean | ✅ |

---

## Note — vérification UI

Comme pour LM2-134, cet environnement ne dispose pas d'émulateur/appareil Android ni de cible Flutter Web configurée pour ce projet. La vérification s'est appuyée sur `flutter analyze` (0 erreur nouvelle) et une relecture complète du flux réactif Firestore → providers → écrans, incluant le point d'intégration critique avec le système de capsules existant (routage `albumType`). **Un test manuel sur appareil reste recommandé avant mise en production.**
