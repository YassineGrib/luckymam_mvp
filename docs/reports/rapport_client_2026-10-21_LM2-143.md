# Rapport — LM2-143 : Enfant Attendu & Genre Surprise

**Date :** 2026-10-21  
**Ticket :** LM2-143  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé  

---

## Ce qui a été fait

### 1. Cycle de vie de l'enfant et gestion des bébés à naître
Auparavant, tout enfant créé dans l'application était obligatoirement considéré comme déjà né, ce qui ne permettait pas à une future maman de préparer sereinement le dossier de son futur bébé dès la grossesse. Le modèle `Child` intègre désormais le cycle de vie `ChildLifecycle` :
- `ChildLifecycle.expected` pour un bébé attendu / à naître,
- `ChildLifecycle.born` pour un enfant déjà né (valeur par défaut).

Pour un enfant attendu, la date présumée d'accouchement (`expectedDate`) est stockée et sert de point de référence temporel. Dans Firestore, le champ `birthDate` est conservé à null tant que l'enfant n'est pas né, tandis que le modèle Dart garantit une compatibilité ascendante transparente pour le code existant. Le champ facultatif `pregnancyId` permet de relier directement l'enfant attendu à sa grossesse correspondante, et le drapeau `archived` permet de conserver les souvenirs d'une grossesse interrompue sans fausser les dossiers actifs.

### 2. Support du genre surprise et fallback défensif
- Ajout de la valeur `ChildGender.unknown` ("Surprise") pour les futurs parents qui ne connaissent pas encore le sexe de leur bébé ou souhaitent en garder la surprise jusqu'au jour de l'accouchement.
- Sécurisation des données existantes : les anciens dossiers d'enfants dépourvus de genre ou comportant une valeur non reconnue basculent désormais automatiquement et de manière sécurisée vers `unknown`, au lieu d'imposer artificiellement la valeur masculine par défaut. L'application ne présente aucun risque de plantage sur des documents incomplets.

### 3. Identité visuelle neutre et bienveillante
- Attribution d'un thème visuel dédié et apaisant pour les enfants au genre inconnu : couleur d'accent dorée (`AppColors.goldenrod`) en remplacement des codes couleur binaires habituels (bleu / rose).
- Remplacement des icônes de visages genrés par l'icône neutre et universelle de soin pédiatrique `Icons.child_care_rounded`.
- Intégration de cette identité visuelle sur l'ensemble des composants d'affichage : carte de résumé de l'enfant (`child_summary_card.dart`), pastille de genre et filigrane du passeport bébé (`child_profile_screen.dart`).

### 4. Textes d'attente localisés (FR, AR, EN)
Création de 4 nouvelles clés de traduction et intégration dans l'extension de localisation `profile_l10n_extension.dart` :
- Nom par défaut du futur bébé : « Bébé » (FR) / « بيبي » (AR) / « Baby » (EN),
- Libellé du genre : « Surprise » (FR) / « مفاجأة » (AR) / « Surprise » (EN),
- Compte à rebours dynamique jusqu'au terme : « Naissance prévue dans {weeks} sem. » (FR) / « الولادة متوقعة بعد {weeks} أسابيع » (AR) / « Due in {weeks} weeks » (EN),
- Terme échu le jour même : « Naissance prévue aujourd'hui » (FR) / « الولادة متوقعة اليوم » (AR) / « Due today » (EN).

### 5. Intégration du cycle de vie lors de la déclaration et de l'accouchement
- Lors de la déclaration d'une grossesse (`declarePregnancy`), un ou plusieurs dossiers d'enfants attendus sont générés automatiquement avec le statut `expected`, le genre `unknown` et la date prévue du terme.
- Lors de l'accouchement (`markChildBorn`), le dossier de l'enfant attendu est converti en enfant né (`born`) avec enregistrement de son prénom officiel, de son genre et de sa date de naissance réelle.
- Les fournisseurs Riverpod séparent les listes d'enfants : `bornChildrenProvider` pour les enfants nés et `expectedChildrenProvider` pour les enfants attendus. Le sélecteur d'enfant actif (`selectedChildProvider`) privilégie prioritairement les enfants nés tout en permettant de sélectionner un enfant attendu si aucun enfant né n'est présent.

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/profile/models/profile_models.dart` | Ajout de l'enum `ChildLifecycle`, des champs `lifecycle`, `expectedDate`, `pregnancyId`, `archived`, du genre `unknown` et du thème doré |
| `lib/core/extensions/profile_l10n_extension.dart` | Méthodes d'extension pour les libellés traduits de genre surprise et les textes de décompte de naissance |
| `lib/features/home/widgets/child_summary_card.dart` | Prise en compte du genre surprise, couleur d'accent dorée et icône de soin neutre |
| `lib/features/profile/child_profile_screen.dart` | Passeport bébé adapté avec filigrane neutre et pastille de genre traduite |
| `lib/features/profile/services/profile_service.dart` | Création des dossiers d'enfants attendus lors de la déclaration de grossesse et transition lors de la naissance |
| `lib/features/profile/providers/profile_providers.dart` | Séparation réactive de `bornChildrenProvider` et `expectedChildrenProvider`, sélection d'enfant par défaut |
| `lib/l10n/app_fr.arb` | Clés de traduction françaises pour le genre surprise, le prénom par défaut et les semaines d'attente |
| `lib/l10n/app_ar.arb` | Clés de traduction arabes pour le genre surprise, le prénom par défaut et les semaines d'attente |
| `lib/l10n/app_en.arb` | Clés de traduction anglaises pour le genre surprise, le prénom par défaut et les semaines d'attente |
| `lib/l10n/app_localizations*.dart` | Classes et traductions Dart générées par `flutter gen-l10n` |
| `test/child_model_test.dart` | 28 tests unitaires validant le modèle, la sérialisation Firestore, les couleurs et les extensions i18n |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Document enfant legacy avec genre manquant ou invalide (fallback `unknown`, thème goldenrod, aucun crash) | ✅ |
| Enfant attendu (cycle de vie `expected`, `birthDate` null dans Firestore, `expectedDate` renseigné, libellé dynamique « Naissance prévue... ») | ✅ |
| Isolation des fonctionnalités post-natales (aucun vaccin ou jalon pédiatrique avant la naissance) | ✅ |
| `flutter analyze` clean | ✅ |
