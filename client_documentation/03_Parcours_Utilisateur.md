# 03. Schéma de Navigation & Parcours Utilisateur

Ce document explique le flux (flow) complet d'un utilisateur au sein de l'application.

## A. Schéma Global (Flowchart)

```mermaid
graph TD
    Splash[Splash Screen] -->|Vérification Auth| AuthCheck{Utilisateur Connecté ?}
    
    %% Non connecté
    AuthCheck -->|Non| Onboarding[Écran Onboarding]
    Onboarding --> Login[Écran de Connexion]
    Onboarding --> SignUp[Écran d'Inscription]
    Login --> AuthCheck
    SignUp --> ProfilSetup[Configuration du statut : Enceinte / Maman]
    ProfilSetup --> Home
    
    %% Connecté
    AuthCheck -->|Oui| Home[Home : Barre de Navigation Principale]
    
    %% Barre de navigation
    Home --> Tab1[1. Dashboard (Tableau de Bord)]
    Home --> Tab2[2. Timeline (Flux Souvenirs)]
    Home --> Tab3[3. Nouvelle Capsule (Bouton central+)]
    Home --> Tab4[4. Santé (Vaccins)]
    Home --> Tab5[5. Profil]

    %% Dashboard interactif
    Tab1 -->|Clic 'Reels'| Reels[Reels Éducatifs (Vidéos Verticales)]
    Tab1 -->|Clic 'Livre Mémoires'| MemBook[Livre de Mémoires]
    Tab1 -->|Clic 'Nouvelle Capsule'| Tab3
    Tab1 -->|Clic 'Bannière'| Sub[Plans d'Abonnement]
    
    %% Actions Modales et Sous-écrans
    Tab3 --> NewPhoto[Prise Photo / Voix / Texte] --> SaveCapsule[Sauvegarde] --> Tab2
    Tab4 --> VacDetail[Détail d'un vaccin]
    Tab5 --> AddChild[Ajouter un enfant]
    Tab5 --> EditProfile[Modifier informations persos]
```

## B. Détail des Parcours Stratégiques (User Flows)

### 1. Le parcours "Création de Souvenir" (Le plus fréquent)
L'utilisatrice veut immortaliser un moment spontané.
1. Elle ouvre l'application (arrive sur le `Dashboard`).
2. Elle appuie sur l'icône centrale `+` de la barre de navigation.
3. Elle choisit une photo / prend une vidéo.
4. Elle reste appuyée pour enregistrer un message vocal rapide.
5. Elle sélectionne une émotion (ex: 😍) et valide.
6. La "Capsule" est disponible sur sa `Timeline` immédiatement.

### 2. Le parcours "Information & Détente" (Engagement)
L'utilisatrice a 5 minutes devant elle et cherche des conseils.
1. Depuis le `Dashboard`, elle clique sur la carte *Reels Éducatifs* dans la section *Accès Rapide*.
2. Le lecteur vidéo s'ouvre en plein écran (fond noir immersif).
3. Elle swipe (glisse vers le haut) pour passer de vidéo en vidéo.
4. Si une vidéo l'intéresse, elle tape au centre pour la mettre en pause, ou sur le cœur pour l'ajouter à ses favoris.
5. Elle clique sur "Retour" pour revenir au `Dashboard`.

### 3. Le parcours "Suivi Médical" (Utilitée)
L'utilisatrice doit vérifier le carnet de santé chez le pédiatre.
1. Elle clique sur l'onglet `Vaccins` (icône seringue) dans le menu du bas.
2. Elle sélectionne l'un de ses enfants.
3. Elle voit la liste chronologique. Les vaccins verts sont "Faits", les rouges sont "En retard" ou "À faire".
4. Elle coche le vaccin qui vient d'être administré.

### 4. Le parcours "Monétisation" (Business)
1. L'utilisatrice est sur l'offre "Gratuite" (10 capsules max par mois, etc.).
2. Depuis le `Dashboard`, une très belle bannière animée l'invite vers le Premium.
3. Elle clique et atterrit sur le tableau comparatif (`SubscriptionPlansScreen`).
4. Elle voit l'avantage de "Capsules illimitées et Livres auto-générés" au prix adapté (ex: 500 DZD).
