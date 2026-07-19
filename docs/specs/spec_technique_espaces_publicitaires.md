# Spécification Technique — Espaces Publicitaires Luckymam

**Version :** 1.0 · **Date :** 2026-06-21 · **Ticket :** LM2-122

Ce document décrit les espaces publicitaires disponibles dans l'application
Luckymam, les formats et dimensions des créations à fournir par les
annonceurs, et les règles de diffusion. Il sert de référence pour les
futurs contrats publicitaires.

---

## 1. Principe général

- **Régie interne (« house ads »)** : les publicités sont servies par
  l'application elle-même. **Aucun SDK publicitaire tiers** n'est intégré,
  aucune donnée utilisateur n'est partagée avec un réseau publicitaire.
- **Diffusion par plan d'abonnement** (voir §5) : les membres VIP ne voient
  **aucune** publicité.
- Chaque publicité porte un badge visible **« Sponsorisé · {Nom} »**.

---

## 2. Emplacements disponibles

### 2.1 — Ouverture de l'application (« Splash »)

| Propriété | Valeur |
|-----------|--------|
| Moment | Au lancement, après l'écran sponsors, avant l'accueil |
| Format | Plein écran, portrait |
| Fréquence | **Maximum 1 par session** d'utilisation |
| Fermeture | Bouton ✕ après le délai non-skippable du plan (§5) |
| Bouton d'action | Optionnel, pleine largeur en bas d'écran |

### 2.2 — Interstitiel de transition

