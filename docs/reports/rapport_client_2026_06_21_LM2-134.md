# Rapport — LM2-134 : Album Prédéfini

**Date :** 2026-06-21  
**Ticket :** LM2-134  
**Priorité :** Should Have · 13 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

Fonctionnalité complète construite de bout en bout : modèles de données, service Firestore, providers Riverpod, écrans, intégration dans l'app existante, et règles de sécurité.

### 1. Modèles d'album prédéfini

**`AlbumTemplate` / `AlbumEventSlot`** (`memory_book/models/album_template.dart`) — définissent un modèle d'album statique : titre, icône, dégradé de couleur, et une liste d'évènements (slots) à remplir.

**3 modèles de contenu réel** créés dans `memory_book/data/album_templates_data.dart` :

| Modèle | Évènements |
|--------|-----------|
| **Album de Naissance** | Premier cri, Première mise au sein, Bracelet de naissance, Premier bain, Retour à la maison, Vaccin de naissance |
| **Première Année** | Premier sourire, Premières dents, Premiers pas, Premiers mots, 1er anniversaire |
| **Aqiqa & Traditions** | Aqiqa, Circoncision, Premier Aïd |

**`PredefinedAlbum`** — modèle Firestore de l'instance créée par l'utilisatrice pour un enfant donné, avec une map `slotId → capsuleId` pour suivre le remplissage.

### 2. Service et persistance Firestore

Nouvelle sous-collection `users/{uid}/predefinedAlbums/{albumId}` avec `PredefinedAlbumService` :
- `createAlbum()` — instancie un modèle pour un enfant
- `attachCapsuleToSlot()` / `clearSlot()` — remplit/vide un évènement
- `watchAlbumsForChild()` / `watchAlbum()` — streams temps réel

### 3. Intégration avec le système de capsules existant

Le modèle `Capsule` a été étendu avec `albumId` + `albumSlotId` (même pattern que `milestoneId`/`vaccineGroupId` déjà en place). Résultat : quand une nouvelle capsule est créée pour un évènement d'album, elle est **automatiquement attachée au bon slot** dans `capsule_service.dart` — pas d'étape manuelle supplémentaire.

`CreateCapsuleScreen` accepte désormais `albumId` + `albumSlotId` en paramètres optionnels, en plus des paramètres existants.

### 4. Écrans

**`AlbumTemplatePickerScreen`** — liste des 3 modèles sous forme de cartes dégradées, avec nombre d'évènements. Tap → dialogue de confirmation → création Firestore → navigation directe vers l'album créé.

**`PredefinedAlbumDetailScreen`** — en-tête hero avec dégradé du modèle + compteur "X/Y évènements remplis", puis liste des évènements :
- **Évènement rempli** → vignette photo + badge vert "Souvenir attaché" → tap ouvre la capsule
- **Évènement vide** → icône + titre + description + **2 boutons** : « Existante » (ouvre un sélecteur de capsules) ou « Nouvelle » (ouvre la création de capsule pré-liée)

**`CapsulePickerSheet`** — bottom sheet en grille montrant toutes les capsules existantes de l'enfant, pour attacher une capsule déjà prise à un évènement.

### 5. Intégration dans l'app (« Livre de Mémoires »)

Un bandeau dégradé « 🎁 Album prédéfini » a été ajouté en haut de l'écran Livre de Mémoires (accessible depuis l'accueil), au-dessus des albums auto-générés existants. Au tap :
- **1 seul enfant** → ouvre directement le sélecteur de modèles
- **Plusieurs enfants** → bottom sheet pour choisir l'enfant concerné
- **Aucun enfant** → message invitant à en ajouter un

### 6. Analytics

- `album_template_selected` — à la création d'un album, avec `templateId` + `childId`
- `album_event_slot_filled` — à chaque évènement rempli, avec `albumId`, `slotId`, et `method` (`existing` ou `new`) pour distinguer les deux parcours

### 7. Sécurité

- **Contrôle d'accès** — nouvelle règle Firestore `predefinedAlbums/{albumId}` scopée par `request.auth.uid == userId`, identique au pattern déjà validé pour `capsules`/`vaccinations` (LM2-132)
- **Liens sécurisés** — aucune nouvelle surface d'exposition : les photos restent servies via les URLs Firebase Storage authentifiées existantes, pas de lien public généré
- **Respect du privacy level** — le contenu de l'album (capsules) reste soumis aux mêmes règles d'accès par utilisateur que le reste de l'app ; aucun partage externe n'est introduit par cette fonctionnalité

---

## Fichiers créés / modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/memory_book/models/album_template.dart` | Nouveau — `AlbumTemplate`, `AlbumEventSlot` |
| `lib/features/memory_book/data/album_templates_data.dart` | Nouveau — 3 modèles, 14 évènements au total |
| `lib/features/memory_book/models/predefined_album.dart` | Nouveau — modèle Firestore `PredefinedAlbum` |
| `lib/features/memory_book/services/predefined_album_service.dart` | Nouveau — CRUD Firestore |
| `lib/features/memory_book/providers/predefined_album_providers.dart` | Nouveau — providers + notifier d'actions + analytics |
| `lib/features/memory_book/screens/album_template_picker_screen.dart` | Nouveau — sélection de modèle |
| `lib/features/memory_book/screens/predefined_album_detail_screen.dart` | Nouveau — remplissage des évènements |
| `lib/features/memory_book/widgets/capsule_picker_sheet.dart` | Nouveau — sélecteur de capsule existante |
| `lib/features/memory_book/screens/memory_book_screen.dart` | Bandeau d'entrée + sélection d'enfant |
| `lib/features/capsules/models/capsule.dart` | Champs `albumId` / `albumSlotId` |
| `lib/features/capsules/services/capsule_service.dart` | Auto-attachement à l'évènement + analytics |
| `lib/features/capsules/providers/capsule_providers.dart` | Passage des nouveaux paramètres |
| `lib/features/capsules/screens/create_capsule_screen.dart` | Paramètres `albumId` / `albumSlotId` |
| `firestore.rules` | Règle d'accès `predefinedAlbums` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Sélection d'un modèle d'album prédéfini | ✅ |
| Chaque modèle a une liste d'évènements réelle | ✅ |
| Attacher une capsule existante à un évènement | ✅ |
| Créer une nouvelle capsule liée à l'évènement | ✅ |
| Mise à jour temps réel (Firestore streams) | ✅ |
| Accessible depuis Livre de Mémoires | ✅ |
| Gestion multi-enfants au moment de la création | ✅ |
| Contrôle d'accès Firestore par utilisateur | ✅ |
| Analytics `album_template_selected` | ✅ |
| Analytics `album_event_slot_filled` | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |

---

## Note — vérification UI

Cet environnement ne dispose ni d'émulateur/appareil Android connecté, ni de cible Flutter Web configurée pour ce projet (Android-only, confirmé dans `CLAUDE.md`). La vérification s'est donc appuyée sur `flutter analyze` (0 erreur sur l'ensemble du projet, hors 5 erreurs préexistantes et sans rapport dans `app_theme.dart`) et une relecture manuelle complète du flux de données réactif (Firestore streams → providers → écrans). **Un test manuel sur appareil réel ou émulateur reste recommandé avant mise en production.**
