
1. Convention de priorité
P0 – Bloquant : empêche l’utilisation ou entraîne une perte de données.
P1 – Critique : dysfonctionnement important sur une fonctionnalité principale.
P2 – Important : amélioration nécessaire de l’expérience utilisateur.
P3 – Mineur : correction de texte, d’affichage ou optimisation secondaire.

EPIC 1 – Onboarding, consentement et profil utilisateur
LM-ONB-001 – Corriger le texte d’acceptation de la loi 18-07
Type : Correction de contenu
Priorité : P2
État actuel
Le texte affiché est :
« J’accepte la loi 18-07 »
Modification demandée
Remplacer ce texte par :
« J’accepte les termes de la loi n° 18-07. »

LM-ONB-002 – Corriger la zone tactile de la case d’acceptation
Type : Bug UX/UI
Priorité : P1
Problème constaté
La case d’acceptation relative à la loi 18-07 est difficile à cocher. La zone tactile semble trop petite ou ne réagit pas immédiatement.
Comportement attendu
L’utilisateur doit pouvoir cocher ou décocher la case facilement en appuyant :
directement sur la case ;
sur son libellé ;
ou sur toute la zone contenant la case et son libellé.
Critères d’acceptation
Un seul appui permet de cocher ou décocher la case.
La zone tactile couvre la case et son libellé.
La modification visuelle de l’état est immédiate.
Aucun double-clic ou appui prolongé n’est nécessaire.
Le bouton de continuation est activé uniquement après acceptation.
Le comportement est identique sur Android et iOS.
Le consentement est correctement enregistré dans la base de données avec, si prévu par l’architecture : 
l’identifiant utilisateur ;
la version du consentement ;
la date et l’heure ;
la langue utilisée.

LM-ONB-003 – Ajouter la sélection de langue après le consentement
Type : Amélioration fonctionnelle
Priorité : P1
Modification demandée
Afficher l’écran de sélection de la langue immédiatement après la validation du consentement relatif à la loi 18-07.
Ordre du parcours attendu
Affichage de l’écran relatif à la loi 18-07.
Acceptation par l’utilisateur.
Validation du consentement.
Affichage immédiat de l’écran de sélection de langue.
Enregistrement de la langue choisie.
Poursuite de l’onboarding dans la langue sélectionnée.
Langues à afficher
Français
Arabe
Anglais
Critères d’acceptation
L’écran de langue s’ouvre après validation du consentement.
La langue sélectionnée est immédiatement appliquée.
La préférence est conservée après fermeture et réouverture de l’application.
L’utilisateur peut modifier ultérieurement la langue depuis les paramètres.
L’interface arabe respecte l’affichage de droite à gauche.
Aucun écran intermédiaire non prévu ne s’affiche.

LM-ONB-004 – Générer automatiquement un profil « MAM »
Type : Amélioration fonctionnelle
Priorité : P1
Modification demandée
À la fin de l’onboarding, générer automatiquement un profil principal utilisateur de type « MAM ».
Comportement attendu
Le profil « MAM » est créé automatiquement.
Il devient le profil principal de l’utilisatrice.
Il est lié aux souvenirs, aux capsules, aux enfants et aux albums.
Il peut être modifié à tout moment.
Éléments modifiables
Selon les champs déjà disponibles dans l’application :
nom ou prénom ;
photo de profil ;
date de naissance ;
statut ;
informations personnelles non sensibles ;
préférences.
Critères d’acceptation
Un seul profil « MAM » principal est généré automatiquement.
La création du profil ne génère aucun doublon.
Le profil reste accessible après reconnexion.
La modification du profil n’altère pas les souvenirs ou les enfants déjà associés.
Les données existantes sont conservées si l’utilisateur modifie son statut.

LM-ONB-005 – Autoriser l’ajout d’enfants quel que soit le statut
Type : Amélioration fonctionnelle
Priorité : P1
Problème constaté
L’ajout d’un enfant semble dépendre du statut sélectionné par l’utilisatrice et de son forfait d’abonnement
Modification demandée
Permettre l’ajout et le suivi d’un ou plusieurs enfants quel que soit le statut du profil :
Espoir ;
Enceinte ;
Maman.
Critères d’acceptation
L’action « Ajouter un enfant » reste accessible pour les trois statuts.
Le changement de statut ne supprime ni ne masque les enfants existants.
Plusieurs enfants peuvent être associés au même profil « MAM ».
Chaque souvenir ou capsule peut être associé : 
au profil « MAM » ;
à un enfant ;
ou, si la conception le permet, à plusieurs profils.
Les données d’un enfant sont correctement isolées de celles des autres enfants.
La suppression d’un enfant demande une confirmation explicite.

