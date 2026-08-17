# 📋 Guide de Vérification Manuelle (Checklist) — Localisation & Améliorations

Ce document récapitule les étapes pas à pas pour tester et valider manuellement l'affichage dynamique des trois langues (**Arabe / Français / Anglais**) sur tous les écrans modifiés.

> [!NOTE]
> Pour changer la langue de l'application lors des tests, veuillez modifier la langue système de votre appareil ou émulateur (Paramètres de l'appareil → Système → Langues).

---

## 📅 1. Timeline & Jalons (Bébé)

### 🩺 LM2-127 & LM2-130 — Détails du Jalon & Conseils
* **Écran :** Timeline → Cliquer sur un jalon de développement (ex. "1er mois").
* **Actions à tester :**
  1. Passer l'appareil en **Arabe** ➡️ Vérifier que la description du jalon et les conseils pratiques de santé s'affichent correctement en arabe.
  2. Passer l'appareil en **Anglais** ➡️ Vérifier que les conseils et descriptions s'affichent en anglais.
  3. Passer l'appareil en **Français** ➡️ Vérifier l'affichage en français.

### ⚙️ LM2-128 — Paramètres de la Timeline
* **Écran :** Paramètres rapides de la Timeline.
* **Actions à tester :**
  * Vérifier que tous les libellés de configuration de visibilité et d'affichage sont traduits dynamiquement selon la langue active.

### ⏳ LM2-129 — Indicateurs de Chargement Shimmer
* **Écran :** Cartes images réseau de la Timeline.
* **Actions à tester :**
  * Lors d'une connexion lente, vérifier que le Shimmer s'adapte correctement au thème actif (Clair / Sombre) sans distorsion visuelle.

### 🔔 LM2-131 — Rappels & Bottom Sheet
* **Écran :** Détails du Jalon → Cliquer sur "Planifier un rappel".
* **Actions à tester :**
  * Vérifier que la feuille de presets de temps affiche :
    * **AR :** "غداً" / "في غضون 3 أيام" / "في غضون أسبوع" / "في يوم الجالون".
    * **EN :** "Tomorrow" / "In 3 days" / "In 1 week" / "On milestone day".
    * **FR :** "Demain" / "Dans 3 jours" / "Dans 1 semaine" / "Le jour du jalon".
  * Vérifier que la boîte de sélection d'heure et de date respecte le format local de la langue système.
  * Valider que les SnackBars de confirmation de rappel programmé sont traduits.

---

## 💉 2. Vaccins & Reels

### 🏷️ LM2-132 — Capsules Vaccins
* **Écran :** Carnet de vaccination → Fiche ou détails d'un vaccin.
* **Actions à tester :**
  * Vérifier que les émotions et réactions associées à la capsule de vaccin utilisent la fonction `getLabel(locale)` et affichent des termes traduits (ex. "Souriant ➡️ مبتسم / Smiling").
  * Vérifier que le guide d'instruction en bas de la fiche vaccin est traduit dans la langue système active.

### 🎥 LM2-133 — Reels par Vaccin
* **Écran :** Flux Reels filtré par vaccin.
* **Actions à tester :**
  * Vérifier que le badge de filtrage de l'âge cible ou du vaccin affiche :
    * **AR :** "تصفية: ..."
    * **EN :** "Filtered: ..."
    * **FR :** "Filtré : ..."
  * Vérifier que les intervalles d'âge (ex. "Naissance" / "mois" / "ans") dans les filtres du flux Reels sont traduits dynamiquement.

---

## 📖 3. Livre de Mémoires & Albums

