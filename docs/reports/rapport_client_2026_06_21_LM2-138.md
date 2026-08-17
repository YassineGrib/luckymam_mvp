# Rapport — LM2-138 : Marketplace — Catalogue Produits Partenaires

**Date :** 2026-06-21  
**Ticket :** LM2-138  
**Priorité :** Could Have · 13 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

Nouvelle feature complète `lib/features/marketplace/` construite selon l'architecture en tranches du projet (models / data / providers / screens), avec contenu statique V1 comme prévu dans le ticket, mais **structurée pour basculer vers un backoffice sans réécrire l'UI**.

### 1. Modèles de données

- **`ProductCategory`** — 5 catégories : Puériculture 🍼, Alimentation 🥣, Hygiène 🧴, Éveil & Jouets 🧸, Espace Maman 🌸 — chacune avec libellé, icône et couleur tirés de la palette de l'app
- **`MarketplacePartner`** — partenaire : nom, slogan, téléphone, emoji, couleur
- **`MarketplaceProduct`** — produit : nom, description, prix DZD, partenaire, catégorie, points clés (`highlights`), image optionnelle
- **`formattedPrice`** — affichage "2 490 DZD" avec séparateur de milliers

### 2. Catalogue statique V1

`marketplace_data.dart` : **4 partenaires fictifs** (placeholders en attendant les vrais contrats) et **12 produits réalistes** répartis sur les 5 catégories, avec descriptions rédigées, prix en DZD plausibles et 3 points clés par produit. Détail culturel : les cubes d'apprentissage sont bilingues arabe/français, l'huile de soin est à l'argan d'Algérie.

### 3. Écran Marketplace (listing)

- En-tête cohérent avec le style de l'app (icône gradient, titre + sous-titre)
- **Chips de filtrage par catégorie** ("Tous" + 5 catégories), chaque chip prenant la couleur de sa catégorie une fois sélectionnée
- **Grille 2 colonnes** : visuel produit (dégradé de la catégorie + emoji en V1, image réseau quand le backoffice en fournira), nom, partenaire, badge prix coloré
- État vide propre si une catégorie n'a pas de produits

### 4. Fiche produit

- **Hero** plein écran aux couleurs de la catégorie (SliverAppBar épinglée)
- Badge catégorie + prix en grand, nom, description complète
- Section **"Points clés"** à puces cochées
- **Carte partenaire** : emoji, nom, slogan, badge "Partenaire" à la couleur de la marque
- **CTA « Commander »** fixe en bas d'écran (gradient primaire de l'app)

### 5. CTA « Commander » — pont vers LM2-139

La commande in-app est le périmètre de LM2-139 (21 SP, ticket suivant). En attendant, le CTA est **déjà utile** : il ouvre une fiche contact du partenaire avec son numéro de téléphone **copiable en un tap** (presse-papiers + confirmation). LM2-139 remplacera le contenu de cette feuille par le vrai parcours de commande — le point d'accroche est en place.

### 6. Intégration dans l'app

- **Dashboard** — nouvelle section "Boutique Partenaires" avec carte raccourci dégradée orange (même pattern que la carte Santé Enfant), placée entre "Mes Souvenirs" et l'astuce du jour
- **Route GoRouter** `/marketplace` nommée, avec la transition de page standard du projet

### 7. Sécurité (exigences du ticket)

- **Validation contenu (URLs/images)** — le getter `safeImageUrl` n'accepte que des URLs **https absolues bien formées** ; tout autre schéma (http, file, javascript, data…) est rejeté et le placeholder dégradé s'affiche à la place. En V1 statique, aucune URL distante n'est d'ailleurs embarquée — la validation protège le futur flux backoffice
- **Anti-injection** — aucun contenu utilisateur n'entre dans le catalogue ; les textes sont statiques et rendus via des widgets `Text` (pas de HTML/WebView) ; `Image.network` a un `errorBuilder` de repli partout

### 8. Analytics

- `marketplace_opened` — à l'ouverture du marketplace
- `product_viewed` — à l'ouverture d'une fiche, avec `product_id`, `partner_id`, `category`

---

## Fichiers créés / modifiés

| Fichier | Changement / Rôle |
|---------|------------------|
| `lib/features/marketplace/models/marketplace_product.dart` | `ProductCategory`, `MarketplacePartner`, `MarketplaceProduct` · ajout du support de localisation getLabel(locale) pour toutes les catégories |
| `lib/features/marketplace/screens/marketplace_screen.dart` | Listing grille + chips + analytics · traduction dynamique du bandeau de bienvenue, des boutons de commandes et panier, des filtres de catégories et des états vides |
| `lib/features/marketplace/screens/product_detail_screen.dart` | Fiche produit + carte partenaire + CTA « Commander » · traduction complète des sections (Points clés, Partenaire), de la feuille de sélection des quantités, des alertes de panier et des boutons |
| `lib/features/marketplace/data/marketplace_data.dart` | 4 partenaires + 12 produits statiques V1 |
| `lib/features/marketplace/providers/marketplace_providers.dart` | Catalogue, filtre catégorie, lookup partenaire |
| `lib/features/home/widgets/marketplace_shortcut_card.dart` | Carte raccourci dashboard |
| `lib/features/home/tabs/dashboard_tab.dart` | Section "Boutique Partenaires" |
| `lib/core/router/app_router.dart` | Route nommée `/marketplace` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Page Marketplace avec listing produits | ✅ |
| Chaque produit : image/visuel, titre, prix, partenaire | ✅ |
| Traduction dynamique complète des en-têtes et boutons (AR / FR / EN) | ✅ |
| Traduction dynamique de toutes les catégories et chips de filtrage | ✅ |
| Traduction dynamique de la feuille de quantité et des alertes de panier | ✅ |
| Filtrage par catégorie | ✅ |
| Fiche produit détaillée | ✅ |
| CTA « Commander » présent (pont vers LM2-139) | ✅ |
| Accessible depuis le Dashboard + route `/marketplace` | ✅ |
| Validation https des images (contenu backoffice futur) | ✅ |
| Anti-injection (contenu statique, aucun rendu HTML) | ✅ |
| Prêt pour bascule backoffice (providers isolent la source) | ✅ |
| Analytics `marketplace_opened` | ✅ |
| Analytics `product_viewed` | ✅ |
| Mode sombre/clair supporté | ✅ |
| `flutter analyze` clean | ✅ |

---

## Notes

- Les 4 partenaires sont des **placeholders fictifs** — à remplacer par les vrais partenaires (noms, téléphones, produits, tarifs) dès que les contrats seront signés.
- La bascule vers un catalogue piloté par backoffice ne demandera que de remplacer le corps de 2 providers (`marketplacePartnersProvider`, `marketplaceProductsProvider`) par des streams Firestore — aucun écran à modifier.
