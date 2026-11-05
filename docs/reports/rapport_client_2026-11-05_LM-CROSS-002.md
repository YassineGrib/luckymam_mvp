# Rapport Client – Ticket LM-CROSS-002

**Date :** 05 novembre 2026  
**Référence Ticket :** LM-CROSS-002  
**Titre :** Traductions et cohérence terminologique trilingue (FR / AR RTL / EN)  
**Type :** Cohérence fonctionnelle & Internationalisation  
**Priorité :** P2  
**Statut :** ✅ Validé & Conforme aux critères d'acceptation  

---

## 1. Contexte & Objectif

Assurer une harmonisation stricte du vocabulaire de l'application LuckyMam sur l'ensemble des parcours et des écrans. Aucun texte ne doit être codé en dur sans passer par les fichiers de localisation, et les termes clés doivent être traduits avec exactitude et sensibilité en français, en arabe (avec affichage de droite à gauche RTL impeccable) et en anglais.

---

## 2. Réalisations & Fonctionnalités Implémentées

1. **Parité absolue des dictionnaires de localisation :**
   - **932 clés** traduites et synchronisées à l'identique entre [`app_fr.arb`](file:///c:/Projects/luckymam_mvp/lib/l10n/app_fr.arb), [`app_ar.arb`](file:///c:/Projects/luckymam_mvp/lib/l10n/app_ar.arb) et [`app_en.arb`](file:///c:/Projects/luckymam_mvp/lib/l10n/app_en.arb).
   - Zero clé orpheline ou manquante.

2. **Harmonisation des termes clés :**
   - *Mes souvenirs* ➔ **« ذكرياتي »** / **« My memories »**
   - *Voir tout* ➔ **« عرض الكل »** / **« See all »**
   - *Calendrier vaccinal complet* ➔ **« جدول التطعيمات الكامل »** / **« Full vaccine calendar »**
   - *Passer à Premium* ➔ **« الترقية إلى بريميوم »** / **« Upgrade to Premium »**
   - *VIP Annuel* ➔ **« في آي بي سنوي »** / **« Annual VIP »**
   - *Capsule émotionnelle* ➔ **« كبسولة مشاعر »** / **« Emotional capsule »**
   - *Timeline* ➔ **« الخط الزمني »** / **« Timeline »**
   - *Livre de mémoires* ➔ **« ألبوم الذكريات »** / **« Memory Book »**
   - *Album numérique* ➔ **« ألبوم رقمي (عرض متحرك) »** / **« Digital Album (Slideshow) »**
   - *Prix hors frais de transport* ➔ **« الأسعار دون مصاريف التوصيل »** / **« Price excluding shipping »**

3. **Prise en charge native de la mise en page RTL :**
   - Remplacement de tous les positionnements fixes gauche/droite par `PositionedDirectional`, `AlignmentDirectional` et `EdgeInsetsDirectional`.

---

## 3. Validation & Tests

- **Audit automatisé :** Script de validation de parité terminologique validant les 932 clés.
- **Tests unitaires :** [`test/cross_cutting_concerns_test.dart`](file:///c:/Projects/luckymam_mvp/test/cross_cutting_concerns_test.dart).
- **Roadmap :** Coché `[x]` dans [`fix/MASTER_TODO.md`](file:///c:/Projects/luckymam_mvp/fix/MASTER_TODO.md).

