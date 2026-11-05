# Rapport de Livraison — LM-NAV-001 : Stabilisation de la Barre de Navigation Inférieure

**Date :** 2026-11-03  
**Ticket :** LM-NAV-001 (Priorité P1 – Critique)  
**Module :** Navigation Principale / Barre Inférieure (`AppBottomNav`)  
**Statut :** ✅ Validé & Prêt pour Test Appareil  

---

## 🎯 Problèmes résolus & Spécifications implémentées

1. **Disparition de la barre de navigation lors du passage au profil (`LM-NAV-001`) :**
   - **Cause identifiée :** Les widgets du tableau de bord (`PersonalHeader`, `ChildrenOverview`, `HomeHeroCompanionCard`, `CycleTrackingSection`, `MotherHealthCard`) ouvraient l'écran de profil en poussant une nouvelle route complète (`Navigator.push(ProfileScreen())`). Cela masquait le `HomeScreen` et supprimait totalement la barre de navigation inférieure.
   - **Solution apportée :** Centralisation de l'état de l'onglet actif dans Riverpod via `homeNavigationIndexProvider`. Tous les accès vers le profil depuis l'accueil basculent désormais directement l'onglet vers le profil (index 4) au sein du même conteneur principal `HomeScreen`.
   - **Résultat :** La barre de navigation reste présente, stable, avec l'onglet « Profil » activé et mis en surbrillance. Les changements de statut (grossesse, essai bébé, maman) se font sans rupture ni réinitialisation de l'historique.

2. **Présence de la barre de navigation sur l'écran des Notifications :**
   - **Cause identifiée :** L'écran `NotificationsScreen` était ouvert comme un écran isolé sans barre de navigation.
   - **Solution apportée :** Intégration de `AppBottomNav` sur `NotificationsScreen` avec l'onglet actif synchronisé. Taper sur n'importe quel onglet de la barre inférieure depuis les notifications permet de revenir immédiatement et sans friction sur l'onglet sélectionné du tableau de bord.
   - **Préservation des contenus & zones sécurisées :** Ajustement des marges inférieures (`SliverPadding` et vue vide à 120px) pour garantir qu'aucune carte de notification, bouton ou texte ne soit recouvert par la barre flottante, tout en respectant les bordures système (iOS home indicator / Android navigation gestures).

3. **Indépendance vis-à-vis des écrans secondaires et formulaires :**
   - Conformément aux spécifications, les formulaires de saisie modale ou secondaire plein écran (`EditMotherProfileScreen`, `EditChildScreen`, `CreateCapsuleScreen`) conservent leur mode focus sans barre de navigation.

---

## 📂 Fichiers modifiés & créés

| Fichier | Nature de la modification |
|---|---|
| `lib/shared/widgets/navigation/app_bottom_nav.dart` | Ajout du provider global `homeNavigationIndexProvider`, de la fonction `getAppNavItems(context)` et du helper `navigateToHomeTab(context, ref, index)`. |
| `lib/features/home/home_screen.dart` | Remplacement de la variable locale `_currentIndex` par `homeNavigationIndexProvider` pour pérenniser l'état de navigation face aux rafraîchissements de profil. |
| `lib/features/home/widgets/personal_header.dart` | Redirection du clic avatar mère vers l'onglet Profil (index 4) sans push de route. |
| `lib/features/home/widgets/children_overview.dart` | Redirection du bouton « Ajouter un enfant » vers l'onglet Profil (index 4). |
| `lib/features/home/widgets/home_hero_card.dart` | Redirection de la bannière de progression vers l'onglet Profil (index 4). |
| `lib/features/home/widgets/cycle_tracking_section.dart` | Redirection du bouton de configuration du cycle vers l'onglet Profil (index 4). |
| `lib/features/home/widgets/mother_health_card.dart` | Redirection de la carte santé maman vers l'onglet Profil (index 4). |
| `lib/features/notifications/notifications_screen.dart` | Intégration de `AppBottomNav`, mise en conformité des espacements bas (120px) et navigation réactive. |
| `test/bottom_navigation_stabilization_test.dart` | Suite de tests automatisés validant la présence de la barre, la persistance de l'état, l'accès au profil sans push et le comportement sur les notifications. |
| `fix/MASTER_TODO.md` | Clôture officielle du ticket `LM-NAV-001` (`[x]`). |

---

## 🧪 Validation & Critères d'Acceptation Vérifiés

- [x] **Critère 1 :** La barre de navigation reste visible après tout changement de mode ou de profil.
- [x] **Critère 2 :** La barre de navigation reste visible dans la liste des notifications.
- [x] **Critère 3 :** L’onglet actif est correctement mis en évidence (indicateur dynamique).
- [x] **Critère 4 :** Les changements de profil ne réinitialisent pas la navigation inopinément vers l'accueil.
- [x] **Critère 5 :** La barre ne recouvre aucun bouton ni texte de notification (padding 120px).
- [x] **Critère 6 :** Respect total des zones sécurisées (Safe Area & marges flottantes 24px).

