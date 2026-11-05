# Rapport Client – Ticket LM-HOME-002

**Date :** 05 novembre 2026  
**Référence Ticket :** LM-HOME-002  
**Titre :** Réorganisation des raccourcis d'Accès rapide  
**Type :** Amélioration UX/UI  
**Priorité :** P2  
**Statut :** ✅ Validé & Conforme aux critères d'acceptation  

---

## 1. Contexte & Objectif

L'écran d'accueil propose une section signature « Accès rapide » sous forme de grille Bento asymétrique. La disposition a été réorganisée pour valoriser les contenus éducatifs (*Reels*) et la *Santé*, tout en repositionnant *Mes souvenirs* de manière fluide et intuitive.

---

## 2. Nouvelle Disposition Implémentée

1. **Colonne de gauche (cartes empilées) :**
   - **En haut :** *Reels éducatifs* (`_ReelsBentoCard`), prend la position principale en haut à gauche.
   - **En bas :** *Mes souvenirs* (`_MemoryBentoCard`), descend en bas à gauche sous les Reels.
2. **Colonne de droite (carte haute pleine hauteur) :**
   - *Santé Enfant / Suivi & Vitalité* (`_TallHealthBentoCard`), prend la position haute à droite (hauteur 226px, alignée avec les deux cartes de gauche).
3. **Respect du sens de lecture et RTL :**
   - Utilisation systématique de `PositionedDirectional` pour les filigranes décoratifs en coin, garantissant un positionnement élégant en français, anglais et arabe (RTL).
4. **Charte graphique et Purple Ban :**
   - Bannissement strict des teintes violettes : filigrane des Reels migré vers le corail signature LuckyMam (`0xFFE85A71`).
5. **Ergonomie & cibles tactiles :**
   - Hauteur des cartes : 106px (raccourcis empilés) et 226px (santé), largement supérieures au minimum requis de 44x44px.

---

## 3. Validation & Tests

- **Tests automatisés :** [`test/quick_access_bento_grid_test.dart`](file:///c:/Projects/luckymam_mvp/test/quick_access_bento_grid_test.dart)
- **Roadmap :** Coché `[x]` dans [`fix/MASTER_TODO.md`](file:///c:/Projects/luckymam_mvp/fix/MASTER_TODO.md).

