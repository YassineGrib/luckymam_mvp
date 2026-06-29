import '../models/phase.dart';

/// Static, professionally-tailored advice for each milestone.
///
/// Each entry contains:
///  - [explanation]  : why this milestone matters (developmental / cultural / medical)
///  - [keyPoints]    : concrete bullets — diseases covered for vaccines, what to
///                     watch for developmental steps, post-care tips, etc.
///  - [photoTips]    : ideas to capture the moment as a memory capsule
///
/// Content is keyed by the real [Milestone.id] values from `milestones_data.dart`.
/// Falls back to category-level defaults when no specific entry exists.
class MilestoneAdvice {
  final String explanation;
  final List<String> keyPoints;
  final List<String> photoTips;

  const MilestoneAdvice({
    required this.explanation,
    this.keyPoints = const [],
    required this.photoTips,
  });
}

/// Per-milestone advice keyed by the exact Milestone.id.
const Map<String, MilestoneAdvice> milestoneAdviceById = {
  // ════════════════════════════════════════════════════════════════════════
  // PRÉ-GESTATION
  // ════════════════════════════════════════════════════════════════════════
  'PRE_DECISION': MilestoneAdvice(
    explanation:
        'Décider d\'avoir un enfant ouvre un nouveau chapitre de vie. Ce moment '
        'd\'intention partagée, souvent discret, est le tout premier souvenir de '
        'l\'histoire de votre futur enfant.',
    keyPoints: [
      'C\'est le bon moment pour commencer l\'acide folique (avant la conception).',
      'Un bilan préconceptionnel chez le médecin est recommandé.',
      'Notez la date : elle marquera le « jour 0 » de votre ligne de vie.',
    ],
    photoTips: [
      'Selfie couple complice, lumière naturelle douce.',
      'Gros plan sur les mains jointes — symbole d\'un projet commun.',
      'Photographiez un objet porteur de sens : étoile, lettre, fleur.',
    ],
  ),

  // ════════════════════════════════════════════════════════════════════════
  // GESTATION
  // ════════════════════════════════════════════════════════════════════════
  'GEST_TEST_POSITIF': MilestoneAdvice(
    explanation:
        'Le test positif est la première preuve tangible de la grossesse. '
        'Surprise, joie, incrédulité — ces émotions brutes méritent d\'être '
        'figées : c\'est le début officiel de l\'aventure.',
    keyPoints: [
      'Confirmez par une prise de sang (bêta-hCG) pour dater la grossesse.',
      'Prenez rendez-vous pour la première consultation prénatale.',
      'Évitez tabac, alcool et automédication dès maintenant.',
    ],
    photoTips: [
      'Le test dans la main, sous une belle lumière naturelle.',
      'Capturez la réaction du futur papa.',
      'Plan serré sur le test, arrière-plan flou et doux.',
    ],
  ),
  'GEST_ANNONCE_CONJOINT': MilestoneAdvice(
    explanation:
        'Annoncer la nouvelle au conjoint est un instant intime et unique. '
        'C\'est le premier secret partagé à deux avant de l\'ouvrir au monde.',
    photoTips: [
      'Filmez la scène en cachette — la réaction spontanée est inestimable.',
      'Mettez en scène un petit cadeau (chaussons, body) pour l\'annonce.',
      'Photographiez l\'étreinte qui suit, pleine d\'émotion.',
    ],
  ),
  'GEST_ECHO_1': MilestoneAdvice(
    explanation:
        'La première échographie de datation révèle le cœur qui bat et précise '
        'le terme. Un jalon médical rassurant et profondément émouvant, '
        'accompagné du premier bilan sanguin.',
    keyPoints: [
      'Permet de dater la grossesse et de calculer la DPA.',
      'Bilan sanguin : groupe sanguin, sérologies, glycémie.',
      'Conservez le compte-rendu et l\'image écho dans le carnet.',
    ],
    photoTips: [
      'Photographiez l\'image écho posée sur un fond uni, bien éclairée.',
      'Selfie couple tenant l\'écho contre le ventre.',
      'Capturez la réaction à la sortie de la clinique.',
    ],
  ),
  'GEST_ANNONCE_FAMILLE': MilestoneAdvice(
    explanation:
        'Partager la nouvelle avec les proches multiplie la joie. Les réactions '
        'des futurs grands-parents et de la famille sont des souvenirs précieux.',
    photoTips: [
      'Filmez les réactions en direct — l\'émotion est imprévisible.',
      'Photo de groupe au moment de l\'annonce.',
      'Mise en scène : gâteau, ballon ou pancarte « bientôt 3 ».',
    ],
  ),
  'GEST_VENTRE_M1': MilestoneAdvice(
    explanation:
        'Le ventre du premier mois est encore discret, mais c\'est le point de '
        'départ visuel de votre suivi mois par mois. Une base de comparaison '
        'précieuse pour la suite.',
    photoTips: [
      'Toujours le même angle (profil) pour comparer chaque mois.',
      'Fond neutre et lumière constante pour une belle série.',
      'Notez le mois sur une ardoise ou un carton dans le cadre.',
    ],
  ),
  'GEST_WHAM': MilestoneAdvice(
    explanation:
        'Les envies de la maman (« WHAM ») font partie du folklore de la '
        'grossesse en Algérie. Ces petites fringales, souvent drôles, '
        'sont de jolies anecdotes à transmettre.',
    photoTips: [
      'Photographiez l\'aliment-envie du moment avec humour.',
      'Capturez maman en pleine dégustation, sourire complice.',
      'Tenez un « carnet des envies » et photographiez ses pages.',
    ],
  ),
  'GEST_VENTRE_M2': MilestoneAdvice(
    explanation:
        'Au deuxième mois, les premiers changements corporels apparaissent. '
        'La série de photos du ventre prend forme.',
    photoTips: [
      'Reprenez exactement le même cadrage que le mois 1.',
      'Lumière latérale pour souligner les premières rondeurs.',
      'Tenue ajustée pour révéler la silhouette.',
    ],
  ),
  'GEST_VENTRE_M3': MilestoneAdvice(
    explanation:
        'Le mois 3 clôt le premier trimestre — la période la plus délicate. '
        'Le ventre s\'arrondit doucement, c\'est souvent le moment où la '
        'grossesse devient « réelle » pour l\'entourage.',
    photoTips: [
      'Profil net sur fond uni, dans la continuité de la série.',
      'Mains posées sur le ventre pour la tendresse.',
      'Comparez côte à côte M1 / M2 / M3.',
    ],
  ),
  'GEST_VISITE_2': MilestoneAdvice(
    explanation:
        'La 2ᵉ visite comprend l\'échographie morphologique et un bilan '
        'dentaire. C\'est un rendez-vous clé pour vérifier le bon développement '
        'de bébé.',
    keyPoints: [
      'Échographie morphologique : vérifie organes et croissance.',
      'Bilan dentaire : la grossesse fragilise les gencives.',
      'Possibilité de découvrir le sexe si vous le souhaitez.',
    ],
    photoTips: [
      'Image écho montrant le profil ou le visage de bébé.',
      'Carnet de suivi à l\'entrée de la clinique.',
    ],
  ),
  'GEST_SEXE_BEBE': MilestoneAdvice(
    explanation:
        'Découvrir le sexe du bébé est un moment de surprise et de joie qui '
        'aide à préparer le prénom et la chambre. Certains préfèrent garder '
        'la surprise jusqu\'à la naissance.',
    photoTips: [
      'Mise en scène « gender reveal » : ballon, fumée ou gâteau coloré.',
      'Capturez la réaction de toute la famille.',
      'Filmez le moment du dévoilement.',
    ],
  ),
  'GEST_MOUVEMENTS': MilestoneAdvice(
    explanation:
        'Sentir bébé bouger pour la première fois crée une connexion corporelle '
        'unique. Ces sensations, d\'abord légères comme des bulles, ne sont '
        'ressenties que par la maman.',
    photoTips: [
      'Main sur le ventre, capturez l\'expression de surprise.',
      'Gros plan sur la main posée sur le ventre.',
    ],
  ),
  'GEST_COUPS_PIED': MilestoneAdvice(
    explanation:
        'Les premiers coups de pied sont une interaction vivante et ludique. '
        'Bébé répond parfois à la voix ou à la musique — un vrai dialogue '
        'commence.',
    photoTips: [
      'Faites poser la main de papa en attente du prochain coup.',
      'Filmez le ventre : on voit parfois la peau bouger.',
    ],
  ),
  'GEST_VENTRE_M4': MilestoneAdvice(
    explanation:
        'Au 4ᵉ mois, la progression est nette et la fierté grandit. Le ventre '
        's\'affirme pleinement.',
    photoTips: [
      'Même cadrage que la série pour suivre l\'évolution.',
      'Lumière naturelle de fenêtre pour un rendu doux.',
    ],
  ),
  'GEST_VISITE_3': MilestoneAdvice(
    explanation:
        'La 3ᵉ visite comprend une NFS (numération sanguine) et une '
        'échographie supplémentaire si nécessaire. Suivi de routine rassurant.',
    keyPoints: [
      'NFS : dépistage d\'une éventuelle anémie.',
      'Surveillance du poids et de la tension.',
    ],
    photoTips: [
      'Carnet de santé ouvert sur la page du jour.',
    ],
  ),
  'GEST_VENTRE_M5': MilestoneAdvice(
    explanation:
        'Le mois 5 marque le milieu de grossesse — un repère visuel important. '
        'Bébé bouge de plus en plus.',
    photoTips: [
      'Profil sur fond neutre, dans la continuité de la série.',
      'Tenue élégante ou drap drapé pour un portrait soigné.',
    ],
  ),
  'GEST_VISITE_4': MilestoneAdvice(
    explanation:
        'La 4ᵉ visite suit la croissance de bébé et dépiste le diabète '
        'gestationnel (test O\'Sullivan / HGPO).',
    keyPoints: [
      'Dépistage du diabète gestationnel autour de 24-28 SA.',
      'Suivi de la croissance fœtale.',
    ],
    photoTips: [
      'Photo du ventre à 6 mois pour la série.',
    ],
  ),
  'GEST_VENTRE_M6': MilestoneAdvice(
    explanation:
        'La silhouette s\'arrondit franchement au 6ᵉ mois. Un souvenir tendre '
        'de la grossesse qui s\'épanouit.',
    photoTips: [
      'Lumière latérale pour sculpter le ventre.',
      'Mains formant un cœur sur le ventre.',
    ],
  ),
  'GEST_VISITE_5': MilestoneAdvice(
    explanation:
        'La consultation du 7ᵉ mois lance la préparation à l\'accouchement. '
        'On aborde le projet de naissance et les cours de préparation.',
    keyPoints: [
      'Début des séances de préparation à la naissance.',
      'Discussion du projet de naissance avec l\'équipe.',
    ],
    photoTips: [
      'Photo du ventre — dernière ligne droite.',
    ],
  ),
  'GEST_ECHO_DERNIERE': MilestoneAdvice(
    explanation:
        'Les dernières échographies vérifient la position et estiment le poids '
        'de bébé, qui commence à se placer tête en bas en vue de la naissance.',
    keyPoints: [
      'Vérification de la présentation (tête en bas idéalement).',
      'Estimation du poids et de la quantité de liquide amniotique.',
    ],
    photoTips: [
      'Image écho du visage de bébé — souvent très détaillée à ce stade.',
      'Selfie couple ému devant l\'écran.',
    ],
  ),
  'GEST_VENTRE_M7': MilestoneAdvice(
    explanation:
        'Au 7ᵉ mois, c\'est la dernière ligne droite et la fierté est à son '
        'comble. Le ventre est imposant et magnifique.',
    photoTips: [
      'Profil sur fond uni, série toujours cohérente.',
      'Séance photo grossesse professionnelle envisageable à ce stade.',
    ],
  ),
  'GEST_VISITE_6': MilestoneAdvice(
    explanation:
        'La 6ᵉ visite (8ᵉ mois) comprend un bilan sanguin et la consultation '
        'd\'anesthésie en vue de l\'accouchement.',
    keyPoints: [
      'Consultation pré-anesthésique (péridurale).',
      'Bilan sanguin de fin de grossesse.',
    ],
    photoTips: [
      'Photo du ventre à 8 mois.',
    ],
  ),
  'GEST_VENTRE_M8': MilestoneAdvice(
    explanation:
        'L\'attente devient palpable au 8ᵉ mois. La valise de maternité se '
        'prépare, les souvenirs familiaux s\'accumulent.',
    photoTips: [
      'Photographiez la valise de maternité prête.',
      'Portrait du ventre, le plus rond de la série.',
    ],
  ),
  'GEST_CHAMBRE_BEBE': MilestoneAdvice(
    explanation:
        'Préparer la chambre de bébé est un acte d\'amour concret. C\'est aussi '
        'l\'occasion d\'intégrer des marqueurs culturels et familiaux dans le '
        'cocon qui accueillera l\'enfant.',
    photoTips: [
      'La chambre entièrement arrangée, belle lumière.',
      'Gros plan sur les petits vêtements pliés ou suspendus.',
      'Flat lay des essentiels bébé sur le lit.',
    ],
  ),
  'GEST_VISITE_7': MilestoneAdvice(
    explanation:
        'La 7ᵉ visite (9ᵉ mois) procède aux dernières vérifications avant '
        'l\'accouchement : col, position, monitoring.',
    keyPoints: [
      'Examen du col et monitoring du rythme cardiaque fœtal.',
      'Définition de la voie d\'accouchement.',
    ],
    photoTips: [
      'Photo du ventre à 9 mois — l\'apogée.',
    ],
  ),
  'GEST_VENTRE_M9': MilestoneAdvice(
    explanation:
        'Le ventre du 9ᵉ mois est à son apogée — prête pour la rencontre. '
        'La dernière photo de la série avant l\'arrivée de bébé.',
    photoTips: [
      'Le plus grand ventre de la série : un final mémorable.',
      'Séance en lumière naturelle, tenue fluide.',
    ],
  ),
  'GEST_SORTIE_COUPLE': MilestoneAdvice(
    explanation:
        'La dernière sortie en couple avant la parentalité est un souvenir '
        'tendre. Profitez de ce moment à deux avant le tourbillon.',
    photoTips: [
      'Portrait du couple dans un lieu qui vous est cher.',
      'Capturez la complicité, mains dans la main.',
    ],
  ),
  'GEST_VENTRE_FAMILLE': MilestoneAdvice(
    explanation:
        'La dernière photo de ventre en famille clôt le chapitre de la '
        'grossesse. Réunissez les aînés s\'il y en a.',
    photoTips: [
      'Photo de famille avec les mains de chacun sur le ventre.',
      'Incluez les frères et sœurs s\'il y en a.',
    ],
  ),
  'GEST_PORTRAIT_COUPLE': MilestoneAdvice(
    explanation:
        'Le portrait du couple avec le ventre immortalise la complicité '
        'parentale juste avant la naissance.',
    photoTips: [
      'Lumière dorée de fin de journée pour un rendu chaleureux.',
      'Front contre front, mains sur le ventre.',
    ],
  ),
  'GEST_CONTROLE_FINAL': MilestoneAdvice(
    explanation:
        'Le dernier contrôle médical valide que tout est prêt pour '
        'l\'accouchement en toute sécurité.',
    keyPoints: [
      'Vérification finale du col et du bien-être fœtal.',
      'Signes à surveiller : contractions régulières, perte des eaux.',
    ],
    photoTips: [
      'Selfie devant la maternité, dernière fois avant bébé.',
    ],
  ),
  'GEST_CONTRACTIONS': MilestoneAdvice(
    explanation:
        'Les premières contractions annoncent le début du travail. Moment '
        'déterminant et intense qui mène à la rencontre tant attendue.',
    keyPoints: [
      'Contractions régulières et rapprochées = départ maternité.',
      'Perte des eaux : rendez-vous à la maternité sans tarder.',
      'Gardez votre valise et vos documents prêts.',
    ],
    photoTips: [
      'Photographiez l\'horloge / le départ pour la maternité.',
      'Un dernier cliché du ventre avant la naissance.',
    ],
  ),

  // ════════════════════════════════════════════════════════════════════════
  // POST-PARTUM
  // ════════════════════════════════════════════════════════════════════════
  'PP_PREMIER_CRI': MilestoneAdvice(
    explanation:
        'Le premier cri de bébé est l\'instant le plus intense de la naissance. '
        'Il marque sa première respiration et l\'entrée dans le monde.',
    photoTips: [
      'Le peau à peau : bébé sur la poitrine de maman.',
      'Les mains minuscules dans celles des parents.',
      'Le bracelet d\'identification de la maternité.',
    ],
  ),
  'PP_MISE_AU_SEIN': MilestoneAdvice(
    explanation:
        'La première mise au sein démarre l\'allaitement et renforce le lien. '
        'Le colostrum, premier lait, est riche en anticorps protecteurs.',
    keyPoints: [
      'Le colostrum protège bébé dès les premières heures.',
      'La mise au sein précoce favorise la montée de lait.',
      'En cas de difficulté, demandez une consultante en lactation.',
    ],
    photoTips: [
      'Cadrage doux sur le visage de bébé pendant la tétée.',
      'Le regard de maman vers bébé.',
    ],
  ),
  'PP_BIBERON': MilestoneAdvice(
    explanation:
        'Le premier biberon, qu\'il complète ou remplace l\'allaitement, est '
        'aussi un moment de lien et de nutrition important.',
    keyPoints: [
      'Respectez les doses et la stérilisation du matériel.',
      'Le biberon permet à papa de participer aux repas.',
    ],
    photoTips: [
      'Papa donnant le biberon — un moment de complicité.',
      'Gros plan sur les petites mains autour du biberon.',
    ],
  ),
  'PP_ANNONCE_NAISSANCE': MilestoneAdvice(
    explanation:
        'L\'annonce officielle de la naissance partage la joie avec tous. '
        'Faire-part, appels, messages — le bonheur se diffuse.',
    photoTips: [
      'Composez un faire-part avec prénom, date, poids et taille.',
      'Première photo officielle de bébé emmailloté.',
    ],
  ),
  'PP_VACCIN_NAISSANCE': MilestoneAdvice(
    explanation:
        'À la naissance, bébé reçoit ses premiers vaccins du calendrier '
        'national algérien : le BCG et la première dose contre l\'hépatite B. '
        'Ce sont ses toutes premières protections.',
    keyPoints: [
      'BCG : protège contre les formes graves de la tuberculose.',
      'HBV : prévient la contamination par le virus de l\'hépatite B.',
      'Le BCG laisse une petite cicatrice normale sur le bras.',
      'Consignez la date et le lot dans le carnet de vaccination.',
    ],
    photoTips: [
      'Photographiez le carnet de vaccination avec la première vignette.',
      'Bébé courageux dans les bras de maman après le vaccin.',
    ],
  ),
  'PP_CIRCONCISION': MilestoneAdvice(
    explanation:
        'La circoncision (Khitane) est un rite religieux et traditionnel '
        'important dans la culture algérienne, célébré en famille dans la joie.',
    keyPoints: [
      'Acte réalisé par un professionnel de santé.',
      'Suivez les conseils de soins post-intervention.',
      'Jour de fête : préparez l\'accueil des proches.',
    ],
    photoTips: [
      'Tenue traditionnelle du petit garçon — portrait soigné.',
      'Photo de groupe avec la famille réunie.',
      'Détails de la décoration et des préparatifs.',
    ],
  ),
  'PP_PREMIER_SOURIRE': MilestoneAdvice(
    explanation:
        'Le premier vrai sourire social (vers 1 mois) récompense les nuits '
        'courtes. Bébé reconnaît votre visage et commence à communiquer.',
    keyPoints: [
      'Le sourire social apparaît généralement entre 4 et 6 semaines.',
      'Parlez et souriez à bébé pour stimuler la réciprocité.',
    ],
    photoTips: [
      'Approchez-vous à 30 cm pour déclencher le sourire.',
      'Mode rafale : le sourire est fugace.',
    ],
  ),
  'PP_AKIKA': MilestoneAdvice(
    explanation:
        'L\'Aqiqa est un rite islamique célébré généralement le 7ᵉ jour : '
        'sacrifice, tonte des cheveux, et partage d\'un repas en famille. '
        'Un moment fort de transmission culturelle.',
    keyPoints: [
      'Traditionnellement au 7ᵉ jour (ou multiples de 7).',
      'Tonte des cheveux et don aux nécessiteux.',
      'Repas familial partagé en signe de gratitude.',
    ],
    photoTips: [
      'La tonte du premier cheveu : moment solennel et tendre.',
      'Les proches rassemblés autour de bébé.',
      'La table du repas familial, dressée avec soin.',
    ],
  ),
  'PP_AID_FITR': MilestoneAdvice(
    explanation:
        'Le premier Aïd el-Fitr de bébé est sa première grande fête '
        'religieuse. Même tout petit, il partage l\'ambiance, les habits neufs '
        'et la chaleur familiale.',
    photoTips: [
      'Bébé en tenue traditionnelle de l\'Aïd.',
      'Photo intergénérationnelle : grands-parents, parents, bébé.',
      'Les gâteaux de l\'Aïd et l\'ambiance festive.',
    ],
  ),
  'PP_VACCIN_2MOIS': MilestoneAdvice(
    explanation:
        'À 2 mois, bébé reçoit l\'un des rendez-vous vaccinaux les plus '
        'complets du calendrier algérien : le vaccin combiné hexavalent, le '
        'vaccin polio oral et le vaccin antipneumococcique.',
    keyPoints: [
      'Hexavalent (DTCaVPI-Hib-HBV) : diphtérie, tétanos, coqueluche, '
          'poliomyélite, Haemophilus influenzae b et hépatite B.',
      'VPOb : vaccin polio par voie orale.',
      'VPC : vaccin antipneumococcique conjugué (otites, méningites).',
      'Une légère fièvre est possible : paracétamol selon avis médical.',
    ],
    photoTips: [
      'Le carnet de vaccination mis à jour.',
      'Bébé réconforté dans les bras après l\'injection.',
    ],
  ),
  'PP_AID_ADHA': MilestoneAdvice(
    explanation:
        'Le premier Aïd al-Adha de bébé est une fête religieuse majeure, '
        'riche en traditions familiales et en partage.',
    photoTips: [
      'Bébé en tenue de fête.',
      'L\'ambiance familiale et le repas de l\'Aïd.',
      'Photo des générations réunies.',
    ],
  ),
  'PP_MUSCLES': MilestoneAdvice(
    explanation:
        'Entre 0 et 3 mois, les muscles de bébé se renforcent : il contrôle '
        'progressivement sa tête et fait ses premiers mouvements volontaires.',
    keyPoints: [
      'Le temps sur le ventre (« tummy time ») renforce le cou.',
      'Vers 2-3 mois, bébé tient mieux sa tête.',
      'Consultez si aucun contrôle de la tête vers 4 mois.',
    ],
    photoTips: [
      'Sur le ventre, tête relevée : posez-vous à sa hauteur.',
      'Capturez l\'effort et la concentration sur son visage.',
    ],
  ),
  'PP_VACCIN_4MOIS': MilestoneAdvice(
    explanation:
        'À 4 mois, bébé reçoit le 2ᵉ rappel du vaccin hexavalent, du polio '
        'oral et de l\'antipneumococcique pour consolider son immunité.',
    keyPoints: [
      'Hexavalent (DTCaVPI-Hib-HBV) : 2ᵉ dose de la primovaccination.',
      'VPOb : 2ᵉ dose du vaccin polio oral.',
      'VPC : 2ᵉ dose antipneumococcique.',
      'Surveillez la fièvre dans les 48 h suivant l\'injection.',
    ],
    photoTips: [
      'Carnet de vaccination à jour.',
      'Bébé apaisé après le vaccin.',
    ],
  ),
  'PP_SONS_SIMPLES': MilestoneAdvice(
    explanation:
        'Vers 2-3 mois, bébé émet ses premiers sons : des voyelles comme '
        '« aah » et « oooh ». C\'est le tout début du langage.',
    keyPoints: [
      'Ces gazouillis sont les prémices de la communication.',
      'Répondez-lui pour encourager les échanges.',
    ],
    photoTips: [
      'Filmez ses gazouillis — le son est le vrai souvenir.',
      'Photo de vous deux face à face en train de « discuter ».',
    ],
  ),
  'PP_BABILLAGE': MilestoneAdvice(
    explanation:
        'Vers 4-6 mois, le babillage se diversifie : « ba-ba », « da-da », '
        'répétition de syllabes. Bébé explore les sons avec délice.',
    keyPoints: [
      'Le babillage canonique annonce les futurs mots.',
      'Nommez les objets pour enrichir son vocabulaire passif.',
    ],
    photoTips: [
      'Capturez la bouche en plein « ba-ba ».',
      'Vidéo courte : ces sons sont éphémères.',
    ],
  ),
  'PP_RETOURNEMENT': MilestoneAdvice(
    explanation:
        'Entre 4 et 6 mois, bébé commence à se retourner et à s\'asseoir avec '
        'soutien. Sa motricité fait un grand bond.',
    keyPoints: [
      'Ne laissez jamais bébé seul en hauteur : il peut se retourner.',
      'Le retournement ventre-dos précède souvent dos-ventre.',
    ],
    photoTips: [
      'Capturez le moment du retournement en rafale.',
      'Bébé assis avec coussins, fier de sa nouvelle vue.',
    ],
  ),
  'PP_POSITION_ASSISE': MilestoneAdvice(
    explanation:
        'S\'asseoir seul sans appui (6-8 mois) est une étape motrice clé. '
        'Bébé découvre le monde sous un nouvel angle, mains libres.',
    keyPoints: [
      'L\'assise stable arrive généralement entre 6 et 8 mois.',
      'Sécurisez l\'environnement : il explore tout à portée.',
    ],
    photoTips: [
      'Posez bébé sur un tapis coloré, à sa hauteur.',
      'Fond épuré pour mettre en valeur la posture.',
    ],
  ),
  'PP_PREMIERES_DENTS': MilestoneAdvice(
    explanation:
        'Les premières dents (6-10 mois) — souvent les incisives centrales '
        'inférieures — s\'accompagnent de bave et parfois d\'irritabilité.',
    keyPoints: [
      'Anneaux de dentition réfrigérés pour soulager les gencives.',
      'Commencez le brossage doux dès la première dent.',
      'Fièvre élevée : consultez, elle n\'est pas toujours due aux dents.',
    ],
    photoTips: [
      'Attendez le grand sourire pour saisir la petite dent.',
      'Gros plan sur la bouche, lumière directe.',
    ],
  ),
  'PP_RAMPE': MilestoneAdvice(
    explanation:
        'Vers 8-10 mois, bébé rampe, passe à quatre pattes et se met debout '
        'avec appui. Son autonomie de déplacement explose.',
    keyPoints: [
      'Sécurisez la maison : prises, escaliers, angles.',
      'Le quatre pattes développe la coordination croisée.',
    ],
    photoTips: [
      'Photographiez-le de profil en position quatre pattes.',
      'Au sol à sa hauteur pour une belle composition.',
    ],
  ),
  'PP_VACCIN_11MOIS': MilestoneAdvice(
    explanation:
        'À 11 mois, bébé reçoit le vaccin ROR, qui le protège contre trois '
        'maladies virales contagieuses : la rougeole, les oreillons et la '
        'rubéole.',
    keyPoints: [
      'ROR : Rougeole – Oreillons – Rubéole.',
      'La rougeole peut être grave : ce vaccin est essentiel.',
      'Une fièvre ou une éruption légère peut survenir 5-12 jours après.',
    ],
    photoTips: [
      'Carnet de vaccination mis à jour.',
      'Bébé courageux après l\'injection.',
    ],
  ),
  'PP_DENTS_LATERALES': MilestoneAdvice(
    explanation:
        'Entre 8 et 12 mois apparaissent les incisives latérales, '
        'supérieures puis inférieures. Le sourire de bébé s\'enrichit.',
    photoTips: [
      'Sourire large pour révéler les nouvelles dents.',
      'Comparez avec la photo des premières dents.',
    ],
  ),
  'PP_PREMIERS_PAS': MilestoneAdvice(
    explanation:
        'Les premiers pas (10-12 mois) symbolisent l\'indépendance. Bébé '
        'oscille, tombe, se relève — le début de toutes ses aventures.',
    keyPoints: [
      'Pieds nus à la maison : meilleur équilibre et appui.',
      'Les chutes font partie de l\'apprentissage.',
    ],
    photoTips: [
      'Accroupie face à lui, encouragez-le à marcher vers vous.',
      'Vidéo : le moment du « lâcher » est imprévisible.',
      'Gros plan sur les petits pieds nus.',
    ],
  ),
  'PP_PREMIERS_MOTS': MilestoneAdvice(
    explanation:
        'Le premier mot significatif — souvent « maman » ou « papa » '
        '(10-12 mois) — marque l\'entrée dans le langage. Une étape '
        'émotionnellement forte.',
    keyPoints: [
      'Bébé comprend bien plus de mots qu\'il n\'en dit.',
      'Lisez-lui des histoires pour enrichir son langage.',
    ],
    photoTips: [
      'Filmez la scène — le son est le vrai souvenir.',
      'Notez le premier mot dans son carnet, photographiez la page.',
    ],
  ),
  'PP_ANNIVERSAIRE_1': MilestoneAdvice(
    explanation:
        'Le premier anniversaire célèbre une année extraordinaire — autant '
        'pour bébé que pour les parents. Un souvenir culturel majeur.',
    photoTips: [
      'Smash cake : laissez bébé attaquer son gâteau à mains nues.',
      'Photo de famille — instaurez un portrait annuel.',
      'Comparez une photo de naissance et une d\'aujourd\'hui.',
    ],
  ),
  'PP_VACCIN_12MOIS': MilestoneAdvice(
    explanation:
        'À 12 mois, bébé reçoit le rappel du vaccin hexavalent, du polio oral '
        'et de l\'antipneumococcique pour renforcer durablement son immunité.',
    keyPoints: [
      'Hexavalent (DTCaVPI-Hib-HBV) : dose de rappel.',
      'VPOb : rappel du vaccin polio oral.',
      'VPC : rappel antipneumococcique.',
      'Surveillez la fièvre dans les 48 h.',
    ],
    photoTips: [
      'Carnet de vaccination à jour pour le premier anniversaire.',
      'Bébé réconforté après le vaccin.',
    ],
  ),

  // ════════════════════════════════════════════════════════════════════════
  // ENFANCE
  // ════════════════════════════════════════════════════════════════════════
  'ENF_MARCHE_SEULE': MilestoneAdvice(
    explanation:
        'Entre 12 et 15 mois, l\'enfant marche seul avec assurance et grimpe '
        'les objets bas. Sa soif d\'exploration est immense.',
    keyPoints: [
      'Sécurisez les meubles : il grimpe partout.',
      'Laissez-le marcher pieds nus pour affiner l\'équilibre.',
    ],
    photoTips: [
      'Capturez-le en pleine marche, en mouvement.',
      'Photo en extérieur : il explore son environnement.',
    ],
  ),
  'ENF_MOLAIRES_1': MilestoneAdvice(
    explanation:
        'Les premières molaires (12-16 mois) permettent de mastiquer des '
        'aliments plus solides. La poussée peut être inconfortable.',
    keyPoints: [
      'Proposez des aliments à texture progressive.',
      'Maintenez le brossage biquotidien.',
    ],
    photoTips: [
      'Sourire large pour montrer la dentition qui s\'étoffe.',
    ],
  ),
  'ENF_VACCIN_18MOIS': MilestoneAdvice(
    explanation:
        'À 18 mois, l\'enfant reçoit la 2ᵉ dose du vaccin ROR, qui consolide '
        'sa protection contre la rougeole, les oreillons et la rubéole.',
    keyPoints: [
      'ROR : 2ᵉ dose — Rougeole, Oreillons, Rubéole.',
      'Cette dose assure une immunité durable.',
      'Réaction possible (fièvre légère) 5-12 jours après.',
    ],
    photoTips: [
      'Carnet de vaccination mis à jour.',
      'Enfant courageux, récompensé par un câlin.',
    ],
  ),
  'ENF_CANINES': MilestoneAdvice(
    explanation:
        'Les canines (16-20 mois) complètent le sourire. Leur percée est '
        'parfois la plus sensible.',
    keyPoints: [
      'Soulagez avec un anneau froid si besoin.',
    ],
    photoTips: [
      'Gros plan sur le sourire qui s\'enrichit.',
    ],
  ),
  'ENF_MOLAIRES_2': MilestoneAdvice(
    explanation:
        'Les deuxièmes molaires (20-30 mois) achèvent la dentition de lait. '
        'L\'enfant peut désormais manger comme un grand.',
    keyPoints: [
      'La dentition de lait compte 20 dents au total.',
      'Première visite chez le dentiste recommandée vers 2-3 ans.',
    ],
    photoTips: [
      'Sourire complet pour immortaliser la dentition de lait.',
    ],
  ),
  'ENF_FATIHA': MilestoneAdvice(
    explanation:
        'Réciter la sourate Al-Fatiha par cœur (2-5 ans) est une grande '
        'fierté familiale et une étape spirituelle marquante.',
    photoTips: [
      'Filmez la récitation — un souvenir précieux à conserver.',
      'Portrait de l\'enfant, mains ouvertes en signe de prière.',
      'Moment partagé avec un parent ou un grand-parent.',
    ],
  ),
  'ENF_JARDIN_ENFANT': MilestoneAdvice(
    explanation:
        'Le premier jour au jardin d\'enfants (2-4 ans) marque les débuts de '
        'la socialisation hors du cercle familial.',
    photoTips: [
      'Photo devant l\'entrée du jardin, cartable sur le dos.',
      'Capturez l\'expression — excitation ou appréhension.',
    ],
  ),
  'ENF_PRESCOLAIRE': MilestoneAdvice(
    explanation:
        'Le premier jour pré-scolaire (vers 5 ans) prépare l\'enfant à '
        'l\'école et développe son autonomie.',
    photoTips: [
      'Portrait du matin, tenue et cartable prêts.',
      'Photo avec la maîtresse ou les nouveaux camarades.',
    ],
  ),
  'ENF_RENTREE_SCOLAIRE': MilestoneAdvice(
    explanation:
        'La rentrée scolaire (6 ans) est un grand pas vers l\'autonomie et la '
        'socialisation. Un rituel familial fort à immortaliser.',
    photoTips: [
      'Photo devant la porte avec le cartable — tradition annuelle.',
      'Gros plan sur les fournitures neuves.',
      'Capturez le départ vers l\'école.',
    ],
  ),
  'ENF_VACCIN_6ANS': MilestoneAdvice(
    explanation:
        'À 6 ans, l\'enfant reçoit un rappel DTCa-VPI avant l\'entrée à '
        'l\'école, qui renforce sa protection contre quatre maladies.',
    keyPoints: [
      'DTCa-VPI : diphtérie, tétanos, coqueluche, poliomyélite.',
      'Rappel important avant la scolarisation.',
      'Vérifiez que le carnet est à jour pour l\'inscription scolaire.',
    ],
    photoTips: [
      'Carnet de santé mis à jour avant la rentrée.',
      'Enfant fier d\'avoir été courageux.',
    ],
  ),
  'ENF_VACCIN_11_13ANS': MilestoneAdvice(
    explanation:
        'Entre 11 et 13 ans, un rappel dT (à teneur réduite) maintient la '
        'protection de l\'adolescent contre le tétanos et la diphtérie.',
    keyPoints: [
      'dT : rappel tétanos et diphtérie à dose réduite.',
      'Étape souvent réalisée en milieu scolaire.',
      'Maintient l\'immunité acquise dans l\'enfance.',
    ],
    photoTips: [
      'Carnet de vaccination à jour.',
    ],
  ),
  'ENF_VACCIN_16_18ANS': MilestoneAdvice(
    explanation:
        'Entre 16 et 18 ans, un nouveau rappel dT prolonge la protection du '
        'jeune adulte contre le tétanos et la diphtérie, avant les rappels '
        'décennaux.',
    keyPoints: [
      'dT : rappel tétanos et diphtérie à dose réduite.',
      'Dernier rappel de l\'adolescence avant le rythme décennal.',
    ],
    photoTips: [
      'Carnet de vaccination à jour à l\'entrée dans l\'âge adulte.',
    ],
  ),

  // ════════════════════════════════════════════════════════════════════════
  // ADULTE
  // ════════════════════════════════════════════════════════════════════════
  'ADULTE_VACCIN_DECENNAL': MilestoneAdvice(
    explanation:
        'À partir de 18 ans, un rappel dT est recommandé tous les 10 ans pour '
        'maintenir une protection à vie contre le tétanos et la diphtérie.',
    keyPoints: [
      'dT : rappel tétanos et diphtérie tous les 10 ans.',
      'Le tétanos est mortel et présent dans l\'environnement (terre, plaies).',
      'Notez la date du prochain rappel décennal.',
    ],
    photoTips: [
      'Carnet de vaccination conservé à jour à l\'âge adulte.',
    ],
  ),
};

