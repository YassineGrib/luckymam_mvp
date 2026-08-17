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

### 2. Bottom sheet — 2 actions rapides localisées

Tous les textes, boutons et avertissements du menu et du sélecteur s'adaptent dynamiquement (FR / AR / EN) :
- **Titre & sous-titre** : `Ajouter rapidement` / `Quick Add` / `إضافة سريعة` ; `Que souhaitez-vous faire ?` / `What would you like to do?` / `ماذا ترغبين في فعله؟`.
- **Option 1 — Créer une capsule** :
  - Ouvre `CreateCapsuleScreen` avec l'enfant pré-rempli.
  - Libellés traduits (ex: `Créer une capsule` / `Create a capsule` / `إنشاء كبسولة`).
  - Analytics : `timeline_quickadd_selected` (`action: 'create_capsule'`).
- **Option 2 — Marquer un jalon** :
  - Libellés traduits (ex: `Marquer un jalon` / `Mark a milestone` / `تحديد جلون`).
  - Ouvre un second bottom sheet (`DraggableScrollableSheet`) listant les jalons (max 6).
  - Titre du sélecteur localisé : `Jalons à venir` / `Upcoming Milestones` / `الجالونات القادمة`.
  - Nom de la phase traduit dynamiquement (ex: `Gestation` / `Pregnancy` / `الحمل`).
  - Si tous les jalons sont complétés, le message d'avertissement s'affiche traduit (ex: `Tous les jalons de cette phase ont déjà un souvenir ✓` / `All milestones in this phase already have a memory ✓` / `كل جالونات هذه المرحلة لديها ذكرى بالفعل ✓`).
  - Analytics : `timeline_quickadd_selected` (`action: 'mark_milestone'`).

### 3. Widget `_QuickAddTile`

Widget réutilisable pour chaque option du menu : icône colorée, titre, sous-titre, chevron. Style cohérent avec le reste de l'app (border radius 16, couleurs dark/light).

### 4. Réglage d'affichage déplacé dans le Profil (traduit dynamiquement)

Le toggle Vue horizontale / verticale a été retiré de l'écran Timeline et intégré dans **Profil → Paramètres** :

- Le titre s'adapte dynamiquement : `Affichage Timeline` / `Timeline Display` / `عرض الخط الزمني`.
- Le sous-titre dynamique indique la vue courante en temps réel : `Vue horizontale` / `Horizontal view` / `عرض أفقي` ou `Vue verticale` / `Vertical view` / `عرض عمودي`.
- Les bulles d'aide (tooltips) des deux boutons s'adaptent dynamiquement (ex: `Horizontale` / `Horizontal` / `أفقي`).
- Contrôle segmenté 2 boutons (icône colonne / icône flux) avec mise en évidence du mode actif en rose (`AppColors.magentaPink`).
- Persisté via `SharedPreferences` (clé `timeline_view_mode`) — survit aux redémarrages.

Nouveau provider : `lib/core/providers/display_provider.dart` — `TimelineViewModeNotifier` (StateNotifier + SharedPreferences).

### 5. Analytics

- `timeline_quickadd_opened` — à chaque ouverture du bottom sheet
- `timeline_quickadd_selected` — à chaque sélection, avec paramètre `action`

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/timeline/screens/timeline_screen.dart` | FAB supprimé → bouton en en-tête ; toggle vue retiré ; viewMode lu depuis provider ; traduction dynamique du bouton Ajouter et des options |
| `lib/core/providers/display_provider.dart` | Nouveau — `timelineViewModeProvider` persisté via SharedPreferences |
| `lib/features/profile/profile_screen.dart` | Ajout `_DisplaySettingsTile` + `_ViewModeButton` dans la section Paramètres (traduit dynamiquement en AR / EN / FR) |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Bouton « + » dans l'en-tête, identique à Mes Capsules | ✅ |
| Titre de la page sur une seule ligne | ✅ |
| Action « Créer capsule » disponible | ✅ |
| Action « Marquer un jalon » disponible | ✅ |
| Jalons déjà liés filtrés (non affichés) | ✅ |
| Traduction dynamique du menu et des sélecteurs (AR / FR / EN) | ✅ |
| Réglage vue déplacé dans Profil → Paramètres | ✅ |
| Préférence persistée entre les sessions | ✅ |
| Analytics `timeline_quickadd_opened` | ✅ |
| Analytics `timeline_quickadd_selected` | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |
