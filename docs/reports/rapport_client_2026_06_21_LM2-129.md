# Rapport — LM2-129 : Thumbnail Capsule sur Jalon

**Date :** 2026-06-21  
**Ticket :** LM2-129  
**Priorité :** Must Have · 5 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Champ `thumbnailUrl` dans `MilestoneWithDueDate`

Un nouveau champ optionnel `thumbnailUrl` a été ajouté au modèle `MilestoneWithDueDate` (dans `timeline_service.dart`). Il est renseigné lors du chargement des jalons si une capsule est liée.

### 2. Fetch batch des thumbnails dans `childMilestonesProvider`

Après la fusion progress/jalons, le provider récupère en parallèle (`Future.wait`) les `photoUrl` de toutes les capsules liées (celles dont `capsuleId != null`) via un accès direct Firestore :

```
users/{uid}/capsules/{capsuleId} → champ photoUrl
```

Seules les capsules effectivement liées à un jalon sont chargées — pas de sur-fetch. Si l'utilisateur n'est pas authentifié ou si aucun jalon n'a de capsule, le fetch est ignoré.

### 3. Widget `_MilestoneThumbnail`

Nouveau `StatefulWidget` affiché à la place du badge "Souvenir ✓" sur la carte complète (full card) :

- **Si `thumbnailUrl` disponible** → `Image.network` en 56×56 px, `ClipRRect` (border radius 10), `fit: BoxFit.cover`.
  - **Indicateur de chargement dynamique** : Un `loadingBuilder` affiche un indicateur de chargement circulaire (`CircularProgressIndicator`) rose et minimaliste sur un fond clair/sombre adapté (`AppColors.surfaceDark` ou `Colors.grey.shade100`) pendant le téléchargement de l'image.
- **En cas d'erreur réseau / URL invalide** → fallback automatique vers le badge "Souvenir" existant (traduit dynamiquement).
- **Refresh immédiat** : la `thumbnailUrl` est chargée dans le même provider que les jalons — elle est disponible dès que la liste se reconstruit après création d'une capsule.

### 4. Analytics `milestone_thumbnail_rendered`

L'événement est déclenché une seule fois par rendu (flag `_analyticsLogged`) via `addPostFrameCallback`, avec les paramètres :
- `milestone_id`
- `capsule_id`

La carte compacte conserve l'icône `check_circle_rounded` verte (pas de thumbnail — espace insuffisant).

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/timeline/services/timeline_service.dart` | Ajout champ `thumbnailUrl` dans `MilestoneWithDueDate` ; fetch batch dans `childMilestonesProvider` |
| `lib/features/timeline/widgets/milestone_card.dart` | Remplacement badge "Souvenir" par `_MilestoneThumbnail` ; ajout widget + fallback badge + indicateur de chargement dynamique |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Thumbnail affiché sur la carte jalon après création capsule | ✅ |
| Refresh immédiat (même provider que les jalons) | ✅ |
| Indicateur de chargement dynamique (loading placeholder) | ✅ |
| Fallback badge "Souvenir" (traduit) si URL manquante ou erreur | ✅ |
| Fetch limité aux jalons avec capsule liée (pas de sur-fetch) | ✅ |
| Analytics `milestone_thumbnail_rendered` | ✅ |
| `flutter analyze` clean | ✅ |
