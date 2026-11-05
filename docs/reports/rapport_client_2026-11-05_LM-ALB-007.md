# Rapport Client – Ticket LM-ALB-007

**Date :** 05 novembre 2026  
**Référence Ticket :** LM-ALB-007  
**Titre :** Offre initiale simplifiée — Mettre en avant exclusivement les 2 modèles prédéfinis  
**Type :** Enrichissement fonctionnel & UX Commerciale  
**Priorité :** P2  
**Statut :** ✅ Validé & Conforme aux critères d'acceptation  

---

## 1. Contexte & Objectif

Pour le lancement commercial de LuckyMam, l'expérience de sélection d'albums photos devait être épurée et immédiate afin d'éviter la surcharge cognitive. L'objectif était de mettre exclusivement en avant les deux offres d'impression phares :
1. **L'Album de naissance 6 photos** (A5 : 1 980 DA, A4 : 3 030 DA)
2. **Le Portrait souvenir 1 photo** (A5 : 440 DA, A4 : 690 DA, A3 : 990 DA)

Tous les autres modèles de la gamme (ex. *Première Année*, *Traditions & Fêtes*) devaient être relégués dans une section dédiée « Bientôt disponible ».

---

## 2. Réalisations & Fonctionnalités Implémentées

1. **Scission de l'écran de sélection (`AlbumTemplatePickerScreen`) :**
   - **Section 1 : Modèles d'albums disponibles** (`albumLaunchModelsSectionTitle`) présentant les 2 modèles officiels de lancement avec étiquettes de formats et prix de départ.
   - **Section 2 : Prochainement disponibles** (`albumComingSoonSectionTitle`) contenant les modèles futurs avec un badge doré « Bientôt disponible ».

2. **Interactivité sécurisée sans impasse :**
   - Le clic sur un modèle disponible ouvre la feuille de prévisualisation avec les formats et le bouton d'action de création/continuation.
   - Le clic sur un modèle à venir déclenche un retour haptique léger et une notification SnackBar informative et bienveillante (`albumComingSoonToast`), garantissant zéro plantage ou frustration.

3. **Intégration de la grille tarifaire algérienne officielle :**
   - Affichage immédiat des tarifs sur chaque carte d'album (`${formats} • Dès ${startingPrice} DA`).
   - Détail exhaustif des formats et prix dans la prévisualisation boutique du modèle.

---

## 3. Validation & Tests

- **Tests unitaires :** [`test/album_launch_models_and_branding_test.dart`](file:///c:/Projects/luckymam_mvp/test/album_launch_models_and_branding_test.dart)
- **Internationalisation :** Clés `albumLaunchModelsSectionTitle`, `albumComingSoonSectionTitle`, `albumComingSoonBadge`, `albumComingSoonToast`, `album6PhotosBadge` ajoutées en Français, Arabe (RTL) et Anglais.
- **Respect Purple Ban :** Aucune teinte violette/mauve, utilisation exclusive de la palette LuckyMam (corail, or, vert sauge, bleu céleste).

