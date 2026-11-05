# Rapport de Livraison — LM-ONB-005 : Ajout d'Enfants Quel Que Soit le Statut

**Date :** 2026-11-03  
**Ticket :** LM-ONB-005 (Priorité P1 – Majeure)  
**Module :** Profil Utilisateur, Dashboard & Espace Capsules (`ChildrenOverview`, `DashboardTab`, `CreateCapsuleScreen`, `TimelineScreen`)  
**Statut :** ✅ Validé & Prêt pour Test Appareil  

---

## 🎯 Problèmes résolus & Spécifications implémentées

1. **Déblocage de l'action « Ajouter un enfant » pour tous les statuts (Espoir, Enceinte, Maman) :**
   - **Comportement précédent :** Sur l'écran d'accueil (`DashboardTab`), la section « Mes Enfants » était conditionnée par `if (hasBornChildren) ...`, rendant la section et le bouton d'ajout invisibles pour toute utilisatrice n'ayant pas encore d'enfant né enregistré (notamment les profils en essai bébé / Espoir, les femmes enceintes d'un premier enfant, ou les nouvelles mamans).
   - **Nouveau comportement :** La section « Mes Enfants » est désormais présente sans condition sur le Dashboard pour l'ensemble des statuts. Si l'utilisatrice n'a aucun enfant enregistré, une carte d'accueil chaleureuse l'invite directement à ajouter son enfant.
   - **Accès direct au formulaire :** Le tap sur « Ajouter un enfant » ouvre immédiatement `EditChildScreen` (avec possibilité de renseigner le prénom, la date de naissance, le genre, la photo, le groupe sanguin et les notes), au lieu d'une redirection indirecte vers l'onglet Profil.
   - **Points d'accès additionnels :** L'ajout d'enfant est également directement accessible depuis l'écran de consultation de la Timeline (`TimelineScreen` avec bouton d'ajout explicite si aucun enfant) et depuis l'écran de création de souvenirs (`CreateCapsuleScreen`).

2. **Préservation absolue des enfants lors des changements de statut :**
   - Le passage d'un statut à un autre (`UserStatus.hope` ↔ `UserStatus.pregnant` ↔ `UserStatus.mom`) ne supprime ni ne masque aucun enfant existant.
   - Les enfants enregistrés conservent l'ensemble de leurs jalons, vaccins, courbes de croissance et souvenirs associés.
   - L'algorithme de dérivation de stade (`deriveMotherStage`) gère harmonieusement les cas mixtes : `MotherStage.momHope` (maman avec enfant(s) essayant d'en concevoir un autre) et `MotherStage.pregnantWithChildren` (maman avec enfant(s) attendant un nouveau bébé).

3. **Multi-enfants sans restriction d'abonnement :**
   - La gestion et le suivi de plusieurs enfants sont désormais ouverts à tous les forfaits (`childLimit: -1` sur le forfait Gratuit / Free).
   - Les tableaux comparatifs d'abonnements reflètent fidèlement la prise en charge de tous les enfants de la fratrie.

4. **Association fluide des souvenirs (Profil MAM vs Profils Enfants) :**
   - Dans `CreateCapsuleScreen`, l'utilisatrice peut librement associer un souvenir :
     - Au profil principal « MAM » (sélectionnable via le jeton avatar MAM dédié), permettant de créer des capsules même en l'absence d'enfant né ;
     - À un enfant spécifique de la fratrie ;
     - Aux deux à la fois (capsule familiale).
   - La validation de sauvegarde (`_canSave`) est débloquée dès lors que le profil MAM ou au moins un enfant est sélectionné.

5. **Isolation rigoureuse des données & Confirmation de suppression :**
   - Chaque profil enfant dispose d'un identifiant Firestore unique et indépendant.
   - La suppression d'un enfant requiert une boîte de dialogue de confirmation explicite (`_confirmDelete` avec message d'avertissement et double confirmation), protégeant l'utilisatrice contre toute manipulation involontaire.

---

## 📂 Fichiers modifiés & créés

| Fichier | Nature de la modification |
|---|---|
| `lib/features/home/tabs/dashboard_tab.dart` | Affichage inconditionnel de la section « Mes Enfants » pour tous les statuts (Espoir, Enceinte, Maman). |
| `lib/features/home/widgets/children_overview.dart` | Navigation directe vers `EditChildScreen` et carte d'accueil engageante lorsque la fratrie est vide (`isOnlyItem: true`). |
| `lib/features/capsules/screens/create_capsule_screen.dart` | Ajout du sélecteur de sujet « MAM » (Maman), du bouton rapide « + Ajouter un enfant », et validation de sauvegarde pour capsules MAM ou enfants. |
| `lib/features/timeline/screens/timeline_screen.dart` | Bouton d'action direct « Ajouter un enfant » dans l'état vide de la Timeline. |
| `lib/features/subscription/models/subscription_models.dart` | Définition de `childLimit: -1` (illimité) sur le forfait gratuit. |
| `lib/features/subscription/subscription_plan_l10n.dart` | Mise à jour des caractéristiques du plan gratuit (tous les enfants inclus). |
| `lib/features/subscription/widgets/plan_comparison_table.dart` | Mise à jour de la grille comparative (tous les enfants inclus sur tous les forfaits). |
| `test/add_child_any_status_test.dart` | Suite de tests automatisés couvrant les 6 critères d'acceptation du ticket. |
| `fix/MASTER_TODO.md` | Mise à jour du statut du ticket `LM-ONB-005` vers `[x]`. |

---

## 🧪 Critères d'Acceptation Validés

- [x] L’action « Ajouter un enfant » reste accessible pour les trois statuts (Espoir, Enceinte, Maman).
- [x] Le changement de statut ne supprime ni ne masque les enfants existants.
- [x] Plusieurs enfants peuvent être associés au même profil « MAM ».
- [x] Chaque souvenir ou capsule peut être associé au profil « MAM », à un enfant, ou aux deux.
- [x] Les données d’un enfant sont correctement isolées de celles des autres enfants.
- [x] La suppression d’un enfant demande une confirmation explicite.

