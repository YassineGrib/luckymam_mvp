# Rapport — LM2-130 : Conseils par Jalon

**Date :** 2026-06-21  
**Ticket :** LM2-130  
**Priorité :** Should Have · 5 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Fichier de contenu statique `milestone_advice_data.dart`

Un nouveau fichier de données statiques regroupe un conseil **dédié et personnalisé pour chacun des 70 jalons** de la ligne de vie (couverture 100 %, aucun jalon ne tombe sur un texte générique) :

- **`MilestoneAdvice`** — modèle enrichi : `explanation` (texte explicatif) + `keyPoints` (points clés médicaux / pratiques) + `photoTips` (idées photo)
- **`milestoneAdviceById`** — map par `Milestone.id` réel, avec un contenu rédigé sur mesure pour chaque étape
- **`milestoneCategoryAdvice`** — fallback de sécurité par catégorie (`emotion`, `sante`, `culture`, `religion`)
- **`getMilestoneAdvice(id, category)`** — cascade id → catégorie → défaut générique

**Vaccins personnalisés par âge** : chaque rendez-vous vaccinal a un contenu spécifique tiré de la base officielle `Base des données Vaccin.csv` (calendrier national algérien) :

| Jalon | Vaccin | Protège contre |
|-------|--------|----------------|
| Naissance | BCG + HBV | Tuberculose, hépatite B |
| 2 mois | Hexavalent + VPOb + VPC | Diphtérie, tétanos, coqueluche, polio, Hib, hépatite B, pneumocoque |
| 4 mois | Hexavalent + VPOb + VPC | (2ᵉ dose) |
| 11 mois | ROR | Rougeole, oreillons, rubéole |
| 12 mois | Hexavalent + VPOb + VPC | (rappel) |
| 18 mois | ROR | (2ᵉ dose) |
| 6 ans | DTCa-VPI | Diphtérie, tétanos, coqueluche, polio |
| 11-13 ans | dT | Tétanos, diphtérie (dose réduite) |
| 16-18 ans | dT | (rappel) |
| 18 ans+ | dT décennal | (rappel tous les 10 ans) |

Le contenu est entièrement en français, rédigé pour une maman algérienne. La structure reste extensible pour une alimentation future via CMS / back-office admin (LM2-021).

### 2. Bouton « Conseils & idées photo » sur le détail du jalon

Un bouton pleine largeur a été ajouté dans `MilestoneDetailScreen`, positionné entre le bouton "Capturer ce moment" et les actions secondaires :

- Icône ampoule (`lightbulb_rounded`) colorée avec la couleur de catégorie du jalon
- Bordure assortie à la catégorie pour renforcer la cohérence visuelle
- Fond adapté mode sombre/clair

### 3. Bottom sheet `_ConseilSheet`

Une `DraggableScrollableSheet` (65 % → 92 % de hauteur) s'ouvre au tap :

**Section 1 — Comprendre ce jalon**
- Texte explicatif sur fond coloré (teinte catégorie à 7 % d'opacité)
- Contexte développemental, médical ou culturel selon le type de jalon

**Section 2 — À retenir** (affichée si présente)
- Points clés à puces : pour les vaccins → maladies couvertes + soins post-injection ; pour les étapes motrices → ce qu'il faut surveiller et quand consulter
- Icône check bleue (`AppColors.info`)

**Section 3 — Idées pour la photo**
- Liste numérotée de conseils photo concrets
- Chaque numéro est un badge gradient rose (couleur primaire de l'app)
- Conseils pratiques : cadrage, lumière, timing, accessoires

### 4. Analytics

`milestone_advice_opened` déclenché à chaque ouverture du bottom sheet, avec paramètre `milestone_id`.

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/timeline/data/milestone_advice_data.dart` | Nouveau — contenu statique : 70 entrées dédiées (1 par jalon) + 4 fallbacks catégorie ; vaccins basés sur la base officielle |
| `lib/features/timeline/screens/milestone_detail_screen.dart` | Bouton "Conseils", méthodes `_buildConseilButton` + `_showConseilSheet`, widgets `_ConseilSheet`, `_SectionTitle`, `_PhotoTipTile`, `_KeyPointTile` · traduction dynamique de l'interface de la fiche conseils |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Bouton "Conseils" visible sur chaque jalon | ✅ |
| Explication du jalon affichée | ✅ |
| Traduction dynamique de l'interface de la fiche conseils (AR / FR / EN) | ✅ |
| Titre du jalon traduit dynamiquement dans la fiche conseils | ✅ |
| Conseil dédié pour les 70 jalons (couverture 100 %) | ✅ |
| Vaccins personnalisés par âge (base officielle) | ✅ |
| Section "À retenir" (points médicaux / pratiques) | ✅ |
| Conseils photo concrets par jalon | ✅ |
| Fallback catégorie de sécurité | ✅ |
| Style cohérent avec la couleur de catégorie | ✅ |
| Mode sombre/clair supporté | ✅ |
| Analytics `milestone_advice_opened` | ✅ |
| Contenu extensible (CMS / LM2-021) | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |
