# Rapport de Livraison — LM-ORD-001 : Intégration de la Grille Tarifaire Complète des Albums (DA)

**Date :** 2026-11-04  
**Ticket :** LM-ORD-001 (Priorité P1 – Majeure)  
**Module :** Impression & Commandes — Tarification Officielle & Panier (`PrintOrderScreen`, `AlbumPricingService`, `PrintOrder`)  
**Statut :** ✅ Validé & Prêt pour Test Appareil  

---

## 🎯 Problèmes résolus & Spécifications implémentées

1. **Intégration de la grille officielle en Dinar Algérien (DA) :**
   - Implémentation stricte de la grille tarifaire fournie :
     - **1 photo** : A5 = 440 DA, A4 = 690 DA, A3 = 990 DA
     - **2 photos** : A5 = 830 DA, A4 = 1 280 DA, A3 = *Non défini*
     - **4 photos** : A5 = 1 210 DA, A4 = 1 860 DA, A3 = *Non défini*
     - **6 photos** : A5 = 1 980 DA, A4 = 3 030 DA, A3 = *Non défini*
     - **8 photos** : A5 = 2 750 DA, A4 = 4 200 DA, A3 = *Non défini*
     - **10 photos** : A5 = 3 520 DA, A4 = 5 370 DA, A3 = *Non défini*
     - **12 photos** : A5 = 4 290 DA, A4 = 6 540 DA, A3 = *Non défini*
   - Formatage respectueux des séparateurs de milliers (ex : `1 980 DA`, `5 370 DA`).

2. **Règles de gestion & Frais de livraison séparés :**
   - **Sous-total album** : Calculé en fonction du format (A5, A4, A3) et de la quantité d'exemplaires commandés.
   - **Mention obligatoire** : « Prix hors frais de livraison » clairement visible sous le sous-total.
   - **Ligne de transport dédiée** :
     - Utilisatrice standard : 500 DA (affiché séparément).
     - Membre VIP : 0 DA avec badge « Inclus VIP 👑 ».
   - **Total de la commande** : Recalculé instantanément sans rechargement de page dès que l'utilisatrice modifie le format ou le nombre d'exemplaires.

3. **Interdiction d'inventer des prix pour combinaisons non définies :**
   - Pour tout album de 2 à 12 photos, l'option A3 est désactivée et annotée comme réservée aux portraits 1 photo.
   - Si une combinaison non définie était soumise, le système bloque la validation avec message explicatif clair.

4. **Immuabilité & Traçabilité de la commande (`PrintOrder`) :**
   - La commande enregistre le format choisi (`format`), le prix unitaire, le sous-total (`subtotal`), les frais de livraison (`shippingFee`), le total final (`totalAmount`) et le nombre d'exemplaires (`albumCopies`).
   - Toute modification ultérieure de la grille tarifaire ne modifie en aucun cas l'historique financier des commandes passées.

---

## 📂 Fichiers modifiés & créés

| Fichier | Nature de la modification |
|---|---|
| `lib/features/print_album/services/album_pricing_service.dart` | Matrice tarifaire officielle, calculs de frais de port et formatage monétaire avec séparateurs de milliers. |
| `lib/features/print_album/models/print_order.dart` | Ajout des champs `format`, `subtotal`, `shippingFee`, `totalAmount`, `albumCopies` pour un enregistrement immuable. |
| `lib/features/print_album/screens/print_order_screen.dart` | Sélecteur de format interactif, réglage d'exemplaires, tableau récapitulatif détaillé avec sous-total, livraison et total en temps réel. |
| `lib/l10n/app_*.arb` & `app_localizations*.dart` | Clés de localisation pour les formats, sous-totaux, frais de livraison et mentions légales. |
| `test/album_quantity_pricing_test.dart` | Tests automatisés validant la conformité exacte de tous les tarifs (440 DA, 1 980 DA, 5 370 DA, etc.), le calcul VIP et la désactivation A3. |
| `fix/MASTER_TODO.md` | Ticket `LM-ORD-001` coché `[x]`. |

---

## 🧪 Critères d'Acceptation Validés

- [x] Un album A5 avec 6 photos affiche 1 980 DA hors transport.
- [x] Un album A4 avec 10 photos affiche 5 370 DA hors transport.
- [x] Un portrait A3 avec 1 photo affiche 990 DA hors transport.
- [x] Aucun prix A3 non renseigné n’est inventé (options désactivées).
- [x] Les séparateurs de milliers sont correctement affichés.
- [x] Le total du panier est recalculé dynamiquement sans rechargement.
- [x] Le prix enregistré dans la commande est scellé au moment de la validation.

