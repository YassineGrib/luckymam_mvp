# Rapport de Livraison — LM-ALB-004 : Remplacement et Recadrage d'une Photo dans l'Album

**Date :** 2026-11-03  
**Ticket :** LM-ALB-004 (Priorité P1 – Majeure)  
**Module :** Albums & Livres Souvenirs — Remplacement, Recadrage, Zoom, Repositionnement (`ImageCropScreen`, `AlbumPhotoActionSheet`, `StandardAlbumDetailScreen`, `PredefinedAlbumDetailScreen`)  
**Statut :** ✅ Validé & Prêt pour Test Appareil  

---

## 🎯 Problèmes résolus & Spécifications implémentées

1. **Remplacement sans réinitialisation de l'album :**
   - **Comportement précédent :** Les pages remplies d'un album ne proposaient qu'un remplacement sommaire via sélection de capsule ou une suppression brutale, sans possibilité de recadrer, de zoomer ou de choisir une nouvelle photo directement depuis la galerie ou l'appareil photo. L'album prédéfini ne disposait d'aucune barre d'actions sous les pages complétées en mode livre.
   - **Nouveau comportement :** L'utilisatrice peut remplacer, recadrer, repositionner ou ajuster le zoom d'une photo sur n'importe quelle page ou jalon sans recommencer tout l'album. Toutes les autres pages et photos restent 100% intactes.

2. **Écran de Recadrage Avancé Multi-Format (`ImageCropScreen`) :**
   - **Sources d'images flexibles :** Accepte aussi bien un fichier local (`File? imageFile`) qu'une URL distante (`String? imageUrl`), téléchargeant et décodant l'image en haute résolution.
   - **Ratios d'aspect multiples :** Permet de basculer instantanément entre plusieurs formats de mise en page pour photobook ou story : Carré `1:1`, Portrait `4:5`, Classique `3:4` et Plein écran `9:16`.
   - **Repositionnement et Zoom tactile :** Utilise `InteractiveViewer` avec contrôle tactile fluide à deux doigts (zoom jusqu'à 4.5x, déplacement 2D, rotation à 90°, réinitialisation au centre, grille des tiers et mode aperçu sans bandes).
   - **Annulation sécurisée :** En cas d'annulation ou de fermeture, aucune modification n'est enregistrée (`null`), la photo d'origine reste rigoureusement inchangée.

3. **Feuille d'actions unifiée (`AlbumPhotoActionSheet`) :**
   - Nouvelle feuille modale élégante, respectant la charte esthétique LuckyMam (palette chaude terracotta/corail, aucune couleur violette/indigo - Purple Ban, cibles tactiles >= 48px) :
     - **Choisir parmi mes souvenirs :** Sélection rapide parmi les capsules existantes de l'enfant.
     - **Prendre une photo :** Ouvre l'appareil photo avec passage direct par le recadreur.
     - **Choisir depuis la galerie :** Ouvre la galerie du téléphone avec recadrage interactif.
     - **Recadrer & Ajuster la photo actuelle :** Ouvre directement le studio de recadrage sur l'image en place.
     - **Retirer de la page :** Supprime la photo de la page d'album avec dialogue de confirmation rassurant.
     - **Annuler :** Ferme la feuille sans aucun impact.

4. **Préservation stricte de la capsule originale :**
   - Lorsqu'une photo est recadrée ou modifiée spécifiquement pour une page d'album, une nouvelle capsule dédiée liée au créneau d'album est créée.
   - La photo originale dans la timeline et les souvenirs de l'utilisatrice n'est **jamais écrasée**.
   - Le rendu actualisé apparaît immédiatement dans la prévisualisation (mode livre et mode mosaïque) et persiste lors du passage à l'étape suivante ou lors de l'export PDF.

5. **Localisation trilingue complète :**
   - Ajout de 21 clés de localisation en Français, Arabe (support RTL natif) et Anglais.

---

## 📂 Fichiers modifiés & créés

| Fichier | Nature de la modification |
|---|---|
| `lib/features/capsules/widgets/image_crop_screen.dart` | Support de `imageUrl`, sélection dynamique de ratios (1:1, 4:5, 3:4, 9:16), gestion des erreurs réseau et rendu haute résolution. |
| `lib/features/memory_book/widgets/album_photo_action_sheet.dart` | Nouveau composant modal proposant les choix de remplacement, prise de vue, import galerie, recadrage et retrait de photo. |
| `lib/features/memory_book/screens/standard_album_detail_screen.dart` | Ajout des boutons « Remplacer », « Recadrer » et « Vider », raccourci tactile sur le canvas, intégration de la création de capsule recadrée isolée. |
| `lib/features/memory_book/screens/predefined_album_detail_screen.dart` | Ajout de la barre d'actions sous les pages remplies en mode livre, puce de recadrage rapide et liaisons avec `PredefinedAlbumActionsNotifier`. |
| `lib/l10n/app_*.arb` & `app_localizations*.dart` | Ajout des 21 clés de localisation trilingues pour les ratios, actions et messages de succès. |
| `test/album_photo_replacement_test.dart` | Tests automatisés validant le rendu du sheet, la traduction arabe, la préservation des autres pages et la non-altération de la capsule source. |
| `fix/MASTER_TODO.md` | Ticket `LM-ALB-004` coché `[x]`. |

---

## 🧪 Critères d'Acceptation Validés

- [x] L'utilisatrice n'est pas obligée de recommencer tout l'album pour remplacer ou ajuster une photo.
- [x] Le remplacement ou le recadrage conserve l'intégralité des autres pages et photos.
- [x] Le rendu actualisé apparaît immédiatement dans la prévisualisation de l'album (mode livre et mode grille).
- [x] La photo originale de la capsule source n'est pas écrasée et reste intacte dans la timeline.
- [x] Les modifications sont conservées lors de la commande ou du passage à l'étape suivante.
- [x] L'utilisatrice peut à tout moment annuler les modifications sans effet secondaire.