EPIC 2 – Mes souvenirs et navigation
LM-MEM-001 – Corriger la destination du bouton « Mes souvenirs »
Type : Bug de navigation
Priorité : P1
État actuel
Un clic sur « Mes souvenirs » redirige vers l’écran de création d’une nouvelle capsule.
Comportement attendu
Le bouton « Mes souvenirs » doit ouvrir la liste de tous les souvenirs déjà créés pour :
le profil « MAM » ;
chacun de ses enfants.
Critères d’acceptation
Le clic ouvre l’écran de consultation des souvenirs.
Aucun formulaire de création ne s’ouvre automatiquement.
Les souvenirs sont filtrables par profil : 
Tous ;
MAM ;
Enfant 1 ;
Enfant 2 ;
etc.
Un bouton séparé permet de créer une nouvelle capsule.
Si aucun souvenir n’existe, un écran vide explicite est affiché avec une action : 
« Créer mon premier souvenir ».
Le retour arrière ramène l’utilisateur à l’écran précédent.

LM-MEM-002 – Corriger le bouton « Voir tout » de Mes souvenirs
Type : Bug fonctionnel
Priorité : P1
État actuel
Un clic sur « Voir tout » dans la rubrique « Mes souvenirs » n’affiche aucun contenu.
Comportement attendu
Le bouton doit ouvrir l’écran contenant l’ensemble des souvenirs accessibles à l’utilisateur.
Critères d’acceptation
Le bouton « Voir tout » déclenche une navigation valide.
Les souvenirs existants sont chargés et affichés.
Un indicateur de chargement apparaît pendant la récupération des données.
Si la liste est vide, un état vide explicite est affiché.
Une erreur du serveur doit produire un message compréhensible et un bouton « Réessayer ».
Aucun écran blanc ne doit apparaître.
La pagination ou le chargement progressif doit être prévu si le volume de souvenirs devient important.

LM-NAV-001 – Stabiliser la barre de navigation inférieure
Type : Bug UX/UI
Priorité : P1
État actuel
La barre de navigation inférieure disparaît dans certaines situations, notamment :
lors du changement de mode ou de profil ;
lors de l’ouverture des notifications.
Comportement attendu
La barre de navigation inférieure doit rester affichée sur tous les écrans principaux où elle est prévue.
Critères d’acceptation
La barre reste visible après un changement de mode ou de profil.
Elle reste visible dans la liste des notifications.
L’onglet actif est correctement mis en évidence.
Les changements de profil ne réinitialisent pas la navigation de manière inattendue.
La barre ne recouvre ni les boutons ni le contenu.
Elle respecte les zones sécurisées des appareils.
Les écrans secondaires, formulaires plein écran ou fenêtres modales peuvent la masquer uniquement si ce comportement est défini dans le design.

EPIC 3 – Accueil et accès rapide
LM-HOME-001 – Renommer « Calendrier complet » sur l’accueil
Type : Correction de contenu
Priorité : P3
Modification demandée
Dans la barre ou section d’accueil, remplacer :
« Calendrier complet »
par :
« Calendrier vaccinal complet »
Critères d’acceptation
Le nouveau libellé s’affiche sans troncature.
Le lien continue à rediriger vers le calendrier vaccinal.
Les traductions sont mises à jour dans les fichiers de localisation.
L’ancien libellé n’apparaît plus sur cet écran.

LM-HOME-002 – Réorganiser les raccourcis d’Accès rapide
Type : Amélioration UX/UI
Priorité : P2
Nouvelle disposition demandée
Réorganiser les raccourcis comme suit :
Reels éducatifs prend la position actuelle de Mes souvenirs, à gauche.
Santé Enfant se déplace vers la droite.
Mes souvenirs descend en bas et prend la position actuelle de Reels éducatifs.
Critères d’acceptation
Les trois raccourcis apparaissent aux nouvelles positions.
Les icônes, libellés et destinations restent correctement associés.
La disposition est responsive.
L’ordre reste cohérent en français, anglais et arabe.
Aucun raccourci n’est dupliqué ou supprimé.
Les zones tactiles restent suffisamment grandes.

