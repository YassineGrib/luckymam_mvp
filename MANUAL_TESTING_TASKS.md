# 📱 LuckyMam — Guide de Recette & Tâches de Test Manuel
> **Document de vérification pas-à-pas pour tester l'application sur appareil réel (Android / iOS) ou émulateur.**  
> **Dernière mise à jour :** 05 novembre 2026 — Couvre l'intégralité des 31 tickets des Sprints 1, 2, 3 et 4.

---

## 🛠️ Instructions de Démarrage Rapide

1. **Lancement de l'application :**
   ```bash
   flutter run
   ```
2. **Basculement de Langue (Arabe RTL / Français / Anglais) :**
   - Soit depuis l'écran de sélection de langue à l'onboarding.
   - Soit depuis l'onglet **Profil ➔ Langue de l'application**.
   - Soit en changeant la langue système du téléphone (Paramètres ➔ Système ➔ Langues).
3. **Méthode de Recette :**
   - Cochez chaque case `[ ]` ➔ `[x]` après vérification sur votre écran.
   - Si un point ne correspond pas, notez le numéro de tâche et le comportement observé.

---

## 🟢 ÉTAPE 1 : Onboarding, Consentement & Profils

### 📋 Tâche 1.1 — Zone tactile de consentement Loi 18-07 (`LM-ONB-002`, `LM-ONB-001`)
- [ ] **Action :** Ouvrir l'application en mode premier lancement ou depuis l'écran de consentement.
- [ ] **Vérification Libellé :** Le texte affiché est exactement : *« J’accepte les termes de la loi n° 18-07. »* (ou en arabe : *« أوافق على شروط القانون رقم 18-07. »*).
- [ ] **Vérification Tactile :** Touchez **le texte** ou **la case à cocher** :
  - La case doit se cocher immédiatement au premier toucher (aucun double-clic nécessaire).
  - La zone tactile est large et confortable.
  - Le scroll de la page n'est jamais bloqué.
- [ ] **Validation :** Le bouton « Continuer » s'active instantanément.

### 📋 Tâche 1.2 — Sélection de la langue juste après le consentement (`LM-ONB-003`)
- [ ] **Action :** Valider le consentement à la loi 18-07.
- [ ] **Vérification :** L'écran de sélection de langue apparaît immédiatement avec les 3 options :
  1. 🇫🇷 Français
  2. 🇩🇿 العربية (RTL)
  3. 🇬🇧 English
- [ ] **Validation :** Choisir **العربية** ➔ Toute l'interface bascule instantanément de droite à gauche (RTL) de manière fluide.

### 📋 Tâche 1.3 — Génération automatique du profil « MAM » (`LM-ONB-004`)
- [ ] **Action :** Terminer la création de compte ou l'onboarding.
- [ ] **Vérification :** Dans le sélecteur de profil en haut ou dans le Profil :
  - Un profil principal intitulé **« MAM »** (ou « مَام ») est automatiquement créé et sélectionné.
  - Ce profil permet d'enregistrer des capsules pour la maman elle-même avant ou en parallèle de ses enfants.

### 📋 Tâche 1.4 — Ajout d'enfants pour tous les statuts (`LM-ONB-005`)
- [ ] **Action :** Tester l'ajout d'enfant depuis le profil en mode *Espoir*, *Enceinte*, ou *Maman*.
- [ ] **Vérification :** Le bouton « Ajouter un enfant » est débloqué et accessible pour tous les profils sans aucune restriction liée au statut initial.

---

## 🟢 ÉTAPE 2 : Capsules Émotionnelles, Audio & Timeline

### 📋 Tâche 2.1 — Enregistrement et modification de mémo vocal (`LM-CAP-004`)
- [ ] **Action :** Créer une nouvelle capsule ➔ Appuyer sur l'icône microphone pour enregistrer un message vocal.
- [ ] **Vérification Lecteur Audio Intégré :**
  - Un lecteur audio s'affiche avec la durée exacte du mémo.
  - Bouton **Écouter** (Play) ➔ La barre de progression avance et le son se fait entendre.
  - Bouton **Pause** / **Reprendre** ➔ Fonctionne instantanément.
  - Bouton **Réenregistrer** ➔ Supprime le mémo précédent et relance l'enregistrement proprement.

