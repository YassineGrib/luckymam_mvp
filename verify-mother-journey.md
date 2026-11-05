# Plan de Vérification — Parcours Maman (Foundation LM2-140 / 141 / 143 / 146)

> **Type de projet :** MOBILE (Flutter / Dart / Firebase Firestore / Riverpod)  
> **Objectif :** Valider rigoureusement l'ensemble des développements réalisés lors du Plan 1 (Fondations du Parcours Maman), tant au niveau des tests automatisés que du comportement fonctionnel et visuel sur émulateur.  
> **Statut :** 🔄 En cours de validation  
> **Date :** 2026-10-22  

---

## 🎯 Critères de Succès (Definition of Done)

1. **Tests Automatisés :** 100% des tests unitaires et widget du projet passent sans échec (147+ tests).
2. **Analyse Statique :** `flutter analyze` retourne `No issues found!`.
3. **Absence de Régression :** Zéro lecture directe de `profile.status` dans `lib/features/home/`.
4. **Validation Fonctionnelle (Émulateur) :**
   - Coexistence validée : Maman enceinte ayant déjà des enfants (Situation D) voit son suivi de grossesse ET la section « Mes enfants ».
   - Bébé attendu : Affichage de la couleur dorée neutre (`goldenrod`), icône pédiatrique universelle, compte à rebours dynamique.
   - Calendriers protégés : Onglet Vaccinations et Onglet Jalons affichent l'état vide bienveillant « Le calendrier démarre à la naissance » pour un bébé attendu.
   - Souvenirs intacts : Les anciennes capsules continuent de s'afficher sans aucune perte de données.
5. **Règles Firestore :** Vérification de la sécurité de la sous-collection `/users/{uid}/pregnancies`.

---

## 🧱 Architecture & Périmètre Testé

```
lib/
├── features/
│   ├── profile/
│   │   ├── models/ (pregnancy.dart, mother_stage.dart, profile_models.dart)
│   │   ├── services/ (profile_service.dart, profile_migration.dart)
│   │   └── providers/ (profile_providers.dart)
│   ├── capsules/
│   │   ├── models/ (capsule.dart: multi-sujets & espaces)
│   │   ├── services/ (capsule_service.dart)
│   │   └── providers/ (capsule_providers.dart)
│   └── home/
│       ├── tabs/ (dashboard_tab.dart, vaccinations_tab.dart)
│       └── widgets/ (weekly_day_strip, cycle_tracking_section, mother_health_card, child_summary_card)
```

---

## 📋 Programme de Vérification par Phase

### Phase 1 : Validation Automatisée (Tests Unitaires & Widgets)

Exécuter chaque suite de tests pour vérifier la logique métier pure :

| ID | Suite de Test | Cible vérifiée | Commande d'exécution | Statut |
|---|---|---|---|:---:|
| **T-01** | `test/pregnancy_test.dart` | Modèle Grossesse, calcul DPA (DDR+280j), SA (0-42), trimestres, sérialisation | `flutter test test/pregnancy_test.dart` | ✅ Pass (100%) |
| **T-02** | `test/child_model_test.dart` | Bébé attendu (`expected`), genre inconnu (`unknown`), repli défensif, pastille dorée | `flutter test test/child_model_test.dart` | ✅ Pass (100%) |
| **T-03** | `test/mother_stage_test.dart` | Matrice des 6 stades maternels (`MotherStage`), TTC, schéma v2 | `flutter test test/mother_stage_test.dart` | ✅ Pass (100%) |
| **T-04** | `test/profile_migration_test.dart` | Migration idempotente des anciens profils, pas de doublons | `flutter test test/profile_migration_test.dart` | ✅ Pass (100%) |
| **T-05** | `test/capsule_subjects_test.dart` | Classification des espaces (enfant, maman, famille), rétrocompatibilité | `flutter test test/capsule_subjects_test.dart` | ✅ Pass (100%) |
| **T-06** | `test/home_stage_consumers_test.dart` | Coexistence Accueil (Situation D), bandeau multi-événements | `flutter test test/home_stage_consumers_test.dart` | ✅ Pass (100%) |
| **T-07** | `test/task_7b_schedules_profile_migration_test.dart` | Exclusion des bébés attendus des vaccins & timeline, état vide l10n | `flutter test test/task_7b_schedules_profile_migration_test.dart` | ✅ Pass (100%) |
| **T-08** | **Suite Globale** | Intégrité de l'ensemble du projet sans régression (147 tests) | `flutter test` | ✅ Pass (147/147) |