EPIC 4 – Abonnements et privilèges Luckymam
LM-SUB-001 – Remplacer la mise en avant VIP par Premium
Type : Amélioration commerciale et UX
Priorité : P2
État actuel
Dans la rubrique « Privilèges Luckymam », le passage vers l’offre VIP est proposé en premier.
Modification demandée
Afficher d’abord l’action :
« Passer à Premium »
au lieu de mettre directement en avant l’offre VIP.
Critères d’acceptation
Premium devient l’offre principale mise en avant.
L’offre VIP reste accessible comme formule supérieure.
L’intitulé est cohérent sur tous les écrans : 
« Passer à Premium » ;
ou « Choisir Premium ».
Les redirections ouvrent la bonne formule.
La formule actuelle de l’utilisateur est clairement identifiée.

LM-SUB-002 – Ajouter un tableau comparatif des abonnements
Voir FEUILLE 2

EPIC 5 – Capsules émotionnelles et Timeline
LM-CAP-001 – Afficher toute nouvelle capsule dans la Timeline
Type : Bug fonctionnel
Priorité : P0
Problème constaté
Après l’ajout d’une capsule, celle-ci n’est pas toujours retrouvée dans la Timeline.
Comportement attendu
Toute capsule créée avec succès doit apparaître immédiatement dans la Timeline, au bon emplacement chronologique et sous le bon profil (JALON)
Critères d’acceptation
La capsule est enregistrée en base avant d’afficher le message de succès.
Elle apparaît immédiatement dans la Timeline.
Elle est associée au profil ou à l’enfant sélectionné.
Elle est positionnée selon sa date de création ou sa date de souvenir.
Elle reste visible après fermeture et réouverture de l’application.
Elle reste visible après déconnexion et reconnexion.
En cas d’échec de sauvegarde, l’application affiche une erreur et ne confirme pas faussement la création.
Aucun doublon n’est créé en cas de nouvel appui sur le bouton de validation.

LM-CAP-002 – Ajouter une miniature sur la Timeline
Type : Amélioration UX/UI
Priorité : P2
Modification demandée
Après la création d’une capsule contenant une photo, afficher automatiquement dans la Timeline une icône ou une carte intégrant la miniature de cette photo.
Critères d’acceptation
La miniature est générée automatiquement.
Elle est associée à la bonne capsule.
Son format ne déforme pas la photo originale.
Une image générique est affichée si aucune photo n’est disponible.
L’affichage reste performant grâce à l’utilisation d’une miniature optimisée.
Un clic sur la miniature ouvre le détail de la capsule.
La modification de la photo met à jour la miniature.

LM-CAP-003 – Permettre plusieurs émotions dans une capsule
Type : Amélioration fonctionnelle
Priorité : P2
Modification demandée
Conserver une émotion principale obligatoire et permettre à l’utilisateur d’ajouter une ou plusieurs émotions secondaires.
Règles attendues
Une émotion principale est obligatoire.
Les émotions secondaires sont facultatives.
Une même émotion ne peut pas être ajoutée deux fois.
Le nombre maximal d’émotions secondaires doit être défini par l’équipe produit.
Critères d’acceptation
La capsule ne peut pas être validée sans émotion principale.
L’utilisateur peut ajouter et supprimer des émotions secondaires.
Les émotions sont correctement sauvegardées.
Elles restent visibles après réouverture de la capsule.
La modification d’une capsule permet de modifier les émotions.
Les émotions sont affichées clairement sans surcharger la Timeline.

LM-CAP-004 – Prévisualiser et modifier l’audio avant validation
Type : Amélioration fonctionnelle
Priorité : P1
Modification demandée
Après l’enregistrement d’un audio, permettre à l’utilisateur de :
l’écouter ;
le mettre en pause ;
reprendre la lecture ;
supprimer l’enregistrement ;
recommencer l’enregistrement ;
confirmer l’utilisation de l’audio.
Parcours attendu
Démarrer l’enregistrement.
Arrêter l’enregistrement.
Afficher le lecteur de prévisualisation.
Proposer les actions : 
Écouter ;
Recommencer ;
Supprimer ;
Valider.
Associer l’audio à la capsule uniquement après validation.
Critères d’acceptation
Le fichier peut être lu avant validation.
L’utilisateur peut refaire l’enregistrement.
L’ancien fichier temporaire est supprimé lorsqu’un nouvel audio est enregistré.
L’audio validé reste accessible après réouverture de la capsule.
La durée et le statut de lecture sont visibles.
Les permissions du microphone sont correctement gérées.
Une erreur claire s’affiche si l’enregistrement échoue.
Aucun fichier audio vide ou corrompu ne doit être sauvegardé.