### 📋 Tâche 2.2 — Sélecteur multi-émotions (`LM-CAP-003`)
- [ ] **Action :** Dans le formulaire de capsule, ouvrir la section « Émotions ».
- [ ] **Vérification :**
  - Choisir une émotion principale obligatoire (ex. *Joie* ou *Amour*).
  - Ajouter jusqu'à 3 émotions secondaires complémentaires.
  - **Zéro doublon :** Une émotion déjà sélectionnée ne peut pas être choisie deux fois.
  - Cliquer sur une émotion secondaire pour la promouvoir en émotion principale : le basculement est immédiat.

### 📋 Tâche 2.3 — Enregistrement fiable & Placement immédiat sur la Timeline (`LM-CAP-001`, `LM-CAP-005`)
- [ ] **Action :** Valider la création d'une capsule avec photo, audio et texte.
- [ ] **Vérification :**
  - Le bouton de validation affiche un indicateur de chargement et est temporairement verrouillé (empêche le double-clic).
  - Dès validation, la capsule apparaît **instantanément** sur la Timeline chronologique sous le bon enfant et la bonne date.

### 📋 Tâche 2.4 — Miniatures sur la Timeline & Placeholders Pastel (`LM-CAP-002`)
- [ ] **Action :** Consulter la Timeline.
- [ ] **Vérification Capsule AVEC photo :**
  - La carte affiche une miniature soignée aux coins arrondis (*squircle*), non déformée (`BoxFit.cover`).
  - Le défilement de la Timeline reste parfaitement fluide à 60 fps (pas de saccade mémoire).
- [ ] **Vérification Capsule SANS photo (texte ou vocal seul) :**
  - Un conteneur pastel élégant s'affiche avec l'icône de l'étape de vie (ex. 🌱 Pré-gestation, 🤰 Grossesse, 👶 Bébé) et un badge micro si un audio est attaché.
  - Aucun vide visuel inesthétique.

---

## 🟢 ÉTAPE 3 : Écran d'Accueil, Navigation & Accès Rapide

### 📋 Tâche 3.1 — Persistance de la barre de navigation inférieure (`LM-NAV-001`)
- [ ] **Action :** Naviguer entre l'Accueil, les Capsules, la Timeline, les Notifications et le Profil.
- [ ] **Vérification :** La barre de navigation inférieure reste toujours visible, stable et ancrée au bas de l'écran sans clignotement ni disparition inopinée.

