# Rapport — LM2-132 : Capsules Vaccins

**Date :** 2026-06-21  
**Ticket :** LM2-132  
**Priorité :** Should Have · 8 SP  
**Statut :** ✅ Terminé

---

## Constat

En analysant le code pour démarrer ce ticket, il s'est avéré que **la fonctionnalité était déjà entièrement implémentée** dans un commit précédent (`673c7c3 — "enable milestone capsules, add album claim rules, and link capsules to vaccine cards"`), antérieur à la session de rattrapage du backlog. Le ticket n'avait simplement jamais été marqué comme terminé dans le suivi.

Plutôt que de recoder une fonctionnalité existante, le travail d'aujourd'hui a consisté à **vérifier le code face à chaque critère d'acceptation** du ticket et à clôturer formellement le suivi.

---

## Vérification des critères d'acceptation

### 1. CTA « Capsule » sur chaque vaccin (liste + détail)

- **Liste** (`vaccine_card.dart`) — bouton "Capsule" dans la section dépliée de chaque carte vaccin, ouvre `CreateCapsuleScreen(vaccineGroupId: ..., preselectedChildId: ...)`
- **Détail** (`vaccine_detail_screen.dart`) — même CTA dans une section dédiée "Souvenir 📸" avec message d'invitation

### 2. Association capsule ↔ vaccin

À la création de la capsule (`capsule_service.dart`, méthode `createCapsule`), si un `vaccineGroupId` est fourni :
- Le document `capsuleId` est écrit sur le statut de vaccination correspondant (`users/{uid}/children/{childId}/vaccinations/{vaccineGroupId}`)
- Si le vaccin n'était pas encore marqué comme fait, il est **automatiquement marqué complété** à la date de création de la capsule (cohérent avec le comportement des jalons — LM2-127)

### 3. Vignette photo sur la fiche vaccin

- **Liste** — miniature 36×36 dans l'en-tête de la carte (remplace le badge de statut) + ligne complète avec photo 56×56 dans la section dépliée
- **Détail** — vignette 70×70 dans la section "Souvenir lié 🌟", avec emoji d'émotion associé
- Chargement via `CachedNetworkImage` avec effet shimmer au chargement et fallback en cas d'erreur réseau

### 4. Analytics

- `vax_capsule_created` — déclenché dans `capsule_service.dart` à la création, avec `childId`, `vaccineGroupId`, `capsuleId`
- `vax_capsule_viewed` — déclenché à chaque ouverture de la capsule liée, depuis la liste **et** le détail

### 5. Sécurité

- **Contrôle d'accès** — vérifié dans `firestore.rules` : la sous-collection `vaccinations` et la collection `capsules` sont toutes deux scopées par `request.auth.uid == userId`, aucun accès croisé possible entre utilisateurs
- **Chiffrement** — les médias sont stockés dans Firebase Storage (chiffrement au repos géré par Google) sous `users/{userId}/capsules/{capsuleId}/`, avec règle d'accès `isOwner(userId)` vérifiée dans `storage.rules`
- **Consentement partage** — couvert par le flux de consentement Loi 18-07 déjà en place (LM2-118), applicable à l'ensemble des médias utilisateur

---

## Fichiers modifiés et vérifiés

| Fichier | Changement / Rôle |
|---------|------------------|
| `lib/features/vaccines/widgets/vaccine_card.dart` | CTA + vignette (vue liste) · traduction dynamique de "Souvenir lié" et formatage de la date attendue |
| `lib/features/vaccines/screens/vaccine_detail_screen.dart` | CTA + vignette (vue détail) · traduction dynamique des titres de section (Souvenir, Souvenir lié, etc.) et texte d'aide |
| `lib/features/capsules/models/emotion.dart` | Ajout d'une méthode de traduction dynamique `getLabel(locale)` pour les émotions afin d'éviter le français forcé (`labelFr`) |
| `lib/features/capsules/services/capsule_service.dart` | Liaison capsule ↔ vaccin, auto-complétion, analytics `vax_capsule_created` |
| `lib/features/capsules/screens/create_capsule_screen.dart` | Support `vaccineGroupId` en paramètre |
| `firestore.rules` / `storage.rules` | Contrôle d'accès vérifié par utilisateur |

---

## Résultat

| Critère | Statut |
|---------|--------|
| CTA "Capsule" sur la liste des vaccins | ✅ |
| CTA "Capsule" sur le détail du vaccin | ✅ |
| Capsule associée au vaccin en Firestore | ✅ |
| Vaccin auto-marqué complété si capsule créée | ✅ |
| Traduction dynamique de l'interface capsule dans les vaccins (AR / FR / EN) | ✅ |
| Traduction dynamique des émotions associées aux capsules | ✅ |
| Vignette photo affichée (liste + détail) | ✅ |
| Analytics `vax_capsule_created` | ✅ |
| Analytics `vax_capsule_viewed` | ✅ |
| Contrôle d'accès Firestore/Storage vérifié | ✅ |
| `flutter analyze` clean | ✅ |