| Propriété | Valeur |
|-----------|--------|
| Moment | Entre les navigations importantes (changements d'onglet) |
| Format | Plein écran, portrait |
| Fréquence | 1 affichage maximum toutes les **4 transitions**, avec un délai minimum de **3 minutes** entre deux publicités plein écran (splash inclus) |
| Fermeture | Bouton ✕ après le délai non-skippable du plan (§5) |
| Bouton d'action | Optionnel, pleine largeur en bas d'écran |

### 2.3 — Flux Reels (natif)

| Propriété | Valeur |
|-----------|--------|
| Moment | Inséré dans le flux vertical des Reels éducatifs |
| Format | Page plein écran 9:16, défilable comme un reel normal |
| Fréquence | **1 publicité toutes les 4 vidéos** |
| Fermeture | Non bloquant — l'utilisatrice glisse simplement vers le reel suivant |
| Bouton d'action | Optionnel, en bas de page |

---

## 3. Formats des créations (assets à fournir)

### 3.1 — Image (tous les emplacements) — V1

| Spécification | Valeur |
|---------------|--------|
| Dimensions | **1080 × 1920 px** (ratio 9:16, portrait) |
| Formats acceptés | PNG, JPEG, WebP |
| Poids maximum | **500 Ko** |
| Espace colorimétrique | sRGB |
| Résolution | 72 dpi minimum (écran) |

### 3.2 — Vidéo (emplacements Splash / Interstitiel / Reels) — V2

| Spécification | Valeur |
|---------------|--------|
| Dimensions | **1080 × 1920 px** (9:16, portrait) |
| Conteneur / codecs | MP4 — vidéo H.264, audio AAC |
| Durée maximum | **15 s** (splash/interstitiel) · **20 s** (reels) |
| Poids maximum | **10 Mo** (splash/interstitiel) · **15 Mo** (reels) |
| Fréquence d'images | 30 fps |
| Débit conseillé | 4–6 Mbit/s |
| Audio | Coupé par défaut au lancement (l'utilisatrice active le son) |

> ℹ️ L'infrastructure vidéo (lecteur des Reels) existe déjà dans l'app ;
> la diffusion de créations vidéo sera activée en V2.

### 3.3 — Zones de sécurité (safe areas)

Les éléments d'interface de l'app se superposent à la création.
**Ne placer aucun texte ni logo important dans ces zones :**

| Emplacement | Haut | Bas | Côtés |
|-------------|------|-----|-------|
| Splash / Interstitiel | 220 px (badge sponsor + minuteur) | 320 px (bouton d'action) | 48 px |
| Reels | 240 px (barre de navigation + badge) | 420 px (titre, description, bouton) | 48 px |

### 3.4 — Éléments texte fournis avec la création

| Champ | Limite | Exemple |
|-------|--------|---------|
| Nom de l'annonceur | 30 caractères | « BébéConfort DZ » |
| Titre | 40 caractères | « Le meilleur pour bébé » |
| Sous-titre | 90 caractères | « Puériculture et éveil, livrés chez vous. » |
| Libellé du bouton | 20 caractères | « Découvrir » |
| Destination du bouton | Route interne app **ou** URL https (V2) | `/marketplace` |

---

## 4. Nommage et livraison des fichiers

```
{annonceur}_{emplacement}_{format}_{AAAAMMJJ}.{ext}

Exemples :
  bebeconfort_splash_1080x1920_20260701.png
  naturalait_reel_1080x1920_20260701.mp4
```

- Livraison : fichiers sources + textes dans un dossier partagé, **7 jours
  ouvrés** avant la date de mise en ligne souhaitée.
- Toute création est validée par l'équipe Luckymam avant diffusion
  (conformité au public cible : mamans et enfants).

---

## 5. Règles de diffusion par plan d'abonnement

| Plan | Durée non-skippable | Publicités |
|------|---------------------|------------|
| **Gratuit** | **5 secondes** | Tous les emplacements |
| **Premium** (2 490 DZD/an) | **3 secondes** | Tous les emplacements |
| **VIP** (9 890 DZD/an) | — | **Aucune publicité** |

- Le minuteur est affiché à l'écran ; le bouton de fermeture n'apparaît
  qu'à la fin du décompte. Le bouton retour Android est bloqué pendant
  le décompte.
- Pour les membres VIP, **aucune logique publicitaire n'est exécutée**
  (pas de sélection d'annonce, pas d'impression comptée).
- Le plan est lu depuis le serveur (Firestore) — la durée du minuteur ne
  peut pas être modifiée localement par l'utilisatrice.

---

## 6. Mesures fournies aux annonceurs

Chaque événement est horodaté et anonyme (aucun profil publicitaire) :

| Événement | Déclenchement |
|-----------|---------------|
| `ad_impression` | La publicité s'affiche à l'écran |
| `ad_timer_started` | Début du décompte non-skippable (durée incluse) |
| `ad_closed` | Fermeture par l'utilisatrice |
| `ad_clicked` | Tap sur le bouton d'action |
| `ad_blocked_vip` | Emplacement demandé mais bloqué (membre VIP) |

Indicateurs dérivés : impressions par emplacement, taux de clic (CTR),
taux de complétion du décompte.

---

## 7. Intégration technique (référence développeur)

- Modèle : `lib/features/ads/models/house_ad.dart`
- Inventaire V1 (statique) : `lib/features/ads/data/house_ads_data.dart`
  — ajouter une entrée `HouseAd` par campagne, avec `assetPath` pointant
  vers `assets/ads/{fichier}` (déclarer le dossier dans `pubspec.yaml`)
- Règles de diffusion : `lib/features/ads/providers/ads_providers.dart`
  (cooldown, seuil de transitions, intervalle reels — constantes en tête
  de fichier)
- Les URLs d'images distantes sont acceptées uniquement en **https**
  (validation dans le modèle) en prévision du backoffice.

---

## 8. Conformité

- Pas de SDK publicitaire tiers, pas de partage de données avec des
  réseaux publicitaires, pas de profilage.
- Les événements de mesure transitent par le système d'analytics interne
  déjà couvert par le consentement Loi 18-07 recueilli au premier
  lancement.
- Contenu publicitaire : uniquement des produits/services adaptés au
  public (mamans, bébés, enfants) ; validation éditoriale avant diffusion.
