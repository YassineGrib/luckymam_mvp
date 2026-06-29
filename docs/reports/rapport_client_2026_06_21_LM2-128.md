# Rapport — LM2-128 : Timeline Quick Add

**Date :** 2026-06-21  
**Ticket :** LM2-128  
**Priorité :** Should Have · 5 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Bouton « + Ajouter » dans l'en-tête de la Timeline

Le bouton d'action rapide est positionné dans le slot `trailing` du `PageHeaderWithFilter`, identique au bouton "Capturer" de l'écran "Mes Capsules" :

- Padding horizontal 16 / vertical 10
- `BorderRadius.circular(20)`
- Gradient `AppColors.primaryGradient`
- Police Outfit 13 px, bold blanc
- Grisé et inactif si aucun enfant sélectionné

Le `FloatingActionButton` a été supprimé car il s'affichait sous la barre de navigation inférieure.

### 2. Bottom sheet — 2 actions rapides

**Option 1 — Créer une capsule**
- Icône caméra rose
- Ouvre directement `CreateCapsuleScreen` avec l'enfant pré-rempli (`preselectedChildId`)
- Analytics : `timeline_quickadd_selected` avec `action: 'create_capsule'`

**Option 2 — Marquer un jalon**
- Icône étoile orange
- Ouvre un second bottom sheet (`DraggableScrollableSheet`) listant les jalons de la phase courante **sans capsule** (max 6)
- Chaque jalon ouvre directement `MilestoneDetailScreen`
- Analytics : `timeline_quickadd_selected` avec `action: 'mark_milestone'`
- Si tous les jalons ont déjà un souvenir → message "Tous les jalons ont déjà un souvenir ✓"

### 3. Widget `_QuickAddTile`

Widget réutilisable pour chaque option du menu : icône colorée, titre, sous-titre, chevron. Style cohérent avec le reste de l'app (border radius 16, couleurs dark/light).

### 4. Réglage d'affichage déplacé dans le Profil

Le toggle Vue horizontale / verticale a été retiré de l'écran Timeline et intégré dans **Profil → Paramètres → Affichage Timeline** :

- Contrôle segmenté 2 boutons (icône colonne / icône flux)
- Le mode actif est mis en évidence en rose (`AppColors.magentaPink`)
- Le sous-titre indique la vue courante en temps réel
- Persisté via `SharedPreferences` (clé `timeline_view_mode`) — survit aux redémarrages

Nouveau provider : `lib/core/providers/display_provider.dart` — `TimelineViewModeNotifier` (StateNotifier + SharedPreferences).

### 5. Analytics

- `timeline_quickadd_opened` — à chaque ouverture du bottom sheet
- `timeline_quickadd_selected` — à chaque sélection, avec paramètre `action`

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/timeline/screens/timeline_screen.dart` | FAB supprimé → bouton en en-tête ; toggle vue retiré ; viewMode lu depuis provider |
| `lib/core/providers/display_provider.dart` | Nouveau — `timelineViewModeProvider` persisté via SharedPreferences |
| `lib/features/profile/profile_screen.dart` | Ajout `_DisplaySettingsTile` + `_ViewModeButton` dans la section Paramètres |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Bouton « + » dans l'en-tête, identique à Mes Capsules | ✅ |
| Titre de la page sur une seule ligne | ✅ |
| Action « Créer capsule » disponible | ✅ |
| Action « Marquer un jalon » disponible | ✅ |
| Jalons déjà liés filtrés (non affichés) | ✅ |
| Réglage vue déplacé dans Profil → Paramètres | ✅ |
| Préférence persistée entre les sessions | ✅ |
| Analytics `timeline_quickadd_opened` | ✅ |
| Analytics `timeline_quickadd_selected` | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |
