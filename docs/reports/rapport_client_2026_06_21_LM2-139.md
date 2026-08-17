# Rapport — LM2-139 : Marketplace — Commande Produit Partenaire

**Date :** 2026-06-21  
**Ticket :** LM2-139  
**Priorité :** Could Have · 21 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

Parcours de commande complet dans la continuité directe de LM2-138 : **panier → livraison → confirmation → historique avec statuts**. Paiement non intégré en V1, conformément à la note du ticket (le PSP relève de LM2-044) : la commande est créée « à confirmer », réglée à la livraison après appel du partenaire.

### 1. Panier (`CartScreen`)

- Le CTA « Commander » de la fiche produit (posé en LM2-138) ouvre désormais une **feuille d'ajout au panier** : récap produit, sélecteur de quantité (1 à 10), bouton « Ajouter au panier » — puis SnackBar de confirmation avec action directe « Voir le panier »
- **Icône panier avec badge en temps réel** (nombre d'articles) dans l'en-tête du Marketplace, à côté d'une icône « Mes commandes »
- Écran panier : lignes avec visuel/nom/prix, **steppers de quantité** (− passe à la suppression sous 1), bouton « Vider », barre totale fixe avec CTA « Passer la commande »
- Panier de session en mémoire (choix V1 assumé : pas de panier fantôme persistant, pas de données tarifaires stockées localement)

### 2. Checkout (`CheckoutScreen`)

- **Récapitulatif de commande** ligne par ligne avec total
- Bandeau : « Paiement à la livraison. Le partenaire vous appellera pour confirmer la commande. »
- **Formulaire de livraison** (même pattern visuel que la commande d'album et la demande VIP) : nom, téléphone, wilaya, adresse — tous requis
- **Validation du téléphone au format algérien** (commence par 0, 9-10 chiffres, espaces tolérés)
- Écran de **confirmation** avec accès direct à « Mes commandes » ou retour à l'accueil

### 3. Historique et statuts (`MyOrdersScreen`)

- Nouvelle collection Firestore `marketplace_orders`, flux temps réel trié du plus récent au plus ancien
- **5 statuts** avec couleur et icône : En attente 🟡 → Confirmée 🔵 → Expédiée 🔷 → Livrée 🟢 / Annulée 🔴 — les transitions sont pilotées par le back-office, le client ne crée que des commandes « En attente »
- Chaque carte : date/heure, chip de statut coloré, lignes de la commande, nombre d'articles, total
- **Lignes dénormalisées** (nom produit + prix unitaire figés dans la commande) : l'historique reste lisible même si le catalogue change plus tard

### 4. Sécurité (exigences du ticket)

- **Chiffrement** — données de commande (adresse, téléphone) stockées dans Firestore, chiffré au repos par Google Cloud ; aucun stockage local des informations de livraison
- **Anti-fraude basique** — plafonds côté client (10 unités max par produit, 20 produits distincts max par commande), validation des quantités à la soumission, **anti double-soumission** (10 s minimum entre deux commandes, bouton désactivé pendant l'envoi), validation du format téléphone
- **Audit log** — règle Firestore `marketplace_orders` : `create`/`read` sur ses propres commandes uniquement, **`update`/`delete` interdits côté client** — chaque commande est une trace immuable, même pattern que `print_orders` et `album_claims`

### 5. Analytics (les 3 évènements du ticket)

- `product_added_to_cart` — à chaque ajout, avec `product_id` + `quantity`
- `checkout_started` — au passage du panier vers le checkout, avec nombre d'articles + total
- `purchase_completed` — à la création de la commande, avec `order_id`, `total_dzd`, `item_count`

---

## Fichiers créés / modifiés

| Fichier | Changement / Rôle |
|---------|------------------|
| `lib/features/marketplace/models/marketplace_order.dart` | `OrderStatus` (5 statuts), `CartItem`, `MarketplaceOrder`, `OrderLine` · ajout du support de localisation getLabel(locale) pour les 5 statuts |
| `lib/features/marketplace/screens/cart_screen.dart` | Panier avec steppers et barre totale · traduction complète du panier, des en-têtes, des boutons de vidage et de validation, et des états vides |
| `lib/features/marketplace/screens/checkout_screen.dart` | Récap + formulaire livraison + confirmation · traduction complète de tous les formulaires (Wilaya, Adresse), de la validation du téléphone algérien, des erreurs Firestore et des messages de succès |
| `lib/features/marketplace/screens/my_orders_screen.dart` | Historique avec chips de statut temps réel · traduction dynamique des statuts, de la date et de l'heure selon la langue active, et des compteurs d'articles |
| `lib/features/marketplace/providers/order_providers.dart` | Panier (`CartNotifier` + plafonds), total/badge, historique stream, soumission avec anti-fraude |
| `lib/features/marketplace/screens/product_detail_screen.dart` | CTA « Commander » → feuille d'ajout au panier avec quantité (remplace le stub contact) |
| `lib/features/marketplace/screens/marketplace_screen.dart` | Icônes panier (badge live) + « Mes commandes » dans l'en-tête |
| `firestore.rules` | Règle `marketplace_orders` (create/read own, immuable) |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Ajout au panier depuis la fiche produit | ✅ |
| Panier : quantités, suppression, total | ✅ |
| Traduction dynamique complète du panier (AR / FR / EN) | ✅ |
| Checkout : adresse + récapitulatif | ✅ |
| Traduction dynamique complète du formulaire de livraison et de la validation du téléphone | ✅ |
| Traduction dynamique complète de l'écran de succès de commande | ✅ |
| Commande créée en Firestore | ✅ |
| Écran de confirmation | ✅ |
| « Mes commandes » avec statuts | ✅ |
| Traduction dynamique complète de l'historique et formatage local de la date et de l'heure | ✅ |
| 5 statuts de commande prévus (back-office) | ✅ |
| Paiement V1 « à confirmer » (à la livraison) | ✅ |
| Anti-fraude basique (plafonds, anti double-soumission, validation téléphone) | ✅ |
| Audit log (commandes immuables côté client) | ✅ |
| Analytics `product_added_to_cart` | ✅ |
| Analytics `checkout_started` | ✅ |
| Analytics `purchase_completed` | ✅ |
| `flutter analyze` clean | ✅ |

---

## Notes

- Quand le PSP (LM2-044 — CIB/Edahabia) sera intégré, l'écran checkout accueillera l'étape de paiement entre le formulaire et la confirmation ; la structure de la commande (`totalDZD`, lignes dénormalisées) est déjà prête.
- Le back-office devra piloter les transitions de statut (`pending → confirmed → shipped → delivered`) directement dans Firestore — l'app les reflète en temps réel sans mise à jour.
- Comme pour les tickets précédents : pas d'émulateur disponible dans cet environnement — vérification par `flutter analyze` (0 erreur) + relecture du flux complet. **Test manuel sur appareil recommandé avant production.**
