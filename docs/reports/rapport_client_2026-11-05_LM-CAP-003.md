# Rapport Client – Ticket LM-CAP-003

**Date :** 05 novembre 2026  
**Référence Ticket :** LM-CAP-003  
**Titre :** Permettre plusieurs émotions dans une capsule  
**Type :** Amélioration fonctionnelle  
**Priorité :** P2  
**Statut :** ✅ Validé & Conforme aux critères d'acceptation  

---

## 1. Contexte & Objectif

La maternité et l'enfance suscitent des émotions riches et complexes (par exemple la fierté mêlée à la tendresse ou la fatigue). Les utilisatrices souhaitaient pouvoir exprimer plusieurs sentiments dans une même capsule tout en conservant une émotion directrice forte.

---

## 2. Règles Métier & Implémentation

1. **Émotion principale obligatoire & sélecteur tactile :**
   - Une émotion principale demeure obligatoire pour valider et enregistrer une capsule (`_selectedEmotion != null`).
   - La sélection principale s'effectue via une grille ergonomique de 8 émotions distinctives.

2. **Émotions secondaires (optionnelles, jusqu'à 3 maximum) :**
   - L'utilisatrice peut ajouter jusqu'à 3 émotions secondaires sous forme de pastilles tactiles (touch targets >= 44x44px).
   - Compteur en temps réel affiché : `0/3`, `1/3`, `2/3`, `3/3`.

3. **Règle stricte d'unicité (Zéro doublon) & Auto-promotion :**
   - Une même émotion ne peut jamais être sélectionnée deux fois.
   - Si une émotion déjà choisie comme secondaire est ensuite cliquée comme émotion principale, le système applique une **auto-promotion** : elle devient l'émotion principale et est automatiquement retirée de la liste des émotions secondaires.

4. **Persistance & Écosystème complet :**
   - **Modèle `Capsule` :** Ajout de `secondaryEmotions: List<Emotion>` et du getter synthétique `allEmotions`.
   - **Firestore :** Sauvegardé sous `'secondaryEmotions': ['tender', 'proud']`.
   - **Écran de création & d'édition (`CreateCapsuleScreen`) :** Sauvegarde et réouverture avec restauration complète de toutes les émotions choisies.
   - **Écran de détail (`CapsuleDetailScreen`) :** Affichage de l'émotion principale accompagnée des badges d'émotions secondaires.
   - **Timeline (`TimelineRail` / `_CapsuleCard`) :** Affichage compact et épuré avec badge principal et indicateur discret des émotions secondaires (`🥰 😴`) sans surcharger la carte.

5. **Respect du Purple Ban :**
   - Remplacement de toute teinte violette/indigo pour l'émotion `sleepy` par un bleu crépusculaire apaisant (`0xFF0284C7`), en parfaite conformité avec la charte LuckyMam.

---

## 3. Validation & Tests

- **Tests unitaires automatisés :** [`test/capsule_multi_emotion_and_thumbnail_test.dart`](file:///c:/Projects/luckymam_mvp/test/capsule_multi_emotion_and_thumbnail_test.dart)
  - Test de création avec émotions secondaires.
  - Test de dé-duplication et plafonnement à 3 maximum.
  - Test d'auto-promotion.
  - Test de sérialisation / désérialisation Firestore.
- **Traductions trilingues (FR / AR / EN) :** Clés `capsulePrimaryEmotion`, `capsuleSecondaryEmotions`, `capsuleSecondaryEmotionsHint` ajoutées et synchronisées dans `app_fr.arb`, `app_ar.arb`, et `app_en.arb`.
- **Intégrité du code :** 100% balancé et vérifié.

