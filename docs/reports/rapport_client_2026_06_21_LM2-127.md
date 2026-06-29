# Rapport — LM2-127 : Capsule sur Jalons

**Date :** 2026-06-21  
**Ticket :** LM2-127  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### Contexte

L'infrastructure de liaison capsule ↔ jalon était déjà en place au niveau des données :
- `Capsule.milestoneId` (Firestore)
- `MilestoneProgress.capsuleId` (Firestore)
- `capsule_providers.dart` appelait déjà `completeMilestone()` après création

Trois éléments manquaient : le badge visuel, la persistance du marquage "terminé", et les analytics.

### 1. Badge "Souvenir ✓" dans `milestone_card.dart`

**Carte complète (full card) :**
- Si une capsule est liée (`capsuleId != null`) → badge vert **"Souvenir ✓"** avec bordure verte
- Si pas de capsule → bouton gradient rose **"Capturer"** (comportement inchangé)

**Carte compacte (compact card) :**
- Si capsule liée → icône `check_circle_rounded` verte à la place du compteur J+XX
- Sinon → compteur J+XX habituel

### 2. Fix `_markComplete` — persistance Firestore

Le bouton "Marquer terminé" était un stub (`TODO`). Il persiste maintenant le jalon en Firestore :

- Appelle `TimelineService.completeMilestone()` avec `userId`, `childId`, `milestoneId`
- SnackBar vert ✓ on success
- SnackBar rouge on error avec message détaillé
- `Navigator.pop()` uniquement après succès

### 3. Analytics

Deux événements Firebase Analytics :

- `milestone_capsule_cta_shown` — déclenché via `addPostFrameCallback` quand le bouton "Capturer ce moment" s'affiche (jalon sans capsule)
  - Paramètre : `milestone_id`
- `milestone_capsule_created` — déclenché après création d'une capsule liée à un jalon et marquage réussi
  - Paramètres : `milestone_id`, `capsule_id`

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/timeline/widgets/milestone_card.dart` | Badge vert "Souvenir ✓" (full + compact) quand capsule liée |
| `lib/features/timeline/screens/milestone_detail_screen.dart` | Fix `_markComplete` (Firestore), analytics `milestone_capsule_cta_shown` |
| `lib/features/capsules/providers/capsule_providers.dart` | Analytics `milestone_capsule_created` après liaison jalon réussie |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Bouton "Créer capsule" visible sur chaque jalon | ✅ |
| Badge "Souvenir ✓" affiché si capsule déjà créée | ✅ |
| Capsule liée au jalon en Firestore | ✅ |
| Jalon marqué "complété" après création capsule | ✅ |
| Bouton "Marquer terminé" persiste en Firestore | ✅ |
| Analytics `milestone_capsule_cta_shown` | ✅ |
| Analytics `milestone_capsule_created` | ✅ |
| `flutter analyze` clean | ✅ |