LM-CAP-005 – Fiabiliser les capsules créées depuis la Timeline
Type : Bug critique
Priorité : P0
Problèmes constatés
Les capsules créées à partir de la Timeline rencontrent plusieurs anomalies :
difficulté à enregistrer une capsule ;
difficulté à modifier une capsule ;
perte ou absence d’affichage après validation ;
photo associée non sauvegardée ou non affichée ;
capsule absente du jalon correspondant.
Comportement attendu
Une capsule créée ou modifiée depuis la Timeline doit être :
sauvegardée de manière fiable ;
rattachée au bon jalon ;
rattachée au bon profil ;
visible après actualisation ;
modifiable sans perte de données.
Critères d’acceptation
Le bouton de validation ne peut pas être déclenché plusieurs fois pendant la sauvegarde.
Un état de chargement est affiché pendant l’enregistrement.
Le message de succès apparaît uniquement après confirmation du serveur.
La capsule apparaît au bon jalon.
La photo, l’audio, le texte et les émotions sont conservés.
La modification ne crée pas une deuxième capsule.
La suppression ou le remplacement d’une photo est correctement répercuté.
Une erreur réseau ne provoque aucune perte silencieuse.
Si un brouillon local est prévu, il peut être repris après interruption.
Les journaux techniques permettent d’identifier : 
l’identifiant de la capsule ;
le profil associé ;
le jalon associé ;
l’étape ayant échoué ;
le type de média concerné.
Tests minimaux
Création avec texte uniquement.
Création avec photo.
Création avec audio.
Création avec photo et audio.
Création avec plusieurs émotions.
Modification du texte.
Remplacement de la photo.
Remplacement de l’audio.
Changement de jalon.
Création avec connexion instable.
Fermeture et réouverture de l’application.
Déconnexion et reconnexion.

EPIC 6 – Livre de mémoires et albums prédéfinis
LM-ALB-001 – Revoir le design des albums
Type : Amélioration UX/UI
Priorité : P2
Objectif
Moderniser le design des albums afin de mieux valoriser les souvenirs et les photos.
Recommandations fonctionnelles
Proposer une couverture identifiable.
Afficher un aperçu réaliste de l’album.
Utiliser des marges et des zones de sécurité adaptées à l’impression.
Éviter les éléments trop proches des bords.
Maintenir une identité visuelle cohérente avec Luckymam.
Prévoir une prévisualisation avant commande ou export.
Critères d’acceptation
Chaque modèle possède une miniature de prévisualisation.
Le modèle sélectionné est visuellement identifiable.
La prévisualisation reflète le résultat final.
Les photos ne sont pas déformées.
Le rendu est adapté aux dimensions A5, A4 et A3 lorsque disponibles.
Les textes et photos respectent les zones d’impression.

LM-ALB-002 – Ajouter un album prédéfini avec une seule photo
Type : Nouvelle offre
Priorité : P2
Modification demandée
Créer un modèle d’album ou de produit souvenir conçu pour une seule photo en format portrait.
Critères d’acceptation
L’utilisateur peut sélectionner une seule photo.
Le modèle accepte une photo en orientation portrait.
Un recadrage est proposé.
Une prévisualisation finale est disponible.
Le prix est calculé selon le format sélectionné.
Le produit peut être ajouté à une commande.

LM-ALB-003 – Ajouter le logo Luckymam aux créations
Type : Identité visuelle
Priorité : P2
Modification demandée
Toujours intégrer le logo Luckymam en forme de trèfle à quatre feuilles dans les créations générées.
Règles d’affichage
Le logo doit rester discret.
Il ne doit pas masquer les visages ou les éléments essentiels.
Sa position doit être cohérente.
Il doit respecter une marge minimale par rapport aux bords.
Le fichier source doit être de qualité suffisante pour l’impression.
Critères d’acceptation
Le logo apparaît dans l’aperçu et le fichier final.
Il n’est ni pixelisé ni déformé.
Sa position est cohérente sur toutes les pages ou photos concernées.
Il est visible sans devenir intrusif.
Sa présence est vérifiée pour les exports PDF et les albums numériques.