---

### Phase 2 : Analyse Statique & Respect des Règles

Vérifier la propreté du code et l'absence de régressions architecturales :

- [x] **L-01 : Analyse du code**
  - Commande : `flutter analyze`
  - Résultat : `No issues found!` (0 erreur, 0 avertissement).
- [x] **L-02 : Vérification du découplage de `profile.status`**
  - Commande : Recherche `profile.status` dans `lib/features/home/`
  - Résultat : 0 occurrence trouvée (découplage strict respecté).
- [x] **L-03 : Déploiement des règles Firestore**
  - Règle `match /pregnancies/{pregnancyId}` vérifiée et déployée sur Firebase.

---

### Phase 3 : Scénarios Fonctionnels sur Émulateur (Vérification Visuelle)

Lancer l'application via `flutter run` et tester les 5 cas d'usage réels :

#### 🔹 Scénario 1 : Coexistence Maman Enceinte + Enfants (Situation D - Cœur de LM2-141)
- **Action :** Se connecter avec un compte ayant déjà un enfant né, puis déclarer une grossesse dans le profil.
- **Vérifications attendues :**
  - [ ] Le bandeau supérieur affiche la semaine de grossesse et le compte à rebours vers le terme.
  - [ ] Le bloc de suivi de grossesse / santé maternelle est visible.
  - [ ] La section « Mes enfants » (`ChildrenOverview`) reste visible et accessible juste en dessous.
  - [ ] Le conseil du jour est ciblé pour une maman enceinte avec enfants.

#### 🔹 Scénario 2 : Première Grossesse (Situation C)
- **Action :** Créer un profil avec uniquement une grossesse déclarée (aucun enfant né).
- **Vérifications attendues :**
  - [ ] Le suivi de grossesse s'affiche.
  - [ ] La section « Mes enfants nés » est masquée.

#### 🔹 Scénario 3 : Fiche Bébé Attendu & Genre Surprise (LM2-143)
- **Action :** Ouvrir le passeport / profil de l'enfant attendu.
- **Vérifications attendues :**
  - [ ] Prénom par défaut : « Bébé » (ou « بيبي » en arabe).
  - [ ] Genre affiché : « Surprise » (ou « مفاجأة ») avec pastille dorée neutre (`goldenrod`).
  - [ ] L'icône affichée est l'icône pédiatrique neutre `Icons.child_care`.
  - [ ] Le texte dynamique indique : « Naissance prévue dans X sem. ».

#### 🔹 Scénario 4 : Protection du Calendrier Médical (Vaccins & Jalons)
- **Action :**
  1. Aller dans l'onglet **Vaccinations** et sélectionner le bébé attendu dans le sélecteur.
  2. Aller dans l'onglet **Jalons / Timeline** et sélectionner le bébé attendu.
- **Vérifications attendues :**
  - [ ] Aucun vaccin n'est programmé avant la naissance.
  - [ ] Affichage du message bienveillant : « Le calendrier démarre à la naissance » / « يبدأ الجدول عند الولادة ».
  - [ ] En basculant vers un enfant né de la fratrie, la liste normale des vaccins réapparaît instantanément.

#### 🔹 Scénario 5 : Rétrocompatibilité des Capsules (LM2-146)
- **Action :** Consulter la liste des capsules existantes.
- **Vérifications attendues :**
  - [ ] Toutes les anciennes capsules sont présentes dans le dossier de leur enfant respectif.
  - [ ] La migration d'arrière-plan s'exécute silencieusement sans bloquer l'UI.

---

## 🛠️ État d'Exécution & Synthèse

| Étape | Responsable | Outil | Statut |
|---|---|---|:---:|
| 1. Tests automatisés unitaires & widgets | Agent / Terminal | `flutter test` | ⏳ À lancer |
| 2. Analyse statique & linters | Agent / Terminal | `flutter analyze` | ⏳ À lancer |
| 3. Vérification manuelle sur émulateur | Utilisateur + Agent | `flutter run` / Argent | ⏳ À lancer |
| 4. Clôture & Passage au Plan Suivant (Plan 2 / IA) | Orchestrator | Git & Rapports | ⏳ En attente |