/// Category-level fallback advice when no specific entry exists.
final Map<MilestoneCategory, MilestoneAdvice> milestoneCategoryAdvice = {
  MilestoneCategory.emotion: const MilestoneAdvice(
    explanation:
        'Ce jalon émotionnel marque une étape importante dans la relation '
        'entre vous et votre enfant. Chaque moment de connexion renforce '
        'le lien d\'attachement qui durera toute sa vie.',
    photoTips: [
      'Privilégiez la lumière naturelle douce pour capturer les émotions.',
      'Soyez présente dans la photo — votre regard compte autant que celui de bébé.',
      'Préférez le mode rafale pour attraper l\'instant parfait.',
      'Le fond épuré met en valeur les visages et les expressions.',
    ],
  ),
  MilestoneCategory.sante: const MilestoneAdvice(
    explanation:
        'Ce jalon de santé est une étape clé du développement de votre '
        'enfant, suivie par votre pédiatre. Chaque rendez-vous médical '
        'est l\'occasion de vérifier que tout progresse comme prévu.',
    keyPoints: [
      'Consignez les résultats dans le carnet de santé.',
      'Notez vos questions avant chaque consultation.',
    ],
    photoTips: [
      'La salle d\'attente ou l\'entrée de la clinique : un souvenir concret.',
      'Le carnet de santé ouvert sur la page du jour.',
      'Capturez le moment après le rendez-vous : soulagement et fierté.',
    ],
  ),
  MilestoneCategory.culture: const MilestoneAdvice(
    explanation:
        'Ce jalon culturel transmet à votre enfant un héritage précieux. '
        'Ces moments de partage familial forgent son identité et '
        'créent des souvenirs qui l\'accompagneront toute sa vie.',
    photoTips: [
      'Rassemblez les proches — la famille est le cœur de ces moments.',
      'Photographiez les détails traditionnels (habits, décorations, plats).',
      'Un portrait de l\'enfant en tenue traditionnelle est un classique intemporel.',
      'Capturez les générations ensemble : grands-parents, parents, enfant.',
    ],
  ),
  MilestoneCategory.religion: const MilestoneAdvice(
    explanation:
        'Ce jalon religieux s\'inscrit dans la tradition familiale et '
        'spirituelle. Il transmet des valeurs et un cadre de vie à votre '
        'enfant, en le connectant à quelque chose de plus grand que lui.',
    photoTips: [
      'La lumière des bougies ou du soleil couchant crée une atmosphère douce.',
      'Un portrait sobre et solennel reflète l\'importance du moment.',
      'Les mains jointes ou levées en prière : un geste symbolique fort.',
      'Réunissez la famille — la dimension communautaire est essentielle.',
    ],
  ),
};

/// Returns advice for a given milestone ID, with category fallback.
MilestoneAdvice getMilestoneAdvice(
  String milestoneId,
  MilestoneCategory category,
) {
  return milestoneAdviceById[milestoneId] ??
      milestoneCategoryAdvice[category] ??
      const MilestoneAdvice(
        explanation: 'Un moment précieux à immortaliser avec votre famille.',
        photoTips: [
          'Choisissez une belle lumière naturelle.',
          'Soyez spontanée et authentique.',
          'Capturez les regards et les sourires.',
        ],
      );
}
