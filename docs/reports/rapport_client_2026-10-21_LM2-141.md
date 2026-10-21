# Rapport — LM2-141 : Consommateurs de Statut vers Capacités de Stade

**Date :** 2026-10-21  
**Ticket :** LM2-141  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé  

---

## Ce qui a été fait

### 1. Remplacement des vérifications rigides de statut par des capacités réactives
Dans l'ancienne architecture, les composants de l'écran d'accueil et du tableau de bord testaient directement la valeur stockée `profile.status == UserStatus.pregnant` ou `UserStatus.mom`. Ce branchement exclusif empêchait une maman enceinte qui a déjà des enfants d'accéder à la fois au suivi de sa grossesse et aux informations de ses aînés.
L'ensemble des widgets consomment désormais des fournisseurs de capacités spécialisés issus de Riverpod :
- `isPregnantProvider` : indique si une grossesse est actuellement active,
- `hasBornChildrenProvider` : indique si l'utilisatrice a au moins un enfant né,
- `activePregnancyProvider` : fournit les données complètes de la grossesse en cours (DPA, DDR, semaine de grossesse),
- `motherStageProvider.legacyStatus` : fait le pont avec les présentations graphiques existantes.
Aucune lecture directe de `profile.status` ne subsiste dans le répertoire `lib/features/home`.

### 2. Coexistence harmonieuse sur le tableau de bord (Situation D)
Pour une maman enceinte ayant déjà un ou plusieurs enfants :
- Le bandeau de santé maternelle (`MotherHealthCard`) et le bloc de grossesse (`CycleTrackingSection`) affichent les informations obstétricales calculées en direct (semaine d'aménorrhée, jour, DPA, décompte des jours).
- La section « Mes enfants » (`ChildrenOverview`) demeure accessible et visible directement sous le suivi de grossesse grâce à l'évaluation de `hasBornChildrenProvider`.
- Pour une première grossesse (Situation C), le suivi de grossesse s'affiche et la section des enfants nés reste masquée.
- Pour une maman non enceinte (Situation E), la section « Mes enfants » s'affiche et le bloc de grossesse est masqué.
- Le conseil du jour (`HomeTipsData.tipForStage` et `dailyTipProvider`) est automatiquement ciblé selon le stade maternel effectif.

### 3. Bandeau quotidien multi-événements (WeeklyDayStrip)
Le bandeau hebdomadaire en haut du tableau de bord est désormais capable de faire coexister plusieurs événements le même jour :
- Les rappels de vaccination des enfants nés (`bornChildrenProvider`),
- Les jalons de développement de la grossesse en cours (`activePregnancyProvider`),
- Le suivi d'ovulation et de cycle pour les femmes en projet de conception (`motherStage.tracksCycle`).

### 4. Protection des calendriers pédiatriques et états vides soignés
- Les générateurs d'échéances médicales (`vaccineSchedulerProvider`, `vaccineGroupsWithStatusProvider`, `TimelineService.getMilestonesForChild`) ignorent rigoureusement les enfants attendus (`child.isExpected`) : aucune alerte ou échéance pédiatrique n'est créée avant la naissance.
- Dans l'onglet Vaccinations (`vaccinations_tab.dart`) et l'onglet Jalons (`timeline_screen.dart`), lorsqu'un enfant attendu est sélectionné, l'application affiche un état vide explicite et bienveillant : « Le calendrier démarre à la naissance » / « يبدأ الجدول عند الولادة » / « The schedule starts at birth », tout en préservant le sélecteur pour basculer facilement vers les autres enfants de la fratrie.

### 5. Câblage de l'enregistrement du profil et routine de démarrage
- Dans `edit_mother_profile_screen.dart`, la validation du formulaire maman déclenche désormais les actions réelles associées : création officielle de la grossesse via `declarePregnancy` si l'utilisatrice passe au statut enceinte, ou activation/désactivation de `tryingToConceive` via `setTryingToConceive`.
- Au lancement de l'application dans `home_screen.dart`, une tâche d'arrière-plan post-affichage déclenche automatiquement la migration des données de profil et des capsules pour les utilisatrices existantes, sans aucun ralentissement au démarrage.

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/home/home_screen.dart` | Déclenchement post-frame de la migration de profil et de capsules au démarrage |
| `lib/features/home/providers/home_providers.dart` | `dailyTipProvider` basé sur le stade dérivé, `childrenSummaryProvider` ignorant les enfants attendus |
| `lib/features/home/tabs/dashboard_tab.dart` | Section « Mes enfants » affichée selon `hasBornChildrenProvider` pour permettre la coexistence |
| `lib/features/home/widgets/home_hero_card.dart` | Hero card alimentée par le statut dérivé de `motherStageProvider` |
| `lib/features/home/widgets/personal_header.dart` | En-tête utilisateur affichant le statut dérivé |
| `lib/features/home/widgets/home_bento_grid.dart` | Grille bento connectée au statut dérivé |
| `lib/features/home/widgets/mother_health_card.dart` | Suivi de santé maternelle conditionné par `isPregnantProvider` |
| `lib/features/home/widgets/cycle_tracking_section.dart` | Suivi de grossesse exploitant `activePregnancyProvider` avec repli défensif |
| `lib/features/home/widgets/weekly_day_strip.dart` | Gestion de la coexistence des vaccins des enfants nés et des jalons de grossesse |
| `lib/features/home/data/home_tips_data.dart` | Méthode `tipForStage` associant chaque stade maternel à sa sélection de conseils |
| `lib/features/home/tabs/vaccinations_tab.dart` | État vide « Le calendrier démarre à la naissance » pour les enfants attendus |
| `lib/features/timeline/screens/timeline_screen.dart` | État vide pour les enfants attendus avec préservation du filtre d'enfants |
| `lib/features/timeline/services/timeline_service.dart` | Exclusion des enfants attendus du calcul des jalons et rappels |
| `lib/features/vaccines/providers/vaccine_providers.dart` | Exclusion des enfants attendus du planning et des notifications de vaccination |
| `lib/features/profile/edit_mother_profile_screen.dart` | Câblage de l'enregistrement vers `declarePregnancy` et `setTryingToConceive` |
| `lib/features/profile/profile_screen.dart` | Sécurisation de l'accès auth pour les tests d'interface |
| `lib/l10n/app_fr.arb`, `app_ar.arb`, `app_en.arb` | Clé de localisation `scheduleStartsAtBirth` dans les 3 langues |
| `lib/l10n/app_localizations*.dart` | Fichiers de localisation générés par `flutter gen-l10n` |
| `test/home_stage_consumers_test.dart` | Tests de la coexistence sur le tableau de bord et du bandeau hebdomadaire |
| `test/task_7b_schedules_profile_migration_test.dart` | Tests des calendriers, des états vides, de la sauvegarde profil et de la migration |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Maman enceinte avec enfants (Situation D : suivi grossesse et section « Mes enfants » affichés simultanément) | ✅ |
| Première grossesse (Situation C : suivi de grossesse affiché, section « Mes enfants » nés masquée) | ✅ |
| Maman sans grossesse active (Situation E : « Mes enfants » affiché, bloc de suivi de grossesse masqué) | ✅ |
| Vérification manuelle sur émulateur | ⏳ À faire |
| `flutter analyze` clean | ✅ |
