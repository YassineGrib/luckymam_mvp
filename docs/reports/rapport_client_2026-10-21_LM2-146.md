# Rapport — LM2-146 : Sujets Multiples de Capsule & Parcours Maman

**Date :** 2026-10-21  
**Ticket :** LM2-146  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé  

---

## Ce qui a été fait

### 1. Modèle de capsule multi-sujets et espaces de souvenirs
Le système de souvenirs (capsules temporelles) était initialement restreint à l'association d'un souvenir à un seul enfant à la fois. Le modèle `Capsule` a été refondu pour refléter la richesse de la vie familiale et permettre à la maman d'immortaliser des moments qui la concernent directement ou qui impliquent plusieurs membres de la famille :
- Association à zéro, un ou plusieurs enfants (`childIds: List<String>`),
- Association directe à la maman (`withMother: bool`),
- Rattachement possible à une grossesse en cours (`pregnancyId`) et à la semaine d'aménorrhée correspondante (`pregnancyWeek`),
- Introduction de l'espace de vie du souvenir (`CapsuleSpace` : `'child'`, `'mother'`, `'family'`), dérivé automatiquement lors de la création ou de la lecture.

### 2. Algorithme de classification des espaces (deriveCapsuleSpace)
L'espace d'une capsule est déterminé selon un ordre de priorité médical et familial strict :
1. *Photo de ventre rond / souvenir de grossesse* (`pregnancyId` présent, `withMother: true`, 1 seul enfant attendu) → Espace Maman (`CapsuleSpace.mother`),
2. *Fratrie / Enfants multiples* (`childIds` ≥ 2, avec ou sans la maman) → Espace Famille (`CapsuleSpace.family`),
3. *Maman avec un enfant né* (`withMother: true` avec 1 enfant né) → Espace Famille (`CapsuleSpace.family`),
4. *Maman seule* (`withMother: true`, aucun enfant associé) → Espace Maman (`CapsuleSpace.mother`),
5. *Enfant seul* (cas standard) → Espace Enfant (`CapsuleSpace.child`).

### 3. Rétrocompatibilité absolue avec les capsules existantes
- Le champ historique `childId` continue d'exister et est automatiquement synchronisé avec le premier enfant de la liste (`childIds.first`), garantissant le bon fonctionnement immédiat de tout le code existant.
- Lors de la lecture d'une ancienne capsule ne contenant pas le champ `childIds`, l'application reconstitue automatiquement la liste `[childId]`, positionne `withMother = false` et attribue l'espace `'child'`.
- Aucune régression n'est possible sur les souvenirs déjà enregistrés par les utilisatrices de l'application.

### 4. Requêtes Firestore filtrées et providers Riverpod
Mise à jour du service `CapsuleService` pour offrir des flux de données réactifs et ciblés :
- `watchCapsulesForChild(childId)` : retourne l'ensemble des capsules associées à un enfant, qu'il s'agisse d'un souvenir individuel ou d'un moment partagé avec ses frères et sœurs,
- `watchMotherCapsules()` : flux des souvenirs personnels de la maman (`withMother == true`),
- `watchFamilyCapsules()` : flux des souvenirs collectifs de la famille (`space == family`).
Création des providers Riverpod correspondants (`motherCapsulesProvider` et `familyCapsulesProvider`) pour alimenter les futures interfaces du parcours maman et du journal familial.

### 5. Validation à la création et routine de migration par lots
- Mise à jour de la méthode de création `createCapsule` : les paramètres `childIds`, `withMother`, `pregnancyId` et `pregnancyWeek` sont pris en charge, avec une validation garantissant qu'au moins un sujet (la maman ou au moins un enfant) est désigné.
- Routine de migration sécurisée `migrateCapsuleSubjects` : convertit par lots de 450 documents les capsules existantes vers le schéma v2 (`capsuleSchemaVersion: 2`) sans saturer les quotas Firestore ni impacter la fluidité de l'application.

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/capsules/models/capsule.dart` | Enum `CapsuleSpace`, règle `deriveCapsuleSpace`, champs multi-sujets (`childIds`, `withMother`, `pregnancyId`, `pregnancyWeek`, `space`), désérialisation sécurisée et rétrocompatibilité |
| `lib/features/capsules/services/capsule_service.dart` | Requêtes filtrées par sujet, validation à la création et routine de migration par lots |
| `lib/features/capsules/providers/capsule_providers.dart` | Providers `motherCapsulesProvider` et `familyCapsulesProvider`, et adaptation de `CapsuleActionsNotifier` |
| `test/capsule_subjects_test.dart` | 40 tests unitaires validant l'attribution des espaces, la rétrocompatibilité, les filtres de flux et la logique de migration |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Capsule parcours maman (`withMother: true`, `space = 'mother'`, affichage parcours maman) | ✅ |
| Rétrocompatibilité capsules existantes (conversion automatique `childIds = [childId]`, `space = 'child'`) | ✅ |
| Capsule partagée famille / fratrie (plusieurs enfants associés, affichage dans chaque dossier concerné, espace `'family'`) | ✅ |
| `flutter analyze` clean | ✅ |