LM-ALB-004 – Permettre le remplacement d’une photo sélectionnée
Type : Amélioration fonctionnelle
Priorité : P1
Modification demandée
Après avoir choisi une photo pour un album, permettre à l’utilisateur de :
remplacer la photo ;
la recadrer ;
la repositionner ;
ajuster son zoom ;
annuler les modifications.
Critères d’acceptation
L’utilisateur n’est pas obligé de recommencer tout l’album.
Le remplacement conserve les autres pages et photos.
Le rendu actualisé apparaît immédiatement dans la prévisualisation.
La photo originale n’est pas écrasée.
Les modifications sont conservées après passage à l’étape suivante.

LM-ALB-005 – Supprimer la numérotation visible des pages
Type : Correction de design
Priorité : P3
Modification demandée
Supprimer la numérotation des pages dans les albums générés.
Critères d’acceptation
Aucun numéro de page ne figure sur le rendu final.
La numérotation interne peut être conservée techniquement pour gérer l’ordre.
Les anciens modèles et nouveaux modèles sont vérifiés.
Le PDF final ne contient aucun numéro visible.

LM-ALB-006 – Corriger le bug de sélection ou de génération PDF
Type : Bug critique
Priorité : P0
Problème constaté
L’option PDF rencontre un dysfonctionnement lors de sa sélection ou de la génération du document.
Points à vérifier
sélection du format PDF ;
génération du document ;
prévisualisation ;
téléchargement ;
partage ;
ouverture sur Android et iOS ;
présence de toutes les photos ;
ordre des pages ;
qualité d’image ;
intégration du logo ;
gestion des caractères français, arabes et anglais.
Critères d’acceptation
Le bouton PDF répond au premier appui.
Un indicateur de progression est affiché.
Le fichier généré peut être ouvert.
Toutes les pages sont présentes dans le bon ordre.
Les photos ne sont ni absentes ni déformées.
Le fichier peut être téléchargé et partagé.
Les textes arabes sont affichés correctement.
Un message d’erreur exploitable apparaît en cas d’échec.
Aucun fichier vide ou corrompu n’est généré.

LM-ALB-007 – Limiter initialement l’offre à deux albums prédéfinis
Type : Décision produit / simplification du MVP
Priorité : P2
Offres initiales
Au lancement, commencer avec deux modèles prédéfinis :
Album 6 photos
Portrait souvenir 1 photo
Critères d’acceptation
Seuls ces deux modèles sont mis en avant dans l’offre prédéfinie initiale.
Chaque modèle possède : 
un nom ;
une description ;
une miniature ;
le nombre de photos requis ;
les formats disponibles ;
le prix correspondant.
Le système bloque la validation si le nombre de photos requis n’est pas respecté.
L’architecture permet d’ajouter ultérieurement d’autres modèles sans refonte majeure.

EPIC 7 – Album numérique et diaporama
LM-DIG-001 – Créer un album numérique sous forme de diaporama
Type : Nouvelle fonctionnalité
Priorité : P2
Description
Permettre à l’utilisateur de créer un album numérique sous forme de diaporama à partir des photos sélectionnées.
Fonctionnalités attendues
Sélectionner les photos.
Définir l’ordre de défilement.
Réorganiser les photos par glisser-déposer.
Prévisualiser le diaporama.
Ajouter le logo Luckymam au début.
Ajouter le logo Luckymam à la fin.
Ajouter un filigrane discret sur chaque photo.
Générer un fichier partageable.
Partager le résultat sur les réseaux sociaux ou via les applications compatibles.
Règles relatives au logo et au filigrane
Logo discret au début du diaporama.
Logo discret à la fin du diaporama.
Filigrane très discret en bas de chaque photo.
Le filigrane ne doit pas masquer les visages.
Son contraste doit s’adapter à la luminosité de l’image.
Critères d’acceptation
L’utilisateur peut sélectionner plusieurs photos.
Il peut modifier leur ordre.
L’ordre choisi est respecté lors de la génération.
Une prévisualisation est disponible.
Le logo apparaît au début et à la fin.
Le filigrane apparaît sur toutes les photos.
Le diaporama généré peut être lu sans erreur.
Le partage ouvre la feuille de partage native du téléphone.
Si une plateforme impose une durée ou un format spécifique, le fichier est adapté ou un message informatif est affiché.
La génération peut être annulée.
Une erreur de génération ne supprime pas la sélection de l’utilisateur.
Paramètres produit à définir
format de sortie ;
résolution ;
durée d’affichage par photo ;
transitions ;
présence éventuelle de musique ;
durée maximale ;
nombre maximal de photos ;
disponibilité selon l’abonnement.

