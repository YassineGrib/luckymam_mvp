# Rapport Client – Ticket LM-ALB-002

**Date :** 05 novembre 2026  
**Référence Ticket :** LM-ALB-002  
**Titre :** Modèle dédié « Portrait souvenir 1 photo » en format portrait avec recadrage et prix selon le format  
**Type :** Enrichissement fonctionnel & UX  
**Priorité :** P2  
**Statut :** ✅ Validé & Conforme aux critères d'acceptation  

---

## 1. Contexte & Objectif

Permettre aux mamans de commander un tirage portrait d'art individuel mettant en valeur leur cliché favori. Ce modèle spécial à 1 photo (`tpl_portrait_1`) devait supporter les formats A5, A4 et le prestigieux format d'affiche A3 (réservé exclusivement à cette offre portrait), avec un recadrage soigné et un calcul tarifaire instantané.

---

## 2. Réalisations & Fonctionnalités Implémentées

1. **Modèle de données & Catalogue (`tpl_portrait_1`) :**
   - Configuration dédiée dans `album_templates_data.dart` avec l'attribut `isSinglePortraitPhoto: true`.
   - 1 jalon unique dédié : `Photo portrait souvenir` (`portrait_main`).
   - Formats d'impression supportés : `['A5', 'A4', 'A3']`.
   - Prix d'appel de lancement : `440 DA` (A5).

2. **Grille tarifaire et validation des formats (`AlbumPricingService`) :**
   - **A5 (15 × 21 cm) :** 440 DA
   - **A4 (21 × 30 cm) :** 690 DA
   - **A3 (30 × 42 cm) :** 990 DA
   - Le sélecteur de format dans l'écran de commande (`PrintOrderScreen`) débloque automatiquement le format A3 lorsque le nombre de photos est égal à 1, tout en le désactivant pour les albums multi-photos conformément aux contraintes de reliure.

3. **Outil de recadrage haute précision :**
   - Intégration transparente avec `PredefinedAlbumDetailScreen` et les ratios de recadrage portrait (4:5 et 3:4) garantissant une composition harmonieuse sans bordure blanche ni étirement indésirable.

---

## 3. Validation & Tests

- **Tests unitaires :** [`test/album_launch_models_and_branding_test.dart`](file:///c:/Projects/luckymam_mvp/test/album_launch_models_and_branding_test.dart)
- **Localisation :** Clé `albumPortrait1PhotoBadge` ("1 photo portrait" / "صورة بورتريه واحدة") intégrée et vérifiée.