### 📐 LM2-134 — Album Prédéfini
* **Écran :** Livre de Mémoires → Sélectionner "Album prédéfini".
* **Actions à tester :**
  * Vérifier que les 3 modèles prédéfinis (Naissance, 1ère année, Aqiqa) et leurs 14 événements sont entièrement traduits en arabe, anglais et français.
  * Vérifier le bouton de choix du modèle :
    * **AR :** "إنشاء" / **EN :** "Create" / **FR :** "Créer".
  * Vérifier la feuille d'ajout de capsule :
    * **AR :** "جديدة" (Nouvelle) / "موجودة" (Existante).
    * **EN :** "New" / "Existing".
    * **FR :** "Nouvelle" / "Existante".

### 🎨 LM2-135 — Album Standard (Libre)
* **Écran :** Livre de Mémoires → Sélectionner "Album libre".
* **Actions à tester :**
  * Vérifier l'affichage du bandeau d'état "Brouillon" :
    * **AR :** "تم ملء X/Y صفحة · مسودة".
    * **EN :** "X/Y pages filled · Draft".
    * **FR :** "X/Y pages remplies · Brouillon".
  * Cliquer sur le titre pour renommer l'album : Vérifier que le dialogue (Titre, boutons Annuler et Enregistrer) est traduit dynamiquement.
  * Cliquer sur une page vide pour ajouter une capsule : Vérifier que la feuille d'options affiche "Choisir une capsule existante" et "Créer une nouvelle capsule" dans la langue de l'appareil.

### 🖨️ LM2-137 — Bridge Album → Impression
* **Écran :** Ouvrir un album contenant au moins une photo → Cliquer sur "Commander l'impression".
* **Actions à tester :**
  * Vérifier le bouton d'action sous l'album : **AR :** "طلب الطباعة" / **EN :** "Order printing" / **FR :** "Commander l'impression".
  * Vérifier le message d'attente lors du rendu PDF : **AR :** "جاري تجهيز ألبومك..." / **EN :** "Preparing your album..." / **FR :** "Préparation de votre album...".
  * Dans le formulaire de livraison final :
    * Vérifier la traduction des étiquettes de saisie (Nom complet, Téléphone, Wilaya, Adresse complète).
    * Vérifier la traduction du bandeau VIP gratuit vs payant.
    * Valider les messages d'erreur de validation (ex. champ requis, numéro de téléphone invalide).
  * Sur l'écran final de succès : vérifier que le message de confirmation et le délai de livraison (7-14 jours) sont traduits.

---

## 🛒 4. Marketplace & Commandes

### 🛍️ LM2-138 — Catalogue Produits
* **Écran :** Dashboard → Section "Boutique Partenaires" (Marketplace).
* **Actions à tester :**
  * Vérifier le sous-titre de l'en-tête : **AR :** "منتجات شركائنا الموثوقين" / **EN :** "Products from our partners" / **FR :** "Produits de nos partenaires".
  * Vérifier les boutons d'accès rapide aux commandes et au panier (infobulles).
  * Vérifier les chips de catégories (Tous / رعاية الأطفال / التغذية / النظافة والجمال / الألعاب والتعليم / مساحة الأم) وفقاً للغة النظام.

### 📦 LM2-139 — Commande & Panier
* **Écran :** Marketplace → Fiche Produit → Ajouter au panier → Ouvrir le Panier → Commander.
* **Actions à tester :**
  * **Fiche produit :** Vérifier que la section "Points clés" et le badge "Partenaire" sont traduits.
  * **Ajout au panier :** Vérifier que la feuille de sélection des quantités, le message d'erreur de quantité maximale et le SnackBar de confirmation sont traduits.
  * **Panier :** Vérifier les textes "Mon Panier", "Vider" (Clear / تفريغ) et "Passer la commande".
  * **Formulaire d'adresse :** Vérifier que les champs et alertes (Délai, Paiement à la livraison) s'adaptent dynamiquement.
  * **Historique des commandes (Mes Commandes) :**
    * Ouvrir l'historique et valider les 5 états de commande (En attente / مؤكدة / تم الشحن / تم التسليم / ملغاة).
    * Vérifier que the date et l'heure s'affichent au format localisé correct.