EPIC 8 – Album libre et nombre de pages
LM-FREE-001 – Ajouter le choix du nombre de pages ou de photos
Type : Amélioration fonctionnelle
Priorité : P1
Choix demandés
Permettre de choisir parmi les quantités suivantes :
1 ;
2 ;
4 ;
6 ;
8 ;
10 ;
12.

Point à clarifier dans l’interface
La grille tarifaire fournie est exprimée en nombre de photos, tandis que la remarque mentionne un nombre de pages.
Pour éviter une erreur de calcul, l’équipe produit doit confirmer si :
une page contient exactement une photo ;
ou si le nombre de pages et le nombre de photos sont deux paramètres distincts.
Proposition pour le MVP
Utiliser « Nombre de photos » comme variable tarifaire principale, sauf confirmation qu’il s’agit réellement d’un nombre de pages.
Critères d’acceptation
Seules les quantités autorisées sont proposées.
Le prix est actualisé selon la quantité et le format.
L’utilisateur voit toujours : 
la quantité ;
le format ;
le prix hors transport.
Les combinaisons sans prix défini sont désactivées.
La sélection est conservée lors du retour à l’étape précédente.
Le panier reprend exactement les options choisies.

EPIC 9 – Tarification et commandes d’albums
LM-ORD-001 – Intégrer la grille tarifaire des albums
Type : Règle métier
Priorité : P1
Devise
Dinar algérien, DA
Règle actuelle
Les tarifs communiqués sont hors frais de transport.
Grille tarifaire à intégrer
Nombre de photos	Format A5	Format A4	Format A3
1 photo	440 DA	690 DA	990 DA
2 photos	830 DA	1 280 DA	Non défini
4 photos	1 210 DA	1 860 DA	Non défini
6 photos	1 980 DA	3 030 DA	Non défini
8 photos	2 750 DA	4 200 DA	Non défini
10 photos	3 520 DA	5 370 DA	Non défini
12 photos	4 290 DA	6 540 DA	Non défini
Règle de calcul
Sous-total album = tarif correspondant au format et au nombre de photos
Total commande = sous-total album + frais de transport
Règles de gestion
Ne pas calculer automatiquement un prix pour une combinaison non renseignée.
Les options A3 de 2 à 12 photos doivent être désactivées jusqu’à validation de leurs tarifs.
Afficher clairement la mention : 
« Prix hors frais de transport ».
Les frais de transport doivent apparaître comme une ligne séparée.
Le montant total doit être recalculé lorsque l’utilisateur modifie : 
le format ;
le nombre de photos ;
l’adresse ou la zone de livraison ;
la quantité d’albums.
Les prix doivent être administrables sans publier une nouvelle version de l’application.
Informations à afficher dans le panier
nom du produit ;
type d’album ;
nombre de photos ;
format ;
quantité commandée ;
prix unitaire ;
sous-total ;
frais de transport ;
total ;
adresse de livraison ;
délai estimatif, si disponible.
Critères d’acceptation
Un album A5 avec 6 photos affiche 1 980 DA hors transport.
Un album A4 avec 10 photos affiche 5 370 DA hors transport.
Un portrait A3 avec 1 photo affiche 990 DA hors transport.
Aucun prix A3 non renseigné n’est inventé.
Les séparateurs de milliers sont correctement affichés.
Le prix du panier correspond à la combinaison choisie.
Le total est recalculé sans rechargement complet.
Le prix enregistré dans la commande correspond au prix affiché au moment de la validation.
Une modification ultérieure de la grille ne modifie pas le montant des anciennes commandes.

10. Exigences transversales
LM-CROSS-001 – États de chargement, succès, erreur et liste vide
Priorité : P1
Chaque écran récupérant ou sauvegardant des données doit gérer quatre états :
chargement ;
succès ;
absence de contenu ;
erreur.
Critères d’acceptation
Aucun écran blanc n’est affiché.
Chaque erreur propose une action compréhensible.
Les boutons sont temporairement désactivés pendant une sauvegarde.
Les messages techniques bruts ne sont pas affichés à l’utilisateur.
Les actions longues comportent un indicateur de progression.

