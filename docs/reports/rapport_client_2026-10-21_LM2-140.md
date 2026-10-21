# Rapport — LM2-140 : Modèle MotherStage & Collection Grossesses

**Date :** 2026-10-21  
**Ticket :** LM2-140  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé  

---

## Ce qui a été fait

### 1. Remplacement du statut unique par le modèle dynamique MotherStage
Auparavant, le profil utilisateur reposait sur un statut rigide et mutuellement exclusif (`UserStatus`) qui empêchait par exemple une maman ayant déjà des enfants d'être également reconnue comme enceinte. Le nouveau modèle `MotherStage` calcule dynamiquement le stade de vie maternel côté client à partir de trois réalités factuelles indépendantes :
- La présence d'enfants déjà nés (`children` avec `lifecycle == born`),
- L'existence d'une grossesse active en cours (`/users/{uid}/pregnancies` avec `status == active`),
- Le projet actif de concevoir un enfant (`tryingToConceive: bool`).

La fonction de dérivation pure (`deriveMotherStage`) couvre fidèlement les six situations de vie de la spécification produit : exploration / découverte (`exploring`), projet bébé (`hope`), première grossesse (`pregnantFirst`), maman enceinte avec enfants (`pregnantWithChildren`), maman avec enfants (`mom`), et maman avec enfants souhaitant concevoir à nouveau (`momHope`).

### 2. Modèle de données Grossesse et calculs gestationnels précis
Création du modèle complet `Pregnancy` dans `lib/features/profile/models/pregnancy.dart` pour modéliser chaque grossesse :
- Enregistrement de la date des dernières règles (DDR / `lmpDate`) et de la date présumée d'accouchement (DPA / `eddDate`),
- Traçabilité de la source du terme (`eddSource` : calcul DDR standard, confirmation par échographie ou avis médical),
- Prise en compte des grossesses multiples (`babyCount` : 1, 2, 3...) et rattachement des identifiants des dossiers enfants attendus (`childIds`),
- Cycle de vie de la grossesse (`status` : active, accouchée / menée à terme, ou interrompue) avec horodatage de fin (`endedAt`),
- Algorithme obstétrical précis basé sur des dates pures (évitant tout décalage horaire ou lié à l'heure d'été) : calcul automatique de la semaine gestationnelle (0 à 42 semaines d'aménorrhée), du jour dans la semaine (0 à 6), du trimestre en cours (1er : 0-13 sem., 2e : 14-27 sem., 3e : 28+ sem.) et du décompte des jours restants avant le terme.

### 3. Persistance Firestore et sécurité des données
- Création de la sous-collection dédiée `/users/{uid}/pregnancies/{pregnancyId}` dans Firebase Firestore, assurant le chiffrement au repos et la stricte confidentialité des données de santé.
- Mise à jour des règles de sécurité Firebase (`firestore.rules`) garantissant que chaque utilisatrice authentifiée ne peut lire et modifier que ses propres dossiers de grossesse.
- Sauvegarde synchronisée et rétrocompatible du champ legacy `status` dérivé sur le document utilisateur afin de préserver le bon fonctionnement de tous les anciens écrans sans régression.

### 4. Migration automatique et idempotente des profils existants
- Implémentation du service `profile_migration.dart` pilotant le passage vers le schéma v2 (`schemaVersion: 2`).
- Pour les profils créés avec les anciennes versions de l'application, la migration s'exécute de façon atomique et transparente : conversion automatique du profil déclaré « enceinte » avec une date de grossesse vers un document officiel `pregnancies`, et activation du projet bébé (`tryingToConceive = true`) pour les profils ayant le statut « hope ».
- Garantie d'idempotence : dès que `schemaVersion` passe à 2, aucune réexécution n'a lieu, garantissant l'absence de doublons ou de réécritures inutiles.

### 5. Fournisseurs d'état réactifs Riverpod
Mise à disposition pour toute l'application d'un ensemble de flux et fournisseurs de données dans `profile_providers.dart` :
- `pregnanciesProvider` (flux complet des grossesses triées par date),
- `activePregnancyProvider` (grossesse active en cours ou null),
- `motherStageProvider` (stade maternel calculé en temps réel),
- `isPregnantProvider` et `hasBornChildrenProvider` (indicateurs booléens directs simplifiant les conditions d'affichage dans les interfaces).

---

> **À noter :** La nouvelle règle de sécurité ajoutée pour la sous-collection `pregnancies` dans `firestore.rules` doit être déployée sur les serveurs Firebase (`firebase deploy --only firestore:rules`) — ce déploiement reste à effectuer.

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `firestore.rules` | Règle de sécurité limitant l'accès à `/users/{userId}/pregnancies/{pregnancyId}` au propriétaire |
| `lib/features/profile/models/pregnancy.dart` | Modèle de données `Pregnancy`, enums de statut et source, calculs obstétricaux et sérialisation |
| `lib/features/profile/models/mother_stage.dart` | Enum `MotherStage`, constantes de schéma v2 et fonction pure `deriveMotherStage` |
| `lib/features/profile/models/profile_models.dart` | Ajout des champs `tryingToConceive` et `schemaVersion` sur `UserProfile` |
| `lib/features/profile/services/profile_migration.dart` | Logique métier pure de calcul du plan de migration de profil v2 |
| `lib/features/profile/services/profile_service.dart` | Gestion de la sous-collection `pregnancies`, persistance, statut dérivé et routine de migration |
| `lib/features/profile/providers/profile_providers.dart` | Providers Riverpod pour les grossesses, le stade maternel et les capacités |
| `test/pregnancy_test.dart` | Tests unitaires des calculs obstétricaux, sérialisation Firestore et gestion des cas limites |
| `test/mother_stage_test.dart` | Tests unitaires de la matrice des 6 stades maternels et des propriétés du profil |
| `test/profile_migration_test.dart` | Tests unitaires de la logique de migration et du comportement des providers |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Dérivation du stade maternel (6 situations A à F conformes) | ✅ |
| Calculs gestationnels précis (DPA = DDR + 280 j, SA 0-42, jours 0-6, trimestres 1-3) | ✅ |
| Migration idempotente des profils existants vers le schéma v2 | ✅ |
| `flutter analyze` clean | ✅ |
