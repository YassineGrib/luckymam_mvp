# Rapport — LM2-122 : Ads Gating & Timers par Plan (Régie Interne)

**Date :** 2026-06-21  
**Ticket :** LM2-122  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé

---

## Adaptation du périmètre (décision client)

Aucun contrat n'étant signé avec une régie publicitaire, la fonctionnalité a
été réalisée en **régie interne (« house ads »)** : les espaces publicitaires
sont servis par l'application elle-même, **sans aucun SDK tiers** et sans
partage de données. En V1, ces espaces diffusent de l'auto-promotion
(Premium, Marketplace, Sponsors) — dès qu'un annonceur signera, il suffira
d'ajouter ses créations à l'inventaire.

**Livrable clé demandé par le client :** un document technique complet des
espaces publicitaires — [`docs/specs/spec_technique_espaces_publicitaires.md`](../specs/spec_technique_espaces_publicitaires.md)
— dimensions des images/vidéos, emplacements, zones de sécurité, fréquences,
nommage des fichiers, règles par plan. Prêt à être remis aux futurs
annonceurs.

---

## Ce qui a été fait

### 1. Trois emplacements publicitaires

| Emplacement | Comportement |
|-------------|--------------|
| **Ouverture de l'app** | Après l'écran sponsors, avant l'accueil — max 1 par session |
| **Transitions d'onglets** | Interstitiel plein écran toutes les 4 transitions, avec un délai global minimum de 3 minutes entre deux pubs plein écran |
| **Flux Reels** | 1 page sponsorisée native toutes les 4 vidéos — non bloquante, on la fait défiler comme un reel |

Chaque publicité porte le badge **« Sponsorisé · {Nom} »**.

### 2. Gating et timers par plan (cœur du ticket)

| Plan | Timer non-skippable | Publicités |
|------|--------------------:|------------|
| Gratuit | **5 s** | Oui |
| Premium | **3 s** | Oui |
| **VIP** | — | **Aucune** |

- Le décompte s'affiche dans un rond en haut à droite ; le bouton ✕
  n'apparaît qu'à la fin. Le **bouton retour Android est bloqué** pendant le
  décompte (`PopScope`).
- **VIP : zéro logique publicitaire exécutée** — le gate refuse la demande
  avant toute sélection d'annonce et journalise `ad_blocked_vip`, conforme
  au critère « aucun appel provider/pub ».
- **Anti-bypass** : le plan est lu depuis Firestore (`currentTierProvider`,
  donnée serveur) — jamais depuis un état local modifiable. Au lancement,
  l'app **attend la résolution réelle du plan** (timeout 3 s) avant de
  décider : une VIP ne verra jamais une pub « parce que le plan n'était pas
  encore chargé » ; en cas de doute, la pub est sautée.

### 3. Écrans et composants

- **`InterstitialAdScreen`** — plein écran, image (ou dégradé de marque en
  V1), badge sponsor, décompte, CTA pleine largeur optionnel qui `push` la
  destination (conserve le retour arrière)
- **`ReelAdItem`** — page native du flux Reels : visuel 9:16, dégradé de
  lisibilité, titre + sous-titre + CTA, impression comptée **une seule fois
  et uniquement quand la page devient visible**
- **`AdGate`** — gardien central : gating VIP, cooldown persisté
  (SharedPreferences), seuil de transitions, rotation round-robin de
  l'inventaire par emplacement

### 4. Intégrations

- `SplashScreen` → slot d'ouverture (uniquement pour les utilisatrices
  connectées et consenties, jamais sur onboarding/login)
- `HomeScreen` → interstitiels de transition (fire-and-forget : le
  changement d'onglet n'est jamais retardé)
- `ReelsScreen` → insertion des pages sponsorisées dans le flux, compteur
  de pages mis à jour, tracking vaccin préservé (les pubs ne comptent pas
  comme des reels vus)

### 5. Analytics (les 4 évènements du ticket + clics)

`ad_impression` · `ad_timer_started` (avec la durée) · `ad_closed` ·
`ad_blocked_vip` (avec l'emplacement) · `ad_clicked` (bonus, pour le CTR
annonceur).

### 6. Conformité

- Pas de SDK tiers → aucune donnée personnelle ne quitte l'app
- Mesures via l'analytics interne, couvert par le consentement Loi 18-07
- Images distantes acceptées uniquement en **https** (même validation que
  le marketplace), en prévision du backoffice

---

## Fichiers créés / modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/ads/models/house_ad.dart` | Nouveau — modèle `HouseAd` + `AdPlacement` + validation https |
| `lib/features/ads/data/house_ads_data.dart` | Nouveau — inventaire V1 (5 annonces auto-promo sur 3 emplacements) |
| `lib/features/ads/providers/ads_providers.dart` | Nouveau — timers par plan, `AdGate` (gating VIP, cooldowns, rotation) |
| `lib/features/ads/screens/interstitial_ad_screen.dart` | Nouveau — pub plein écran avec décompte non-skippable |
| `lib/features/ads/widgets/reel_ad_item.dart` | Nouveau — page sponsorisée du flux Reels |
| `lib/features/splash/splash_screen.dart` | Slot d'ouverture (attente du plan réel, timeout 3 s) |
| `lib/features/home/home_screen.dart` | Interstitiels sur transitions d'onglets |
| `lib/features/reels/screens/reels_screen.dart` | Insertion des pubs dans le flux (1/4 reels) |
| `docs/specs/spec_technique_espaces_publicitaires.md` | **Nouveau — spécification annonceurs complète** |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Gratuit : pub non-skippable 5 s minimum | ✅ |
| Premium : pub non-skippable 3 s minimum | ✅ |
| VIP : zéro publicité, zéro logique pub exécutée | ✅ |
| Emplacement ouverture d'app | ✅ |
| Emplacement transitions (interstitiels) | ✅ |
| Emplacement flux Reels | ✅ |
| Timer contrôlé app + plan lu côté serveur (anti-bypass) | ✅ |
| Bouton retour bloqué pendant le décompte | ✅ |
| Fréquences plafonnées (session, cooldown 3 min, 1/4 reels) | ✅ |
| Document technique des formats publicitaires | ✅ |
| Analytics `ad_impression` / `ad_timer_started` / `ad_closed` / `ad_blocked_vip` | ✅ |
| Conformité consentement (pas de SDK tiers) | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |

---

## Notes

- **Mapping des plans** : le ticket évoquait « Freemium/Standard/VIP » ; les
  plans réels de l'app sont Gratuit/Premium/VIP. Mapping appliqué :
  Gratuit → 5 s, Premium → 3 s, VIP → 0, en conservant l'esprit du ticket
  (3 niveaux, VIP totalement épargné).
- **Enforcement serveur complet** (entitlements signés) nécessiterait des
  Cloud Functions — même dépendance que LM2-136. La lecture du plan depuis
  Firestore offre déjà une protection raisonnable pour une régie interne
  sans enjeu financier direct.
- Vidéo publicitaire : formats spécifiés dans le document annonceurs (V2) —
  le lecteur vidéo des Reels existe déjà et sera réutilisé.
- Test manuel sur appareil recommandé (pas d'émulateur dans cet
  environnement de développement).