LM-CROSS-002 – Traductions et cohérence terminologique
Priorité : P2
Termes à uniformiser
Mes souvenirs
Voir tout
Calendrier vaccinal complet
Passer à Premium
VIP Annuel
Capsule émotionnelle
Timeline
Livre de mémoires
Album numérique
Prix hors frais de transport
Critères d’acceptation
Aucun texte n’est directement codé dans les composants.
Tous les libellés utilisent les fichiers de traduction.
Les écrans sont vérifiés en français, arabe et anglais.
L’arabe est affiché de droite à gauche.
Les textes longs ne sont pas tronqués sans solution de consultation.

LM-CROSS-003 – Traçabilité des erreurs
Priorité : P1
Événements à journaliser
échec de création d’une capsule ;
échec de modification ;
échec d’envoi d’une photo ;
échec d’envoi d’un audio ;
échec de génération PDF ;
échec de génération du diaporama ;
erreur de chargement des souvenirs ;
erreur de paiement ou d’abonnement ;
erreur de calcul ou d’affichage du prix.
Données utiles
identifiant anonymisé de l’utilisateur ;
identifiant du profil ;
identifiant de l’enfant, si concerné ;
identifiant de la capsule ou de l’album ;
date et heure ;
version de l’application ;
système d’exploitation ;
étape du parcours ;
code d’erreur.
Les journaux ne doivent pas enregistrer directement les photos, les audios ou les données personnelles sensibles.

11. Ordre de développement recommandé
Sprint 1 – Corrections bloquantes
LM-CAP-001 – Affichage des capsules dans la Timeline.
LM-CAP-005 – Sauvegarde et modification depuis la Timeline.
LM-ALB-006 – Correction de la génération PDF.
LM-MEM-001 – Destination de Mes souvenirs.
LM-MEM-002 – Bouton Voir tout.
LM-ONB-002 – Case d’acceptation.
LM-NAV-001 – Barre de navigation inférieure.
Sprint 2 – Parcours utilisateur principal
LM-ONB-003 – Sélection de langue.
LM-ONB-004 – Profil MAM par défaut.
LM-ONB-005 – Ajout d’enfants pour tous les statuts.
LM-CAP-004 – Prévisualisation audio.
LM-ALB-004 – Remplacement des photos.
LM-FREE-001 – Choix du nombre de photos ou pages.
LM-ORD-001 – Grille tarifaire.
Sprint 3 – Améliorations UX et offre commerciale
LM-SUB-001 – Mise en avant de Premium.
LM-SUB-002 – Comparatif des abonnements.
LM-CAP-002 – Miniatures dans la Timeline.
LM-CAP-003 – Émotions secondaires.
LM-HOME-003 – Réorganisation d’Accès rapide.
LM-ALB-001 à LM-ALB-007 – Refonte de l’offre albums.
LM-DIG-001 – Album numérique avec diaporama.
Sprint 4 – Finitions
Corrections des libellés.
Vérification des traductions.
Tests RTL en arabe.
Optimisation des performances.
Tests de non-régression.
Vérification Android et iOS.
Tests sur petits écrans et tablettes.

12. Définition globale de « Terminé »
Un ticket ne doit être considéré comme terminé que lorsque :
la correction est développée ;
les critères d’acceptation sont validés ;
les tests unitaires nécessaires sont réalisés ;
les tests d’intégration sont réalisés ;
le comportement est vérifié sur Android et iOS ;
les traductions sont ajoutées ;
l’affichage arabe de droite à gauche est vérifié ;
aucune régression n’est constatée ;
les événements d’erreur nécessaires sont journalisés ;
la fonctionnalité est validée sur l’environnement de recette.

Points à arbitrer avant développement
Les décisions suivantes restent nécessaires pour éviter que le développeur fasse des hypothèses :
Définir les prix et limites des offres Gratuite, Premium et VIP Annuel.
Confirmer si la tarification des albums repose sur le nombre de photos ou de pages.
Fournir les tarifs A3 manquants pour 2, 4, 6, 8, 10 et 12 photos.
Définir les règles de calcul des frais de transport.
Fournir le logo Luckymam dans un format adapté à l’impression et au numérique.
Définir le nombre maximal d’émotions secondaires.
Définir le format, la durée et la résolution de l’album numérique.
Confirmer les écrans sur lesquels la barre de navigation inférieure doit être masquée volontairement.

