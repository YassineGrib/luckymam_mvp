# LuckyMam — Master To-Do & Execution Plan

> **Fichiers sources fusionnés :**
> - Référence 1 : [`to fix.md`](file:///c:/Projects/luckymam_mvp/fix/to%20fix.md) (Retours globaux client — Epics 1 à 10)
> - Référence 2 : [`to fix2.md`](file:///c:/Projects/luckymam_mvp/fix/to%20fix2.md) (Spécification détaillée LM-SUB-002 & Arbitrages validés)
>
> **Légende des Priorités :**
> - **[P0 - Bloquant]** : Bloque l'usage ou risque de perte de données.
> - **[P1 - Critique]** : Dysfonctionnement majeur sur une fonctionnalité clé.
> - **[P2 - Important]** : Amélioration UX/UI ou enrichissement fonctionnel.
> - **[P3 - Mineur]** : Ajustement de libellé ou cosmétique.

---

## 🧭 Méthodologie d'Exécution : « Pas-à-Pas » (One-by-One)
1. **Sélection du ticket** en cours (dans l'ordre des sprints).
2. **Implémentation ciblée & Propre** dans le code.
3. **Validation automatique** (`flutter analyze` + `flutter test`).
4. **Test sur appareil réel (Hot Reload)** par le développeur / vous.
5. **Validation & Coche `[x]`**, puis passage au ticket suivant.

---

## 🔴 Sprint 1 : Corrections Bloquantes & Fondations Critiques (P0 / P1)

| Réf | Priorité | Description Synthétique | Statut |
|---|---|---|:---:|
| `LM-CAP-001` | **P0** | **Affichage immédiat de toute capsule dans la Timeline** : Enregistrement fiable, placement chronologique exact et sous le bon profil/enfant/jalon. | `[x]` |
| `LM-CAP-005` | **P0** | **Fiabilisation des capsules depuis la Timeline** : Empêcher les doubles clics, affichage du loading, conservation texte/photo/audio, liaison jalon fiable. | `[x]` |
| `LM-ALB-006` | **P0** | **Génération et sélection PDF fiable** : Réactivité du bouton PDF, affichage de la progression, export correct des photos et textes arabes/français sans corruption. | `[x]` |
| `LM-MEM-001` | **P1** | **Destination du bouton « Mes souvenirs »** : Doit ouvrir la liste de consultation des souvenirs existants (avec filtres Tous/MAM/Enfant) et non le formulaire de création directe. | `[x]` |
| `LM-MEM-002` | **P1** | **Bouton « Voir tout » de Mes souvenirs** : Charger et afficher la collection complète des souvenirs, avec loader, état vide et pagination/gestion d'erreur. | `[x]` |
| `LM-ONB-002` | **P1** | **Zone tactile de la case loi 18-07** : Agrandir la zone de clic pour englober la case et son texte complet, réactivité immédiate sans double appui, suppression du blocage au scroll. | `[x]` |
| `LM-NAV-001` | **P1** | **Stabilisation de la barre de navigation inférieure** : Conserver la bottom bar visible lors des changements de profil/mode et sur l'écran des notifications. | `[x]` |

---

## 🟠 Sprint 2 : Parcours Utilisateur Principal & Règles Métier (P1)

| Réf | Priorité | Description Synthétique | Statut |
|---|---|---|:---:|
| `LM-ONB-003` | **P1** | **Sélection de langue après le consentement** : Afficher l'écran de sélection de langue (Français, Arabe RTL, Anglais) immédiatement après acceptation loi 18-07. | `[x]` |
| `LM-ONB-004` | **P1** | **Génération automatique du profil « MAM »** : Créer automatiquement un profil principal « MAM » à la fin de l'onboarding pour l'associer aux souvenirs et enfants. | `[x]` |
| `LM-ONB-005` | **P1** | **Ajout d'enfants quel que soit le statut** : Débloquer l'ajout d'enfants pour tous les statuts (Espoir, Enceinte, Maman) sans dépendre du statut initial. | `[x]` |
| `LM-CAP-004` | **P1** | **Prévisualisation et modification audio** : Lecteur audio avant validation d'une capsule (Écouter, Pause, Reprendre, Supprimer, Réenregistrer, Valider). | `[x]` |
| `LM-ALB-004` | **P1** | **Remplacement d'une photo sélectionnée dans l'album** : Pouvoir remplacer, recadrer, zoomer ou repositionner une photo sans réinitialiser tout l'album. | `[x]` |
| `LM-FREE-001` | **P1** | **Choix de la quantité de photos pour l'album libre** : Proposer les choix 1, 2, 4, 6, 8, 10, 12 photos avec mise à jour instantanée du prix. | `[x]` |
| `LM-ORD-001` | **P1** | **Intégration de la grille tarifaire complète (DA)** : Grille officielle A5/A4/A3, mention « Prix hors frais de transport », calcul dynamique du panier. | `[x]` |

---

## 🟡 Sprint 3 : Offre Commerciale, Abonnements & Enrichissements UX (P1 / P2)

> 💡 *Note : Intègre tous les arbitrages arrêtés dans `to fix2.md` pour l'offre commerciale.*

| Réf | Priorité | Description Synthétique (Spécifications validées) | Statut |
|---|---|---|:---:|
| `LM-SUB-001` | **P2** | **Mise en avant de Premium au lieu de VIP** : Action par défaut « Passer à Premium », badge « Recommandée », VIP accessible comme niveau supérieur. | `[x]` |
| `LM-SUB-002` | **P1** | **Tableau comparatif des abonnements (Gratuit, Premium, VIP Annuel)** :<br>• **Gratuit (0 DA)** : 38 capsules max, 1 enfant max, suivi vaccins, reels, sans partage.<br>• **Premium (2 490 DA/an)** : Capsules illimitées, 2 enfants max, partage inclus, tirages au sort.<br>• **VIP Annuel (9 890 DA/an)** : Illimité enfants & capsules, 1 photo A3 imprimée offerte livrée en Algérie sous 2 sem, carte VIP physique (pseudo + QR code), privilèges partenaires.<br>• Gestion des plafonds (alerte à 38 capsules, pas de suppression de données à la rétrogradation). | `[x]` |
| `LM-CAP-002` | **P2** | **Miniature de photo sur la Timeline** : Afficher un thumbnail optimisé et non déformé dans la carte de jalon pour chaque capsule avec photo. | `[x]` |
| `LM-CAP-003` | **P2** | **Multi-émotions dans les capsules** : 1 émotion principale obligatoire + émotions secondaires facultatives (sans doublon). | `[x]` |
| `LM-HOME-002` | **P2** | **Réorganisation des raccourcis Accès Rapide** :<br>• Gauche : *Reels éducatifs*<br>• Droite : *Santé Enfant*<br>• Bas : *Mes souvenirs* | `[x]` |
| `LM-ALB-001` | **P2** | **Modernisation du design des albums** : Couverture soignée, aperçu réaliste, marges d'impression sécurisées. | `[x]` |
| `LM-ALB-002` | **P2** | **Modèle album 1 photo (Portrait souvenir)** : Gabarit dédié pour une photo unique en portrait avec recadrage et prix A5/A4/A3. | `[x]` |
| `LM-ALB-003` | **P2** | **Logo Luckymam discret** : Intégrer le trèfle à 4 feuilles sur les créations générées (discret, marge respectée, haute résolution). | `[x]` |
| `LM-ALB-007` | **P2** | **Offre initiale simplifiée (2 albums prédéfinis)** : Mettre en avant *Album 6 photos* et *Portrait souvenir 1 photo*. | `[x]` |
| `LM-DIG-001` | **P2** | **Album numérique sous forme de diaporama** : Réorganisation des photos, prévisualisation, logo début/fin, filigrane discret, export partage. | `[x]` |

---

## 🟢 Sprint 4 : Libellés, Finitions & Transverses (P2 / P3)

| Réf | Priorité | Description Synthétique | Statut |
|---|---|---|:---:|
| `LM-ONB-001` | **P2** | **Texte légal loi 18-07** : Remplacer par « J’accepte les termes de la loi n° 18-07. ». | `[x]` |
| `LM-HOME-001` | **P3** | **Libellé calendrier** : Remplacer « Calendrier complet » par « Calendrier vaccinal complet ». | `[x]` |
| `LM-ALB-005` | **P3** | **Suppression de la numérotation visible des pages** dans les albums et exports PDF. | `[x]` |
| `LM-CROSS-001` | **P1** | **Gestion uniforme des états** : Loading, Success, Empty states explicites, Error handlers avec retry sur tous les écrans. | `[x]` |
| `LM-CROSS-002` | **P2** | **Uniformisation des termes & i18n** : Cohérence FR / AR (RTL) / EN, zéro texte codé en dur. | `[x]` |
| `LM-CROSS-003` | **P1** | **Traçabilité des erreurs techniques** : Logging d'erreurs (création capsule, génération PDF, etc.) sans stocker de données sensibles. | `[x]` |

---

## 📊 Grille Tarifaire Officielle (Référence LM-ORD-001)

*Devise : Dinar Algérien (DA) — Prix hors frais de livraison.*

| Nombre de photos | Format A5 | Format A4 | Format A3 |
|:---:|:---:|:---:|:---:|
| **1 photo** | 440 DA | 690 DA | 990 DA |
| **2 photos** | 830 DA | 1 280 DA | *Non défini (désactivé)* |
| **4 photos** | 1 210 DA | 1 860 DA | *Non défini (désactivé)* |
| **6 photos** | 1 980 DA | 3 030 DA | *Non défini (désactivé)* |
| **8 photos** | 2 750 DA | 4 200 DA | *Non défini (désactivé)* |
| **10 photos** | 3 520 DA | 5 370 DA | *Non défini (désactivé)* |
| **12 photos** | 4 290 DA | 6 540 DA | *Non défini (désactivé)* |
