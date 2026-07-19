# Rapport — LM2-137 : Bridge Album → Impression

**Date :** 2026-06-21  
**Ticket :** LM2-137  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

L'objectif était de faire de ce pont « album → impression » un moment fort de l'app, pas juste un formulaire de commande. Le point central est un **véritable livre photo généré en PDF**, avec une mise en page soignée — couverture dégradée, photos encadrées, page de clôture — et non une simple liste de miniatures.

### 1. Génération PDF sur mesure (`AlbumPdfService`)

Chaque commande génère un PDF construit page par page :

- **Page de couverture** — dégradé rose→violet aux couleurs de la marque, logo Luckymam sur médaillon blanc, titre de l'album, prénom de l'enfant, date
- **Une page par souvenir** — photo encadrée avec ombre portée, légende (le nom de l'évènement pour un album prédéfini, ou "Page N" pour un album libre), numérotation "X / Y"
- **Page de clôture** — dégradé inversé, message de remerciement personnalisé au prénom de l'enfant

Seules les pages **réellement remplies** sont imprimées — les slots vides de l'album ne polluent pas le livre final.

### 2. Aperçu natif et professionnel (pas un écran fait maison)

Plutôt que de construire un visualiseur PDF depuis zéro, l'aperçu utilise le widget `PdfPreview` du package `printing` (Google) : navigation par vignettes, zoom, boutons natifs de partage et d'impression directe — une expérience que l'on retrouve dans des apps professionnelles, obtenue sans réinventer la roue.

### 3. Parcours complet

```
Album (prédéfini ou standard)
   → Bouton « Commander l'impression » (visible dès 1 souvenir ajouté)
   → Aperçu PDF interactif du livre complet
   → Formulaire de livraison (nom, téléphone, wilaya, adresse)
   → Confirmation + délai estimé
```

### 4. Intégration avec le système d'abonnement VIP

Ce n'est pas une fonctionnalité isolée : elle **reconnaît automatiquement le statut VIP** de l'utilisatrice.

- **Membre VIP** → bandeau vert « Offert avec votre abonnement VIP 🎁 » — cohérent avec le perk déjà annoncé dans les plans d'abonnement
- **Autre membre** → note explicite que l'équipe confirmera le tarif par téléphone (pas de fausse page de paiement — le fulfillment reste manuel à ce stade du MVP, comme pour la demande d'album VIP existante)

Le composant `AlbumPrintCta` est **partagé entre les deux types d'album** (prédéfini et standard) — un seul point de maintenance pour ce bouton, cohérent visuellement partout où il apparaît.

### 5. Analytics

- `album_print_cta_clicked` — au tap du bouton, avec `albumId`, `albumType`, `pageCount`
- `pdf_preview_opened` — à l'ouverture de l'aperçu
- `order_created` — à la confirmation, avec `albumId`, `albumType`, `pageCount`, `isVipFree`

### 6. Sécurité

- **Chiffrement** — les photos utilisées viennent des capsules déjà chiffrées au repos dans Firebase Storage (aucune nouvelle surface d'exposition)
- **RBAC** — chaque commande n'a accès qu'aux albums et enfants appartenant à l'utilisatrice connectée (mêmes providers Firestore scopés par utilisateur que le reste de l'app)
- **Audit commande** — nouvelle collection Firestore `print_orders`, **create/read uniquement** (aucune modification ni suppression côté client), identique au pattern déjà validé pour `album_claims` — chaque commande reste une trace immuable pour le suivi par l'équipe

---

## Fichiers créés / modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/print_album/models/print_order.dart` | Nouveau — modèle de commande |
| `lib/features/print_album/services/album_pdf_service.dart` | Nouveau — génération du livre photo PDF (couverture, pages, clôture) |
| `lib/features/print_album/providers/print_order_providers.dart` | Nouveau — soumission de commande + analytics |
| `lib/features/print_album/screens/album_print_preview_screen.dart` | Nouveau — aperçu PDF natif (`PdfPreview`) |
| `lib/features/print_album/screens/print_order_screen.dart` | Nouveau — formulaire de livraison, bandeau VIP, confirmation |
| `lib/features/memory_book/widgets/album_print_cta.dart` | Nouveau — bouton "Commander" partagé, avec état désactivé si album vide |
| `lib/features/memory_book/screens/predefined_album_detail_screen.dart` | Construction des pages PDF + intégration du bouton |
| `lib/features/memory_book/screens/standard_album_detail_screen.dart` | Construction des pages PDF + intégration du bouton |
| `firestore.rules` | Règle `print_orders` (create/read own, immuable) |
| `pubspec.yaml` | Ajout des packages `pdf` et `printing` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Accès « Commander » depuis un album prédéfini | ✅ |
| Accès « Commander » depuis un album standard | ✅ |
| Prévisualisation PDF avant commande | ✅ |
| Livre photo réellement mis en page (pas une liste brute) | ✅ |
| Finalisation d'une commande d'impression | ✅ |
| Reconnaissance automatique du perk VIP | ✅ |
| Bouton désactivé avec message si l'album est vide | ✅ |
| Chiffrement (aucune nouvelle exposition de médias) | ✅ |
| RBAC (accès limité aux données de l'utilisatrice) | ✅ |
| Audit commande (collection immuable) | ✅ |
| Analytics `album_print_cta_clicked` | ✅ |
| Analytics `pdf_preview_opened` | ✅ |
| Analytics `order_created` | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |

---

## Note — vérification UI

Comme pour LM2-134/135, cet environnement n'a pas d'émulateur Android ni de cible web configurée. La vérification s'est appuyée sur `flutter analyze` (0 erreur nouvelle) et une relecture complète de la chaîne de génération PDF et du flux de commande. **La génération du PDF sur un appareil réel (rendu des polices, des dégradés, du fetch des photos réseau) mérite un test manuel avant mise en production.**
