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

### 1. Badge "Souvenir" & "Capturer" dans `milestone_card.dart`

**Carte complète (full card) :**
- Si une capsule est liée (`capsuleId != null`) → badge vert **"Souvenir"** (traduit en `Memory` / `ذكرى` selon la langue active) avec bordure verte.
- Si pas de capsule → bouton gradient rose **"Capturer"** (traduit en `Capture` / `توثيق`).
- Titre et description affichés dynamiquement selon la langue choisie (via les méthodes `getTitle(lang)` / `getDescription(lang)` du modèle `Milestone`).
- Date d'échéance formatée dynamiquement selon la locale locale (arabe / français / anglais).

**Carte compacte (compact card) :**
- Si capsule liée → icône `check_circle_rounded` verte à la place du compteur J+XX.
- Sinon → compteur J+XX habituel.

### 2. Écran Détail Jalon & Action `_markComplete`

Tous les textes, catégories, phases et alertes sont traduits dynamiquement (FR / AR / EN) :
- Les boutons principaux s'adaptent (ex: `Voir la capsule` / `View Capsule` / `عرض الكبسولة`, `Marquer terminé` / `Mark complete` / `تحديد كمكتمل`, `Fermer` / `Close` / `إغلاق`).
- Le bouton conseil s'affiche traduit (`Conseils & idées photo` / `Tips & photo ideas` / `نصائح وأفكار للصور`).
- Persistance Firestore optimisée : Utilisation d'un identifiant de document déterministe (`${childId}_${milestoneId}`) dans `completeMilestone()` et `skipMilestone()` pour éviter tout doublon de données en base.
- SnackBars d'avertissement et de succès traduites (ex: success: `Jalon marqué comme terminé ✓` / `Milestone marked as complete ✓` / `تم تحديد الجالون كمكتمل ✓`).
- `Navigator.pop()` uniquement après succès.

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
| `lib/features/timeline/services/timeline_service.dart` | Identifiant déterministe dans `completeMilestone()` et `skipMilestone()` pour éviter les doublons |
| `lib/features/timeline/widgets/milestone_card.dart` | Badge vert "Souvenir" (traduit, full + compact) quand capsule liée · traduction dynamique des boutons/textes |
| `lib/features/timeline/screens/milestone_detail_screen.dart` | Fix `_markComplete` (Firestore), analytics `milestone_capsule_cta_shown` · traduction dynamique des boutons/alertes/dialogues |
| `lib/features/timeline/models/milestone.dart` | Fix bug dans la méthode `getDescription` (retour de descriptionFr au lieu de titleFr) |
| `lib/features/timeline/models/phase.dart` | Ajout d'extensions et de méthodes de traduction dynamique (getLabel) pour les phases et catégories de jalons |
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
| Traduction dynamique de l'écran et des badges (AR / FR / EN) | ✅ |
| Correction du bug de description française (`titleFr` -> `descriptionFr`) | ✅ |
| Prévention des doublons de données (ID de document déterministe) | ✅ |
| Analytics `milestone_capsule_cta_shown` | ✅ |
| Analytics `milestone_capsule_created` | ✅ |
| `flutter analyze` clean | ✅ |