### 📋 Tâche 3.2 — Consultation de « Mes souvenirs » & « Voir tout » (`LM-MEM-001`, `LM-MEM-002`)
- [ ] **Action :** Sur l'écran d'accueil, appuyer sur le bouton **« Mes souvenirs »**.
- [ ] **Vérification :**
  - Ouvre la galerie de **consultation** des souvenirs existants (et NON le formulaire d'ajout direct).
  - Appuyer sur **« Voir tout »** ➔ Charge la collection intégrale avec filtres par enfant/profil, affichage de loader et gestion de liste vide si aucun souvenir.

### 📋 Tâche 3.3 — Réorganisation asymétrique de la grille Bento (`LM-HOME-002`)
- [ ] **Action :** Regarder la section « Accès rapide » sur l'écran d'accueil.
- [ ] **Vérification de la disposition :**
  - **En haut à gauche :** Carte *Reels éducatifs* (avec filigrane corail LuckyMam, zéro violet).
  - **En bas à gauche :** Carte *Mes souvenirs*.
  - **À droite (pleine hauteur) :** Carte haute *Santé Enfant* (alignée avec les deux cartes de gauche).
- [ ] **Vérification RTL (Arabe) :** En arabe, les colonnes s'inversent naturellement de droite à gauche avec alignement parfait des filigranes.

### 📋 Tâche 3.4 — Libellé « Calendrier vaccinal complet » (`LM-HOME-001`)
- [ ] **Action :** Regarder le bandeau hebdomadaire au-dessus de la grille d'accueil.
- [ ] **Vérification du texte :**
  - En français : **« Calendrier vaccinal complet › »** (et non plus « Calendrier complet »).
  - En arabe : **« جدول التطعيمات الكامل › »**.
  - En anglais : **« Full vaccine calendar › »**.

---

## 🟢 ÉTAPE 4 : Albums Photos, Modèles & Impression Haute Définition

### 📋 Tâche 4.1 — Sélection des modèles d'albums simplifiée (`LM-ALB-007`)
- [ ] **Action :** Aller dans *Livres de souvenirs* ➔ Choisir un enfant ➔ Ouvrir le catalogue des modèles prédéfinis.
- [ ] **Vérification :**
  - **Section 1 « Modèles d'albums disponibles » :** Met exclusivement en avant les 2 modèles officiels de lancement :
    1. *Album de naissance* (6 photos — A5: 1 980 DA, A4: 3 030 DA).
    2. *Portrait souvenir* (1 photo — A5: 440 DA, A4: 690 DA, A3: 990 DA).
  - **Section 2 « Prochainement disponibles » :** Affiche les modèles futurs (*Première Année*, *Traditions & Fêtes*) avec un badge doré « Bientôt disponible ».
  - Cliquer sur un modèle à venir ➔ Affiche une notification bienveillante (*« Ce modèle d'album sera disponible très prochainement ! ✨ »*) sans aucun plantage.

### 📋 Tâche 4.2 — Modèle « Portrait souvenir 1 photo » & Format A3 (`LM-ALB-002`)
- [ ] **Action :** Sélectionner le modèle *Portrait souvenir 1 photo*.
- [ ] **Vérification :**
  - Propose 1 seul jalon pour la photo préférée de l'enfant.
  - Dans la prévisualisation et la commande, les 3 formats sont disponibles :
    - A5 : 440 DA
    - A4 : 690 DA
    - **A3 (30 × 42 cm) : 990 DA** (disponible exclusivement pour ce modèle 1 photo).

### 📋 Tâche 4.3 — Rendu 3D des couvertures & Filigrane trèfle discret (`LM-ALB-001`, `LM-ALB-003`)
- [ ] **Action :** Observer les cartes d'albums dans le sélecteur et l'aperçu avant impression (`AlbumPrintPreviewScreen`).
- [ ] **Vérification Design 3D :**
  - Effet livre cartonné avec tranche de reliure, dos en cuir/tissu, reflet de lumière supérieur et tranche de pages blanches.
  - Micro-animation au toucher (effet d'enfoncement tactile).
- [ ] **Vérification Filigrane LuckyMam :**
  - Dans l'aperçu et dans les pages de l'album, le trèfle à 4 feuilles LuckyMam apparaît discrètement dans la **marge inférieure de sécurité** avec une opacité douce de **38 %**.
  - Il ne coupe ni ne masque aucun visage.

### 📋 Tâche 4.4 — Remplacement et recadrage d'une photo d'album (`LM-ALB-004`)
- [ ] **Action :** Dans un album en cours de remplissage, appuyer sur une photo déjà attachée.
- [ ] **Vérification :**
  - Une feuille d'actions s'ouvre : *Remplacer*, *Recadrer*, *Retirer de l'album*.
  - Choisir *Recadrer* ➔ Ouvre l'outil de cadrage interactif avec ratios carrés et portrait.
  - Valider ➔ La photo est mise à jour immédiatement dans la page sans affecter le reste de l'album.

### 📋 Tâche 4.5 — Album libre, choix du nombre de photos & Tarification officielle (`LM-FREE-001`, `LM-ORD-001`)
- [ ] **Action :** Créer un *Album libre* depuis l'accueil des albums.
- [ ] **Vérification Capacité :** Propose les choix exacts : **1, 2, 4, 6, 8, 10 ou 12 photos**.
- [ ] **Vérification Tarifs Algériens (Dinar Algérien DA) :**
  - 1 photo : A5 = 440 DA | A4 = 690 DA | A3 = 990 DA
  - 6 photos : A5 = 1 980 DA | A4 = 3 030 DA
  - 12 photos : A5 = 4 290 DA | A4 = 6 540 DA
- [ ] **Frais de livraison séparés :** Les frais de livraison (500 DA standard, 0 DA pour les membres VIP) sont affichés sur une ligne séparée avec la mention légale : *« Prix hors frais de livraison »*.

### 📋 Tâche 4.6 — Génération et export PDF sans numérotation visible (`LM-ALB-006`, `LM-ALB-005`)
- [ ] **Action :** Générer le PDF de prévisualisation d'un album rempli.
- [ ] **Vérification :**
  - Le document se génère rapidement avec barre de progression.
  - Les textes arabes sont parfaitement formés (ligatures RTL impeccables, aucune inversion de lettres).
  - **Zéro numérotation visible :** Les pages ne comportent aucun numéro visible imprimé (aspect livre d'art pur).

---

## 🟢 ÉTAPE 5 : Album Numérique sous forme de Diaporama Animé (`LM-DIG-001`)

### 📋 Tâche 5.1 — Accès et composition du diaporama
- [ ] **Action :** Aller dans *Livres de souvenirs* ➔ Appuyer sur la bannière **« Album numérique (Diaporama) »** (ou sur le bouton « عرض / Diaporama » dans un album).
- [ ] **Vérification Sélection :**
  - La liste des photos de l'enfant s'affiche avec le compteur `X / 12`.
  - Si moins de 3 photos sont sélectionnées ➔ Le bouton est désactivé avec message : *« Veuillez sélectionner au moins 3 photos pour le diaporama »*.
  - Maximum 12 photos autorisées.

### 📋 Tâche 5.2 — Réorganisation par glisser-déposer (*Drag & Drop*)
- [ ] **Action :** Sur l'écran de création du diaporama, maintenir enfoncée la poignée d'une photo et la déplacer vers le haut ou vers le bas.
- [ ] **Vérification :**
  - L'ordre se réorganise instantanément avec retour haptique.
  - Le numéro d'ordre `#1, #2...` se met à jour en temps réel.

### 📋 Tâche 5.3 — Lecture plein écran & Contrôles
- [ ] **Action :** Appuyer sur **« Lancer le diaporama »**.
- [ ] **Vérification Slide 0 (Ouverture) :** Affiche un carton élégant personnalisé : *« Les doux souvenirs de [Prénom] »* avec le logo trèfle LuckyMam.
- [ ] **Vérification Défilement (3,5 s par photo) :**
  - Les photos défilent automatiquement toutes les 3,5 secondes avec une transition fluide en fondu enchaîné.
  - La jauge segmentée en haut indique l'avancement.
  - Le filigrane discret LuckyMam (38% opacité) est présent en bas.
- [ ] **Contrôles tactiles :**
  - Toucher à gauche ➔ Revient à la photo précédente.
  - Toucher à droite ➔ Passe à la photo suivante.
  - Toucher au centre ou maintenir ➔ Met en pause avec indicateur « Pause ». Toucher à nouveau ➔ Reprend la lecture.

### 📋 Tâche 5.4 — Carton de fin & Partage natif
- [ ] **Vérification Slide Finale :** Affiche le message chaleureux : *« Moments précieux avec LuckyMam 🍀 »*.
- [ ] **Action Bouton Rejouer :** Redémarre le diaporama depuis le début.
- [ ] **Action Bouton Partager :** Ouvre la feuille de partage native du téléphone (`share_plus`) avec un texte pré-rempli pour WhatsApp, Facebook, Instagram ou SMS.

---

## 🟢 ÉTAPE 6 : Offre Commerciale, Abonnements & Transverses

### 📋 Tâche 6.1 — Mise en avant de l'offre « Premium » (`LM-SUB-001`)
- [ ] **Action :** Ouvrir l'écran des abonnements (depuis le profil ou une bannière d'invitation).
- [ ] **Vérification :**
  - La formule **Premium (2 490 DA/an)** est mise en avant par défaut avec le badge *« Recommandée »*.
  - L'action principale propose « Passer à Premium ».
  - L'offre VIP Annuel reste disponible comme palier supérieur prestigieux.

### 📋 Tâche 6.2 — Tableau comparatif des 3 offres (`LM-SUB-002`)
- [ ] **Action :** Faire défiler la page des abonnements jusqu'au tableau comparatif.
- [ ] **Vérification des colonnes et plafonds :**
  1. **Gratuit (0 DA) :** 38 capsules maximum, 1 enfant max, vaccins inclus, sans partage.
  2. **Premium (2 490 DA/an) :** Capsules illimitées, 2 enfants max, partage inclus, tirages au sort.
  3. **VIP Annuel (9 890 DA/an) :** Illimité enfants & capsules, 1 photo A3 imprimée offerte livrée en Algérie sous 2 semaines, carte physique VIP membre avec QR code, privilèges partenaires.
- [ ] **Gestion de plafond :** Vérifier que lorsqu'un utilisateur gratuit approche de 38 capsules, une alerte l'invite courtoisement à passer à Premium sans blocage brutal.

### 📋 Tâche 6.3 — Gestion uniforme des états (`LM-CROSS-001`)
- [ ] **Action :** Tester l'application en mode hors-ligne (mode avion temporaire) ou sur un écran vide.
- [ ] **Vérification :**
  - **Zéro écran blanc :** Un message compréhensible et bienveillant s'affiche (*« Une petite pause réseau... Vos données restent en sécurité »*).
  - Un bouton **« Réessayer »** bien visible permet de recharger la vue dès le rétablissement de la connexion.

### 📋 Tâche 6.4 — Uniformisation terminologique & Arabe RTL (`LM-CROSS-002`)
- [ ] **Action :** Naviguer dans l'application avec la langue système en **Arabe**.
- [ ] **Vérification :**
  - Tous les textes sont traduits sans mélange de français/anglais.
  - L'alignement est rigoureusement inversé de droite à gauche (RTL) : icônes, flèches de retour, jauges de progression et tiroirs latéraux.
  - Les termes officiels sont respectés : *« ذكرياتي »*, *« عرض الكل »*, *« جدول التطعيمات الكامل »*, *« كبسولة مشاعر »*.

### 📋 Tâche 6.5 — Traçabilité sans données sensibles (`LM-CROSS-003`)
- [ ] **Vérification de sécurité (Code & Logs) :** Les journaux d'erreurs techniques enregistrent uniquement le type d'erreur, l'étape et l'OS, et caviardent systématiquement toute adresse email, numéro de téléphone algérien ou URL privée, conformément à la loi 18-07.

---

## 📊 Grille de Synthèse des Tests

| N° | Domaine de Test | Statut Recette | Remarques / Observations |
|:---:|:---|:---:|:---|
| 1 | Onboarding & Loi 18-07 | `[ ]` | |
| 2 | Sélection Langue (AR / FR / EN) | `[ ]` | |
| 3 | Profil MAM & Ajout Enfant | `[ ]` | |
| 4 | Capsules & Enregistreur Audio | `[ ]` | |
| 5 | Multi-émotions (sans doublon) | `[ ]` | |
| 6 | Timeline & Miniatures Pastel | `[ ]` | |
| 7 | Bottom Navigation Bar permanente | `[ ]` | |
| 8 | Mes souvenirs & Voir tout | `[ ]` | |
| 9 | Grille Bento Accès Rapide | `[ ]` | |
| 10 | Libellé Calendrier vaccinal | `[ ]` | |
| 11 | 2 Modèles d'albums de lancement | `[ ]` | |
| 12 | Modèle Portrait 1 photo (A3) | `[ ]` | |
| 13 | Couvertures 3D & Filigrane 38% | `[ ]` | |
| 14 | Recadrage & Remplacement photo | `[ ]` | |
| 15 | Album libre (1 à 12 photos) | `[ ]` | |
| 16 | Export PDF & Zéro numérotation | `[ ]` | |
| 17 | Diaporama animé & Réorganisation | `[ ]` | |
| 18 | Partage natif du Diaporama | `[ ]` | |
| 19 | Abonnements (Premium & VIP) | `[ ]` | |
| 20 | États de chargement & Erreur | `[ ]` | |
| 21 | Mode Arabe RTL intégral | `[ ]` | |

---

*Ce guide de test manuel vous permet de valider de bout en bout l'expérience utilisateur de LuckyMam sur votre appareil.*

