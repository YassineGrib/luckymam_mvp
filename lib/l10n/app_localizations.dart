import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The app name
  ///
  /// In fr, this message translates to:
  /// **'Luckymam'**
  String get appName;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Capturer chaque moment précieux de votre vie de maman'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get getStarted;

  /// No description provided for @swipeToGetStarted.
  ///
  /// In fr, this message translates to:
  /// **'Glissez pour commencer'**
  String get swipeToGetStarted;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get signUp;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous à votre compte'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre compte pour gérer vos paramètres et explorer les fonctionnalités'**
  String get loginSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte'**
  String get signUpTitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @rememberMe.
  ///
  /// In fr, this message translates to:
  /// **'Se souvenir de moi'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @or.
  ///
  /// In fr, this message translates to:
  /// **'OU'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get signInWithApple;

  /// No description provided for @dontHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte ?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @continueText.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueText;

  /// No description provided for @errorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est requis'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit contenir au moins 8 caractères'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom complet'**
  String get nameHint;

  /// No description provided for @errorNameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom doit contenir au moins 2 caractères'**
  String get errorNameTooShort;

  /// No description provided for @featureNotAvailableMVP.
  ///
  /// In fr, this message translates to:
  /// **'Cette fonctionnalité n\'est pas disponible dans la version MVP'**
  String get featureNotAvailableMVP;

  /// No description provided for @myChildren.
  ///
  /// In fr, this message translates to:
  /// **'Mes Enfants'**
  String get myChildren;

  /// No description provided for @noChildrenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enfant enregistré'**
  String get noChildrenTitle;

  /// No description provided for @noChildrenSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos enfants pour suivre leur croissance, leurs vaccinations et bien plus encore.'**
  String get noChildrenSubtitle;

  /// No description provided for @addFirstChild.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter mon premier enfant'**
  String get addFirstChild;

  /// No description provided for @addChild.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un enfant'**
  String get addChild;

  /// No description provided for @privacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacy;

  /// No description provided for @helpAndSupport.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Support'**
  String get helpAndSupport;

  /// No description provided for @dataProtection.
  ///
  /// In fr, this message translates to:
  /// **'Protection des données'**
  String get dataProtection;

  /// No description provided for @dataProtectionDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vos données personnelles sont stockées de manière sécurisée et ne sont jamais partagées avec des tiers sans votre consentement.'**
  String get dataProtectionDesc;

  /// No description provided for @medicalDataPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Données médicales'**
  String get medicalDataPrivacy;

  /// No description provided for @medicalDataPrivacyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vos informations médicales (cycle menstruel, grossesse, enfants) sont strictement confidentielles et accessibles uniquement par vous.'**
  String get medicalDataPrivacyDesc;

  /// No description provided for @dataDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suppression des données'**
  String get dataDeleteTitle;

  /// No description provided for @dataDeleteDesc.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez demander la suppression complète de votre compte et de toutes vos données à tout moment depuis les paramètres.'**
  String get dataDeleteDesc;

  /// No description provided for @offlineData.
  ///
  /// In fr, this message translates to:
  /// **'Données hors ligne'**
  String get offlineData;

  /// No description provided for @offlineDataDesc.
  ///
  /// In fr, this message translates to:
  /// **'Certaines données peuvent être stockées localement sur votre appareil pour une utilisation hors ligne.'**
  String get offlineDataDesc;

  /// No description provided for @faqTitle.
  ///
  /// In fr, this message translates to:
  /// **'Questions fréquentes'**
  String get faqTitle;

  /// No description provided for @faqAddChild.
  ///
  /// In fr, this message translates to:
  /// **'Comment ajouter un enfant ?'**
  String get faqAddChild;

  /// No description provided for @faqAddChildAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Allez dans votre profil, section \"Mes Enfants\", puis appuyez sur \"Ajouter un enfant\".'**
  String get faqAddChildAnswer;

  /// No description provided for @faqCycle.
  ///
  /// In fr, this message translates to:
  /// **'Comment suivre mon cycle menstruel ?'**
  String get faqCycle;

  /// No description provided for @faqCycleAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Dans la section \"Cycle Menstruel\" de votre profil, appuyez sur \"Enregistrer mes règles\" pour indiquer la date de début.'**
  String get faqCycleAnswer;

  /// No description provided for @faqEditInfo.
  ///
  /// In fr, this message translates to:
  /// **'Comment modifier mes informations ?'**
  String get faqEditInfo;

  /// No description provided for @faqEditInfoAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur l\'icône de crayon à côté de chaque information pour la modifier.'**
  String get faqEditInfoAnswer;

  /// No description provided for @faqDataSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Mes données sont-elles sécurisées ?'**
  String get faqDataSecurity;

  /// No description provided for @faqDataSecurityAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Oui, toutes vos données sont cryptées et stockées de manière sécurisée. Consultez notre politique de confidentialité pour plus de détails.'**
  String get faqDataSecurityAnswer;

  /// No description provided for @contactUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get contactUs;

  /// No description provided for @emailSupport.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailSupport;

  /// No description provided for @emailSupportHint.
  ///
  /// In fr, this message translates to:
  /// **'support@luckymam.site'**
  String get emailSupportHint;

  /// No description provided for @sendEmailPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-nous un email à support@luckymam.site'**
  String get sendEmailPrompt;

  /// No description provided for @liveChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat en direct'**
  String get liveChat;

  /// No description provided for @liveChatUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible bientôt'**
  String get liveChatUnavailable;

  /// No description provided for @featureComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Cette fonctionnalité sera disponible prochainement'**
  String get featureComingSoon;

  /// No description provided for @appVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0'**
  String get appVersion;

  /// No description provided for @law1807Title.
  ///
  /// In fr, this message translates to:
  /// **'Loi 18-07 Protection des Données'**
  String get law1807Title;

  /// No description provided for @law1807Text.
  ///
  /// In fr, this message translates to:
  /// **'Conformément aux dispositions de la Loi n° 18-07 du 10 juin 2018 relative à la protection des personnes physiques dans le traitement des données à caractère personnel, vous acceptez que vos données personnelles soient collectées, traitées et stockées en toute sécurité par Luckymam pour le bon fonctionnement de l\'application. Vous pouvez exercer vos droits d\'accès, de rectification et de suppression à tout moment.'**
  String get law1807Text;

  /// No description provided for @law1807Checkbox.
  ///
  /// In fr, this message translates to:
  /// **'J’accepte la Loi 18/07'**
  String get law1807Checkbox;

  /// No description provided for @law1807Error.
  ///
  /// In fr, this message translates to:
  /// **'L’acceptation de la Loi 18/07 est obligatoire pour continuer.'**
  String get law1807Error;

  /// No description provided for @capsule.
  ///
  /// In fr, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navTimeline.
  ///
  /// In fr, this message translates to:
  /// **'Timeline'**
  String get navTimeline;

  /// No description provided for @navCapsules.
  ///
  /// In fr, this message translates to:
  /// **'Capsules'**
  String get navCapsules;

  /// No description provided for @navHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get navHealth;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @dashboardQuickAccess.
  ///
  /// In fr, this message translates to:
  /// **'Accès Rapide'**
  String get dashboardQuickAccess;

  /// No description provided for @dashboardHealthWellbeing.
  ///
  /// In fr, this message translates to:
  /// **'Mon Bien-être'**
  String get dashboardHealthWellbeing;

  /// No description provided for @dashboardHealthPregnancy.
  ///
  /// In fr, this message translates to:
  /// **'Ma Grossesse'**
  String get dashboardHealthPregnancy;

  /// No description provided for @dashboardHealthDefault.
  ///
  /// In fr, this message translates to:
  /// **'Ma Santé'**
  String get dashboardHealthDefault;

  /// No description provided for @dashboardMyChildren.
  ///
  /// In fr, this message translates to:
  /// **'Mes Enfants'**
  String get dashboardMyChildren;

  /// No description provided for @dashboardMyMemories.
  ///
  /// In fr, this message translates to:
  /// **'Mes Souvenirs'**
  String get dashboardMyMemories;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardSeeAllCapsules.
  ///
  /// In fr, this message translates to:
  /// **'Voir toutes les capsules'**
  String get dashboardSeeAllCapsules;

  /// No description provided for @dashboardPartnerShop.
  ///
  /// In fr, this message translates to:
  /// **'Boutique Partenaires'**
  String get dashboardPartnerShop;

  /// No description provided for @dashboardHopeBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre parcours commence ici 💜'**
  String get dashboardHopeBannerTitle;

  /// No description provided for @dashboardHopeBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez votre cycle et prenez soin de vous.\nVos enfants apparaîtront ici dès l\'arrivée de bébé.'**
  String get dashboardHopeBannerSubtitle;

  /// No description provided for @dashboardPregnantBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre bébé grandit 🩷'**
  String get dashboardPregnantBannerTitle;

  /// No description provided for @dashboardPregnantBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'La section Mes Enfants sera disponible\naprès la naissance de votre bébé.'**
  String get dashboardPregnantBannerSubtitle;

  /// No description provided for @cycleTrackingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du Cycle'**
  String get cycleTrackingTitle;

  /// No description provided for @cycleActivateTracking.
  ///
  /// In fr, this message translates to:
  /// **'Activer le suivi'**
  String get cycleActivateTracking;

  /// No description provided for @cycleEnterPregnancyStart.
  ///
  /// In fr, this message translates to:
  /// **'Renseigner ma date de début'**
  String get cycleEnterPregnancyStart;

  /// No description provided for @cyclePregnancySubtitleWeekDays.
  ///
  /// In fr, this message translates to:
  /// **'Semaine {week} · DPA dans {days} j'**
  String cyclePregnancySubtitleWeekDays(int week, int days);

  /// No description provided for @cycleDayPhase.
  ///
  /// In fr, this message translates to:
  /// **'Jour {day} · {phase}'**
  String cycleDayPhase(int day, String phase);

  /// No description provided for @cycleDayLabel.
  ///
  /// In fr, this message translates to:
  /// **'Jour'**
  String get cycleDayLabel;

  /// No description provided for @cycleWeekLabel.
  ///
  /// In fr, this message translates to:
  /// **'SA'**
  String get cycleWeekLabel;

  /// No description provided for @cycleConfigure.
  ///
  /// In fr, this message translates to:
  /// **'Configurer mon cycle'**
  String get cycleConfigure;

  /// No description provided for @cycleLogPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer mes règles'**
  String get cycleLogPeriod;

  /// No description provided for @cyclePeriodInDays.
  ///
  /// In fr, this message translates to:
  /// **'Règles dans {days} j'**
  String cyclePeriodInDays(int days);

  /// No description provided for @cycleLmpPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez votre date de dernières règles (DDR)\npour suivre votre grossesse semaine par semaine.'**
  String get cycleLmpPrompt;

  /// No description provided for @cycleEnterLmp.
  ///
  /// In fr, this message translates to:
  /// **'Entrer ma DDR'**
  String get cycleEnterLmp;

  /// No description provided for @cycleModifyLmp.
  ///
  /// In fr, this message translates to:
  /// **'Modifier ma DDR'**
  String get cycleModifyLmp;

  /// No description provided for @cycleLmpDatePickerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Date de dernières règles (DDR)'**
  String get cycleLmpDatePickerHelp;

  /// No description provided for @cycleWeekProgress.
  ///
  /// In fr, this message translates to:
  /// **'Semaine {week} / 40'**
  String cycleWeekProgress(int week);

  /// No description provided for @cycleDueDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'DPA : {date}'**
  String cycleDueDateLabel(String date);

  /// No description provided for @cycleDaysUntilDelivery.
  ///
  /// In fr, this message translates to:
  /// **'J−{days} avant l\'accouchement'**
  String cycleDaysUntilDelivery(int days);

  /// No description provided for @cyclePhaseMenstruation.
  ///
  /// In fr, this message translates to:
  /// **'Menstruation'**
  String get cyclePhaseMenstruation;

  /// No description provided for @cyclePhaseFollicular.
  ///
  /// In fr, this message translates to:
  /// **'Folliculaire'**
  String get cyclePhaseFollicular;

  /// No description provided for @cyclePhaseOvulation.
  ///
  /// In fr, this message translates to:
  /// **'Ovulation'**
  String get cyclePhaseOvulation;

  /// No description provided for @cyclePhaseLuteal.
  ///
  /// In fr, this message translates to:
  /// **'Lutéale'**
  String get cyclePhaseLuteal;

  /// No description provided for @cyclePhaseDescMenstruation.
  ///
  /// In fr, this message translates to:
  /// **'Votre cycle commence. Prenez soin de vous.'**
  String get cyclePhaseDescMenstruation;

  /// No description provided for @cyclePhaseDescFollicular.
  ///
  /// In fr, this message translates to:
  /// **'Votre corps se prépare. Vous vous sentez plus énergique.'**
  String get cyclePhaseDescFollicular;

  /// No description provided for @cyclePhaseDescOvulation.
  ///
  /// In fr, this message translates to:
  /// **'Période de fertilité maximale.'**
  String get cyclePhaseDescOvulation;

  /// No description provided for @cyclePhaseDescLuteal.
  ///
  /// In fr, this message translates to:
  /// **'Préparation pour le prochain cycle.'**
  String get cyclePhaseDescLuteal;

  /// No description provided for @cyclePhaseDescDefault.
  ///
  /// In fr, this message translates to:
  /// **'Évolution de votre cycle féminin.'**
  String get cyclePhaseDescDefault;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get greetingEvening;

  /// No description provided for @defaultMotherName.
  ///
  /// In fr, this message translates to:
  /// **'Maman'**
  String get defaultMotherName;

  /// No description provided for @statusWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get statusWelcome;

  /// No description provided for @statusPregnant.
  ///
  /// In fr, this message translates to:
  /// **'Enceinte'**
  String get statusPregnant;

  /// No description provided for @statusHope.
  ///
  /// In fr, this message translates to:
  /// **'En espoir'**
  String get statusHope;

  /// No description provided for @statusMom.
  ///
  /// In fr, this message translates to:
  /// **'Maman'**
  String get statusMom;

  /// No description provided for @dailyTipSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'CONSEIL DU JOUR'**
  String get dailyTipSectionTitle;

  /// No description provided for @dailyTipFooter.
  ///
  /// In fr, this message translates to:
  /// **'— Luckymam Team 💕'**
  String get dailyTipFooter;

  /// No description provided for @upgradePremiumTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passez à Premium'**
  String get upgradePremiumTitle;

  /// No description provided for @upgradePremiumSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Capsules illimitées • Sans pubs'**
  String get upgradePremiumSubtitle;

  /// No description provided for @marketplaceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Marketplace'**
  String get marketplaceTitle;

  /// No description provided for @marketplaceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Produits de nos partenaires'**
  String get marketplaceSubtitle;

  /// No description provided for @marketplaceMyOrders.
  ///
  /// In fr, this message translates to:
  /// **'Mes commandes'**
  String get marketplaceMyOrders;

  /// No description provided for @marketplaceAllCategories.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get marketplaceAllCategories;

  /// No description provided for @marketplaceNoProducts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun produit dans cette catégorie'**
  String get marketplaceNoProducts;

  /// No description provided for @marketplaceMyCart.
  ///
  /// In fr, this message translates to:
  /// **'Mon panier'**
  String get marketplaceMyCart;

  /// No description provided for @myOrdersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes Commandes'**
  String get myOrdersTitle;

  /// No description provided for @myOrdersLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get myOrdersLoadError;

  /// No description provided for @myOrdersEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande pour le moment'**
  String get myOrdersEmptyTitle;

  /// No description provided for @myOrdersEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos commandes marketplace apparaîtront ici'**
  String get myOrdersEmptySubtitle;

  /// No description provided for @orderItemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String orderItemCount(int count);

  /// No description provided for @cartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon Panier'**
  String get cartTitle;

  /// No description provided for @cartClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider'**
  String get cartClear;

  /// No description provided for @labelTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get labelTotal;

  /// No description provided for @cartProceedCheckout.
  ///
  /// In fr, this message translates to:
  /// **'Passer la commande'**
  String get cartProceedCheckout;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre panier est vide'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Parcourez le marketplace pour découvrir\nles produits de nos partenaires'**
  String get cartEmptySubtitle;

  /// No description provided for @productHighlights.
  ///
  /// In fr, this message translates to:
  /// **'Points clés'**
  String get productHighlights;

  /// No description provided for @productPartnerDefault.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire Luckymam'**
  String get productPartnerDefault;

  /// No description provided for @productPartnerBadge.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire'**
  String get productPartnerBadge;

  /// No description provided for @productOrder.
  ///
  /// In fr, this message translates to:
  /// **'Commander'**
  String get productOrder;

  /// No description provided for @productOutOfStock.
  ///
  /// In fr, this message translates to:
  /// **'Rupture de stock'**
  String get productOutOfStock;

  /// No description provided for @productQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get productQuantity;

  /// No description provided for @productMaxQtyReached.
  ///
  /// In fr, this message translates to:
  /// **'Quantité maximale atteinte pour ce produit'**
  String get productMaxQtyReached;

  /// No description provided for @productAddedToCart.
  ///
  /// In fr, this message translates to:
  /// **'{productName} ajouté au panier'**
  String productAddedToCart(String productName);

  /// No description provided for @productViewCart.
  ///
  /// In fr, this message translates to:
  /// **'Voir le panier'**
  String get productViewCart;

  /// No description provided for @productAddToCart.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au panier'**
  String get productAddToCart;

  /// No description provided for @checkoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Finaliser la commande'**
  String get checkoutTitle;

  /// No description provided for @checkoutSubtotal.
  ///
  /// In fr, this message translates to:
  /// **'Sous-total'**
  String get checkoutSubtotal;

  /// No description provided for @checkoutShipping.
  ///
  /// In fr, this message translates to:
  /// **'Livraison'**
  String get checkoutShipping;

  /// No description provided for @checkoutPaymentNote.
  ///
  /// In fr, this message translates to:
  /// **'Paiement à la livraison. Le partenaire vous appellera pour confirmer la commande.'**
  String get checkoutPaymentNote;

  /// No description provided for @checkoutDeliveryInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations de livraison'**
  String get checkoutDeliveryInfo;

  /// No description provided for @checkoutFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom et prénom'**
  String get checkoutFullNameHint;

  /// No description provided for @checkoutPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get checkoutPhone;

  /// No description provided for @checkoutWilaya.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya'**
  String get checkoutWilaya;

  /// No description provided for @checkoutWilayaHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre wilaya'**
  String get checkoutWilayaHint;

  /// No description provided for @checkoutAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complète'**
  String get checkoutAddress;

  /// No description provided for @checkoutAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'Rue, numéro, quartier...'**
  String get checkoutAddressHint;

  /// No description provided for @checkoutPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide (ex : 0550 00 00 00)'**
  String get checkoutPhoneInvalid;

  /// No description provided for @checkoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la commande'**
  String get checkoutConfirm;

  /// No description provided for @checkoutErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la commande'**
  String get checkoutErrorGeneric;

  /// No description provided for @checkoutConfirmedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande confirmée !'**
  String get checkoutConfirmedTitle;

  /// No description provided for @checkoutConfirmedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le partenaire vous contactera par téléphone pour confirmer la livraison et le paiement.'**
  String get checkoutConfirmedSubtitle;

  /// No description provided for @checkoutViewOrders.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes commandes'**
  String get checkoutViewOrders;

  /// No description provided for @checkoutBackHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get checkoutBackHome;

  /// No description provided for @printAlbumSummary.
  ///
  /// In fr, this message translates to:
  /// **'{pageCount} pages · {childName}'**
  String printAlbumSummary(int pageCount, String childName);

  /// No description provided for @printVipFreeNote.
  ///
  /// In fr, this message translates to:
  /// **'Offert avec votre abonnement VIP 🎁'**
  String get printVipFreeNote;

  /// No description provided for @printPricingNote.
  ///
  /// In fr, this message translates to:
  /// **'Nos équipes vous contacteront pour confirmer le tarif d\'impression.'**
  String get printPricingNote;

  /// No description provided for @printOrderSentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commande envoyée !'**
  String get printOrderSentTitle;

  /// No description provided for @printOrderSentMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {albumTitle} » sera imprimé et expédié à l\'adresse indiquée. Nous vous contacterons par téléphone pour confirmer.'**
  String printOrderSentMessage(String albumTitle);

  /// No description provided for @printEstimatedDelay.
  ///
  /// In fr, this message translates to:
  /// **'Délai estimé : 7-14 jours'**
  String get printEstimatedDelay;

  /// No description provided for @printBackToAlbum.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'album'**
  String get printBackToAlbum;

  /// No description provided for @printPreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de l\'album'**
  String get printPreviewTitle;

  /// No description provided for @printPreparingAlbum.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de votre album...'**
  String get printPreparingAlbum;

  /// No description provided for @printOrderPrinting.
  ///
  /// In fr, this message translates to:
  /// **'Commander l\'impression'**
  String get printOrderPrinting;

  /// No description provided for @memoryBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livre de Mémoires'**
  String get memoryBookTitle;

  /// No description provided for @memoryBookSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Albums auto-générés'**
  String get memoryBookSubtitle;

  /// No description provided for @albumPredefinedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Album prédéfini'**
  String get albumPredefinedTitle;

  /// No description provided for @albumPredefinedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Naissance, 1ère année…'**
  String get albumPredefinedSubtitle;

  /// No description provided for @albumFreeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Album libre'**
  String get albumFreeTitle;

  /// No description provided for @albumFreeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pages vierges à remplir'**
  String get albumFreeSubtitle;

  /// No description provided for @albumAddChildFirst.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez d\'abord un enfant pour créer un album'**
  String get albumAddChildFirst;

  /// No description provided for @albumForWhichChild.
  ///
  /// In fr, this message translates to:
  /// **'Pour quel enfant ?'**
  String get albumForWhichChild;

  /// No description provided for @albumDefaultTitleForChild.
  ///
  /// In fr, this message translates to:
  /// **'Album de {childName}'**
  String albumDefaultTitleForChild(String childName);

  /// No description provided for @albumNewFreeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel album libre'**
  String get albumNewFreeTitle;

  /// No description provided for @albumTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre de l\'album'**
  String get albumTitleHint;

  /// No description provided for @albumCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get albumCancel;

  /// No description provided for @albumCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get albumCreate;

  /// No description provided for @albumCreateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la création de l\'album'**
  String get albumCreateError;

  /// No description provided for @memoryBookNoAlbums.
  ///
  /// In fr, this message translates to:
  /// **'Aucun album disponible'**
  String get memoryBookNoAlbums;

  /// No description provided for @memoryBookCaptureMore.
  ///
  /// In fr, this message translates to:
  /// **'Capturez plus de souvenirs\npour débloquer des albums automatiques'**
  String get memoryBookCaptureMore;

  /// No description provided for @albumLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get albumLoadingError;

  /// No description provided for @memoryBookGenerateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de générer les albums'**
  String get memoryBookGenerateError;

  /// No description provided for @albumChooseTemplateFor.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un modèle pour {childName}'**
  String albumChooseTemplateFor(String childName);

  /// No description provided for @albumCreateTemplateConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Créer « {templateTitle} » ?'**
  String albumCreateTemplateConfirm(String templateTitle);

  /// No description provided for @albumCreateTemplateDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cet album sera créé pour {childName} avec {slotCount} évènements à remplir.'**
  String albumCreateTemplateDesc(String childName, int slotCount);

  /// No description provided for @albumTemplateEventCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} évènements'**
  String albumTemplateEventCount(int count);

  /// No description provided for @albumErrorWithMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String albumErrorWithMessage(String error);

  /// No description provided for @albumNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Album introuvable'**
  String get albumNotFound;

  /// No description provided for @albumTemplateNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Modèle introuvable'**
  String get albumTemplateNotFound;

  /// No description provided for @albumEventsFilledProgress.
  ///
  /// In fr, this message translates to:
  /// **'{filled}/{total} évènements remplis'**
  String albumEventsFilledProgress(int filled, int total);

  /// No description provided for @albumMemoryAttached.
  ///
  /// In fr, this message translates to:
  /// **'Souvenir attaché'**
  String get albumMemoryAttached;

  /// No description provided for @albumExistingCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Existante'**
  String get albumExistingCapsule;

  /// No description provided for @albumNewCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle'**
  String get albumNewCapsule;

  /// No description provided for @albumPageCaption.
  ///
  /// In fr, this message translates to:
  /// **'Page {number}'**
  String albumPageCaption(int number);

  /// No description provided for @albumPagesFilledDraft.
  ///
  /// In fr, this message translates to:
  /// **'{filled}/{total} pages remplies · Brouillon'**
  String albumPagesFilledDraft(int filled, int total);

  /// No description provided for @albumRenameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer l\'album'**
  String get albumRenameTitle;

  /// No description provided for @albumSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get albumSave;

  /// No description provided for @albumChooseExistingCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une capsule existante'**
  String get albumChooseExistingCapsule;

  /// No description provided for @albumCreateNewCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Créer une nouvelle capsule'**
  String get albumCreateNewCapsule;

  /// No description provided for @albumPrintNeedMemory.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un souvenir pour pouvoir commander l\'impression.'**
  String get albumPrintNeedMemory;

  /// No description provided for @albumChooseCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une capsule'**
  String get albumChooseCapsule;

  /// No description provided for @albumNoCapsulesForChild.
  ///
  /// In fr, this message translates to:
  /// **'Aucune capsule pour cet enfant.\nCréez-en une nouvelle pour ce moment.'**
  String get albumNoCapsulesForChild;

  /// No description provided for @timeline_quick_add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter rapidement'**
  String get timeline_quick_add;

  /// No description provided for @timeline_quick_add_prompt.
  ///
  /// In fr, this message translates to:
  /// **'Que souhaitez-vous faire ?'**
  String get timeline_quick_add_prompt;

  /// No description provided for @timeline_create_capsule.
  ///
  /// In fr, this message translates to:
  /// **'Créer une capsule'**
  String get timeline_create_capsule;

  /// No description provided for @timeline_create_capsule_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Capturez un souvenir maintenant'**
  String get timeline_create_capsule_subtitle;

  /// No description provided for @timeline_mark_milestone.
  ///
  /// In fr, this message translates to:
  /// **'Marquer un jalon'**
  String get timeline_mark_milestone;

  /// No description provided for @timeline_mark_milestone_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez un jalon de la phase actuelle'**
  String get timeline_mark_milestone_subtitle;

  /// No description provided for @timeline_upcoming_milestones.
  ///
  /// In fr, this message translates to:
  /// **'Jalons à venir'**
  String get timeline_upcoming_milestones;

  /// No description provided for @timeline_all_milestones_have_memory.
  ///
  /// In fr, this message translates to:
  /// **'Tous les jalons de cette phase ont déjà un souvenir ✓'**
  String get timeline_all_milestones_have_memory;

  /// No description provided for @timeline_add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get timeline_add;

  /// No description provided for @milestone_capture.
  ///
  /// In fr, this message translates to:
  /// **'Capturer'**
  String get milestone_capture;

  /// No description provided for @milestone_memory.
  ///
  /// In fr, this message translates to:
  /// **'Souvenir'**
  String get milestone_memory;

  /// No description provided for @milestone_phase.
  ///
  /// In fr, this message translates to:
  /// **'Phase'**
  String get milestone_phase;

  /// No description provided for @milestone_suggested.
  ///
  /// In fr, this message translates to:
  /// **'Suggéré'**
  String get milestone_suggested;

  /// No description provided for @milestone_capsule_ready.
  ///
  /// In fr, this message translates to:
  /// **'Capsule réalisée'**
  String get milestone_capsule_ready;

  /// No description provided for @milestone_view_capsule.
  ///
  /// In fr, this message translates to:
  /// **'Voir la capsule'**
  String get milestone_view_capsule;

  /// No description provided for @milestone_tap_to_open_memory.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour ouvrir le souvenir'**
  String get milestone_tap_to_open_memory;

  /// No description provided for @milestone_mark_complete.
  ///
  /// In fr, this message translates to:
  /// **'Marquer terminé'**
  String get milestone_mark_complete;

  /// No description provided for @milestone_close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get milestone_close;

  /// No description provided for @milestone_capture_this_moment.
  ///
  /// In fr, this message translates to:
  /// **'Capturer ce moment'**
  String get milestone_capture_this_moment;

  /// No description provided for @milestone_capsule_not_found.
  ///
  /// In fr, this message translates to:
  /// **'Capsule introuvable'**
  String get milestone_capsule_not_found;

  /// No description provided for @milestone_tips_and_photo_ideas.
  ///
  /// In fr, this message translates to:
  /// **'Conseils & idées photo'**
  String get milestone_tips_and_photo_ideas;

  /// No description provided for @milestone_reminder_on.
  ///
  /// In fr, this message translates to:
  /// **'Rappel le {date}'**
  String milestone_reminder_on(String date);

  /// No description provided for @milestone_schedule_reminder.
  ///
  /// In fr, this message translates to:
  /// **'Programmer un rappel'**
  String get milestone_schedule_reminder;

  /// No description provided for @milestone_marked_complete.
  ///
  /// In fr, this message translates to:
  /// **'Jalon marqué comme terminé ✓'**
  String get milestone_marked_complete;

  /// No description provided for @milestone_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String milestone_error(String error);

  /// No description provided for @milestone_tips.
  ///
  /// In fr, this message translates to:
  /// **'Conseils'**
  String get milestone_tips;

  /// No description provided for @milestone_understand_this.
  ///
  /// In fr, this message translates to:
  /// **'Comprendre ce jalon'**
  String get milestone_understand_this;

  /// No description provided for @milestone_key_points.
  ///
  /// In fr, this message translates to:
  /// **'À retenir'**
  String get milestone_key_points;

  /// No description provided for @milestone_photo_ideas.
  ///
  /// In fr, this message translates to:
  /// **'Idées pour la photo'**
  String get milestone_photo_ideas;

  /// No description provided for @milestone_reminder_tomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get milestone_reminder_tomorrow;

  /// No description provided for @milestone_reminder_date_at_nine.
  ///
  /// In fr, this message translates to:
  /// **'d MMM à 09:00'**
  String get milestone_reminder_date_at_nine;

  /// No description provided for @milestone_reminder_in_3_days.
  ///
  /// In fr, this message translates to:
  /// **'Dans 3 jours'**
  String get milestone_reminder_in_3_days;

  /// No description provided for @milestone_reminder_in_1_week.
  ///
  /// In fr, this message translates to:
  /// **'Dans 1 semaine'**
  String get milestone_reminder_in_1_week;

  /// No description provided for @milestone_reminder_on_milestone_day.
  ///
  /// In fr, this message translates to:
  /// **'Le jour du jalon'**
  String get milestone_reminder_on_milestone_day;

  /// No description provided for @milestone_reminder_choose_date_time.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date et heure'**
  String get milestone_reminder_choose_date_time;

  /// No description provided for @milestone_reminder_manual_selection.
  ///
  /// In fr, this message translates to:
  /// **'Sélection manuelle'**
  String get milestone_reminder_manual_selection;

  /// No description provided for @milestone_reminder_cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le rappel'**
  String get milestone_reminder_cancel;

  /// No description provided for @milestone_reminder_cancel_subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le rappel programmé'**
  String get milestone_reminder_cancel_subtitle;

  /// No description provided for @milestone_reminder_future_date_required.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une date dans le futur'**
  String get milestone_reminder_future_date_required;

  /// No description provided for @milestone_reminder_enable_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Activez les notifications de jalons dans Paramètres > Notifications'**
  String get milestone_reminder_enable_notifications;

  /// No description provided for @milestone_reminder_scheduled.
  ///
  /// In fr, this message translates to:
  /// **'Rappel programmé le {date} ✓'**
  String milestone_reminder_scheduled(String date);

  /// No description provided for @milestone_reminder_cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Rappel annulé'**
  String get milestone_reminder_cancelled;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSmartReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels intelligents'**
  String get notificationsSmartReminders;

  /// No description provided for @notificationsSmartRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos rappels personnalisés'**
  String get notificationsSmartRemindersSubtitle;

  /// No description provided for @notificationsSystemSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres système'**
  String get notificationsSystemSettings;

  /// No description provided for @notificationsVaccineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rappels Vaccination'**
  String get notificationsVaccineTitle;

  /// No description provided for @notificationsVaccineSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'2 jours avant la date du vaccin, à 09h00'**
  String get notificationsVaccineSubtitle;

  /// No description provided for @notificationsMilestoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Jalons de Développement'**
  String get notificationsMilestoneTitle;

  /// No description provided for @notificationsMilestoneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'7 jours avant chaque étape clé, à 09h00'**
  String get notificationsMilestoneSubtitle;

  /// No description provided for @notificationsCycleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cycle Féminin'**
  String get notificationsCycleTitle;

  /// No description provided for @notificationsCycleSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Règles dans 2 jours • Phase ovulatoire — à 08h00'**
  String get notificationsCycleSubtitle;

  /// No description provided for @notificationsInfoNote.
  ///
  /// In fr, this message translates to:
  /// **'Les rappels sont planifiés automatiquement. Ils s\'adaptent à vos données personnelles et celles de votre enfant.'**
  String get notificationsInfoNote;

  /// No description provided for @profileTimelineDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Affichage Timeline'**
  String get profileTimelineDisplay;

  /// No description provided for @profileTimelineHorizontal.
  ///
  /// In fr, this message translates to:
  /// **'Vue horizontale'**
  String get profileTimelineHorizontal;

  /// No description provided for @profileTimelineVertical.
  ///
  /// In fr, this message translates to:
  /// **'Vue verticale'**
  String get profileTimelineVertical;

  /// No description provided for @profileViewHorizontal.
  ///
  /// In fr, this message translates to:
  /// **'Horizontale'**
  String get profileViewHorizontal;

  /// No description provided for @profileViewVertical.
  ///
  /// In fr, this message translates to:
  /// **'Verticale'**
  String get profileViewVertical;

  /// No description provided for @vaccineLinkedMemory.
  ///
  /// In fr, this message translates to:
  /// **'Souvenir lié'**
  String get vaccineLinkedMemory;

  /// No description provided for @vaccineCapsuleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Capsule de vaccination'**
  String get vaccineCapsuleTitle;

  /// No description provided for @vaccineMemorySection.
  ///
  /// In fr, this message translates to:
  /// **'Souvenir'**
  String get vaccineMemorySection;

  /// No description provided for @vaccineMemoryPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une photo ou un enregistrement pour garder en mémoire ce moment.'**
  String get vaccineMemoryPrompt;

  /// No description provided for @vaccineReelsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reels éducatifs'**
  String get vaccineReelsTitle;

  /// No description provided for @vaccineReelsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Regardez des vidéos courtes sur ce vaccin réalisées par des professionnels de santé.'**
  String get vaccineReelsSubtitle;

  /// No description provided for @vaccineReelsButton.
  ///
  /// In fr, this message translates to:
  /// **'Reels'**
  String get vaccineReelsButton;

  /// No description provided for @orderStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmée'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusShipped.
  ///
  /// In fr, this message translates to:
  /// **'Expédiée'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get orderStatusCancelled;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @premiumRequired.
  ///
  /// In fr, this message translates to:
  /// **'Premium requis'**
  String get premiumRequired;

  /// No description provided for @capsulesGalleryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes Capsules'**
  String get capsulesGalleryTitle;

  /// No description provided for @capsulesRemaining.
  ///
  /// In fr, this message translates to:
  /// **'{count} restantes'**
  String capsulesRemaining(int count);

  /// No description provided for @capsulesQuotaLimitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Limite atteinte'**
  String get capsulesQuotaLimitTitle;

  /// No description provided for @capsulesQuotaLimitMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez atteint la limite de {limit} capsules pour le forfait gratuit. Passez à Premium pour un stockage illimité !'**
  String capsulesQuotaLimitMessage(int limit);

  /// No description provided for @capsulesUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get capsulesUnderstood;

  /// No description provided for @capsulesViewPremium.
  ///
  /// In fr, this message translates to:
  /// **'Voir Premium'**
  String get capsulesViewPremium;

  /// No description provided for @capsulesEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune capsule'**
  String get capsulesEmptyTitle;

  /// No description provided for @capsulesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Capturez vos premiers souvenirs\nen appuyant sur le bouton ci-dessous'**
  String get capsulesEmptySubtitle;

  /// No description provided for @capsulesLoadErrorSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les capsules'**
  String get capsulesLoadErrorSubtitle;

  /// No description provided for @capsuleSharePreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation du partage…'**
  String get capsuleSharePreparing;

  /// No description provided for @capsuleShareText.
  ///
  /// In fr, this message translates to:
  /// **'✨ Un souvenir précieux via Luckymam\n{emotion}'**
  String capsuleShareText(String emotion);

  /// No description provided for @capsuleShareError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de partage : {error}'**
  String capsuleShareError(String error);

  /// No description provided for @capsuleGalleryPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission galerie refusée'**
  String get capsuleGalleryPermissionDenied;

  /// No description provided for @capsuleSavedToGallery.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré dans l\'album Luckymam 📸'**
  String get capsuleSavedToGallery;

  /// No description provided for @capsuleSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'enregistrement : {error}'**
  String capsuleSaveError(String error);

  /// No description provided for @capsulePremiumFeatureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité Premium'**
  String get capsulePremiumFeatureTitle;

  /// No description provided for @capsulePremiumFeatureDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le partage et l\'enregistrement de capsules\nsont réservés aux abonnés Premium et VIP.'**
  String get capsulePremiumFeatureDesc;

  /// No description provided for @capsulePremiumUpgradeCta.
  ///
  /// In fr, this message translates to:
  /// **'🌟 Passer à Premium — 2 490 DA/an'**
  String get capsulePremiumUpgradeCta;

  /// No description provided for @capsuleDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la capsule ?'**
  String get capsuleDeleteTitle;

  /// No description provided for @capsuleDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Le souvenir sera supprimé définitivement.'**
  String get capsuleDeleteMessage;

  /// No description provided for @capsuleNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Capsule'**
  String get capsuleNewTitle;

  /// No description provided for @capsuleAddPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get capsuleAddPhoto;

  /// No description provided for @capsulePhotoSourceHint.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo ou galerie'**
  String get capsulePhotoSourceHint;

  /// No description provided for @capsuleAddChildPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un enfant dans votre profil pour créer des capsules'**
  String get capsuleAddChildPrompt;

  /// No description provided for @capsuleWhichChild.
  ///
  /// In fr, this message translates to:
  /// **'🧒 Pour quel enfant ?'**
  String get capsuleWhichChild;

  /// No description provided for @capsuleTagsOptional.
  ///
  /// In fr, this message translates to:
  /// **'🏷️ Tags (optionnel)'**
  String get capsuleTagsOptional;

  /// No description provided for @capsuleAddTagHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un tag...'**
  String get capsuleAddTagHint;

  /// No description provided for @capsuleCategory.
  ///
  /// In fr, this message translates to:
  /// **'📂 Catégorie'**
  String get capsuleCategory;

  /// No description provided for @capsuleRequired.
  ///
  /// In fr, this message translates to:
  /// **'(obligatoire)'**
  String get capsuleRequired;

  /// No description provided for @capsulePhotoDate.
  ///
  /// In fr, this message translates to:
  /// **'📅 Date de la photo'**
  String get capsulePhotoDate;

  /// No description provided for @capsuleTodayDefault.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui (par défaut)'**
  String get capsuleTodayDefault;

  /// No description provided for @capsulePhotoDateHint.
  ///
  /// In fr, this message translates to:
  /// **'Utile si la photo a été prise à une autre date'**
  String get capsulePhotoDateHint;

  /// No description provided for @capsulePhotoDatePickerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Date de la photo'**
  String get capsulePhotoDatePickerHelp;

  /// No description provided for @capsuleChooseSource.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une source'**
  String get capsuleChooseSource;

  /// No description provided for @capsuleCamera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get capsuleCamera;

  /// No description provided for @capsuleGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get capsuleGallery;

  /// No description provided for @capsuleCreatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Capsule créée avec succès ! ✨'**
  String get capsuleCreatedSuccess;

  /// No description provided for @capsuleEmotion.
  ///
  /// In fr, this message translates to:
  /// **'Émotion'**
  String get capsuleEmotion;

  /// No description provided for @capsuleVoiceMessageOptional.
  ///
  /// In fr, this message translates to:
  /// **'🎤 Message vocal (optionnel)'**
  String get capsuleVoiceMessageOptional;

  /// No description provided for @capsuleHoldToRecord.
  ///
  /// In fr, this message translates to:
  /// **'Maintenir pour enregistrer'**
  String get capsuleHoldToRecord;

  /// No description provided for @capsuleMaxDuration.
  ///
  /// In fr, this message translates to:
  /// **'Max {seconds}s'**
  String capsuleMaxDuration(int seconds);

  /// No description provided for @capsuleReleaseToStop.
  ///
  /// In fr, this message translates to:
  /// **'Relâchez pour arrêter l\'enregistrement'**
  String get capsuleReleaseToStop;

  /// No description provided for @capsuleVoiceRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Message vocal enregistré'**
  String get capsuleVoiceRecorded;

  /// No description provided for @capsuleDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée : {duration}'**
  String capsuleDuration(String duration);

  /// No description provided for @healthLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get healthLoadingError;

  /// No description provided for @healthHubSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Croissance & Rendez-vous'**
  String get healthHubSubtitle;

  /// No description provided for @healthTabGrowth.
  ///
  /// In fr, this message translates to:
  /// **'📈 Croissance'**
  String get healthTabGrowth;

  /// No description provided for @healthTabAppointments.
  ///
  /// In fr, this message translates to:
  /// **'🗓 Rendez-vous'**
  String get healthTabAppointments;

  /// No description provided for @healthNoChildTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enfant enregistré'**
  String get healthNoChildTitle;

  /// No description provided for @healthNoChildHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un enfant dans votre profil.'**
  String get healthNoChildHint;

  /// No description provided for @healthTabSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins · Croissance · Rendez-vous'**
  String get healthTabSubtitle;

  /// No description provided for @healthTabVaccines.
  ///
  /// In fr, this message translates to:
  /// **'💉 Vaccins'**
  String get healthTabVaccines;

  /// No description provided for @healthTabRdv.
  ///
  /// In fr, this message translates to:
  /// **'🗓 RDV'**
  String get healthTabRdv;

  /// No description provided for @healthErrorWithDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String healthErrorWithDetail(String error);

  /// No description provided for @healthWeightChartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Courbe de poids'**
  String get healthWeightChartTitle;

  /// No description provided for @healthWhoP50.
  ///
  /// In fr, this message translates to:
  /// **'OMS p50'**
  String get healthWhoP50;

  /// No description provided for @healthMeasurementHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des mesures'**
  String get healthMeasurementHistory;

  /// No description provided for @healthMeasurementFab.
  ///
  /// In fr, this message translates to:
  /// **'Mesure'**
  String get healthMeasurementFab;

  /// No description provided for @healthNoMeasurementsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune mesure enregistrée'**
  String get healthNoMeasurementsTitle;

  /// No description provided for @healthNoMeasurementsHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur + pour ajouter\nune mesure de croissance.'**
  String get healthNoMeasurementsHint;

  /// No description provided for @healthDeleteMeasurementTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette mesure ?'**
  String get healthDeleteMeasurementTitle;

  /// No description provided for @healthCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get healthCancel;

  /// No description provided for @healthDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get healthDelete;

  /// No description provided for @healthNewMeasurement.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle mesure'**
  String get healthNewMeasurement;

  /// No description provided for @healthWeightKg.
  ///
  /// In fr, this message translates to:
  /// **'Poids (kg)'**
  String get healthWeightKg;

  /// No description provided for @healthHeightCm.
  ///
  /// In fr, this message translates to:
  /// **'Taille (cm)'**
  String get healthHeightCm;

  /// No description provided for @healthNotesOptional.
  ///
  /// In fr, this message translates to:
  /// **'Notes (optionnel)'**
  String get healthNotesOptional;

  /// No description provided for @healthMeasurementSaved.
  ///
  /// In fr, this message translates to:
  /// **'Mesure enregistrée ✓'**
  String get healthMeasurementSaved;

  /// No description provided for @healthSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get healthSave;

  /// No description provided for @healthAppointmentFab.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous'**
  String get healthAppointmentFab;

  /// No description provided for @healthNoAppointmentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous'**
  String get healthNoAppointmentsTitle;

  /// No description provided for @healthNoAppointmentsHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez les visites médicales\net les résultats de bilans.'**
  String get healthNoAppointmentsHint;

  /// No description provided for @healthDeleteAppointmentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce rendez-vous ?'**
  String get healthDeleteAppointmentTitle;

  /// No description provided for @healthNewAppointment.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau rendez-vous'**
  String get healthNewAppointment;

  /// No description provided for @healthDoctorName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du médecin'**
  String get healthDoctorName;

  /// No description provided for @healthSpecialty.
  ///
  /// In fr, this message translates to:
  /// **'Spécialité'**
  String get healthSpecialty;

  /// No description provided for @healthNotesObservationsOptional.
  ///
  /// In fr, this message translates to:
  /// **'Notes / observations (optionnel)'**
  String get healthNotesObservationsOptional;

  /// No description provided for @healthAttachPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get healthAttachPhoto;

  /// No description provided for @healthAttachPdfFile.
  ///
  /// In fr, this message translates to:
  /// **'PDF / Fichier'**
  String get healthAttachPdfFile;

  /// No description provided for @healthUploadingFiles.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des fichiers…'**
  String get healthUploadingFiles;

  /// No description provided for @healthSaving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get healthSaving;

  /// No description provided for @healthAppointmentSaved.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous enregistré ✓'**
  String get healthAppointmentSaved;

  /// No description provided for @healthSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'enregistrement'**
  String get healthSaveError;

  /// No description provided for @healthWeightValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} kg'**
  String healthWeightValue(String value);

  /// No description provided for @healthHeightValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} cm'**
  String healthHeightValue(String value);

  /// No description provided for @healthChartAxisKg.
  ///
  /// In fr, this message translates to:
  /// **'{value} kg'**
  String healthChartAxisKg(String value);

  /// No description provided for @healthChartAxisMonths.
  ///
  /// In fr, this message translates to:
  /// **'{value}m'**
  String healthChartAxisMonths(String value);

  /// No description provided for @healthChartTooltip.
  ///
  /// In fr, this message translates to:
  /// **'{weight} kg\n{months}m'**
  String healthChartTooltip(String weight, String months);

  /// No description provided for @healthChartEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une mesure\npour voir la courbe'**
  String get healthChartEmptyHint;

  /// No description provided for @healthApptTypeGeneraliste.
  ///
  /// In fr, this message translates to:
  /// **'Médecin généraliste'**
  String get healthApptTypeGeneraliste;

  /// No description provided for @healthApptTypePediatre.
  ///
  /// In fr, this message translates to:
  /// **'Pédiatre'**
  String get healthApptTypePediatre;

  /// No description provided for @healthApptTypeDentiste.
  ///
  /// In fr, this message translates to:
  /// **'Dentiste'**
  String get healthApptTypeDentiste;

  /// No description provided for @healthApptTypeOphtalmologue.
  ///
  /// In fr, this message translates to:
  /// **'Ophtalmologue'**
  String get healthApptTypeOphtalmologue;

  /// No description provided for @healthApptTypeCardiologue.
  ///
  /// In fr, this message translates to:
  /// **'Cardiologue'**
  String get healthApptTypeCardiologue;

  /// No description provided for @healthApptTypeAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre spécialiste'**
  String get healthApptTypeAutre;

  /// No description provided for @healthMotherTitle.
  ///
  /// In fr, this message translates to:
  /// **'Santé Maman'**
  String get healthMotherTitle;

  /// No description provided for @healthMotherPregnancyTracking.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de grossesse'**
  String get healthMotherPregnancyTracking;

  /// No description provided for @healthMotherViewMedicalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Consultez vos infos médicales'**
  String get healthMotherViewMedicalInfo;

  /// No description provided for @subscriptionPlansTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un forfait'**
  String get subscriptionPlansTitle;

  /// No description provided for @subscriptionPlansSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez toutes les fonctionnalités'**
  String get subscriptionPlansSubtitle;

  /// No description provided for @subscriptionPlanCurrentBadge.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get subscriptionPlanCurrentBadge;

  /// No description provided for @subscriptionPlanCurrentButton.
  ///
  /// In fr, this message translates to:
  /// **'Votre forfait actuel'**
  String get subscriptionPlanCurrentButton;

  /// No description provided for @subscriptionPlanSelect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get subscriptionPlanSelect;

  /// No description provided for @subscriptionPlanChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir ce forfait'**
  String get subscriptionPlanChoose;

  /// No description provided for @paymentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get paymentTitle;

  /// No description provided for @paymentBaridiMob.
  ///
  /// In fr, this message translates to:
  /// **'BaridiMob'**
  String get paymentBaridiMob;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In fr, this message translates to:
  /// **'Moyen de paiement'**
  String get paymentMethodTitle;

  /// No description provided for @paymentMethodCib.
  ///
  /// In fr, this message translates to:
  /// **'CIB'**
  String get paymentMethodCib;

  /// No description provided for @paymentMethodCibDescription.
  ///
  /// In fr, this message translates to:
  /// **'Carte Interbancaire'**
  String get paymentMethodCibDescription;

  /// No description provided for @paymentMethodEdahabia.
  ///
  /// In fr, this message translates to:
  /// **'Edahabia'**
  String get paymentMethodEdahabia;

  /// No description provided for @paymentMethodEdahabiaDescription.
  ///
  /// In fr, this message translates to:
  /// **'Algérie Poste'**
  String get paymentMethodEdahabiaDescription;

  /// No description provided for @paymentCardDetailsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails de la carte'**
  String get paymentCardDetailsTitle;

  /// No description provided for @paymentCardHolderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titulaire de la carte'**
  String get paymentCardHolderLabel;

  /// No description provided for @paymentCardNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de carte'**
  String get paymentCardNumberLabel;

  /// No description provided for @paymentCardNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'0000 0000 0000 0000'**
  String get paymentCardNumberHint;

  /// No description provided for @paymentExpiryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Expiration'**
  String get paymentExpiryLabel;

  /// No description provided for @paymentExpiryHint.
  ///
  /// In fr, this message translates to:
  /// **'MM/AA'**
  String get paymentExpiryHint;

  /// No description provided for @paymentCvvLabel.
  ///
  /// In fr, this message translates to:
  /// **'CVV'**
  String get paymentCvvLabel;

  /// No description provided for @paymentCvvHint.
  ///
  /// In fr, this message translates to:
  /// **'***'**
  String get paymentCvvHint;

  /// No description provided for @paymentPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'0550 00 00 00'**
  String get paymentPhoneHint;

  /// No description provided for @paymentSecurityNotice.
  ///
  /// In fr, this message translates to:
  /// **'Paiement sécurisé via BaridiMob. Vos données bancaires sont protégées.'**
  String get paymentSecurityNotice;

  /// No description provided for @paymentConfirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le paiement • {price} DZD'**
  String paymentConfirmButton(int price);

  /// No description provided for @paymentPriceDzd.
  ///
  /// In fr, this message translates to:
  /// **'{price} DZD'**
  String paymentPriceDzd(int price);

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement réussi !'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessActivePlan.
  ///
  /// In fr, this message translates to:
  /// **'Votre abonnement {planTitle} est maintenant actif.'**
  String paymentSuccessActivePlan(String planTitle);

  /// No description provided for @paymentSuccessAlbumPerk.
  ///
  /// In fr, this message translates to:
  /// **'Votre album imprimé gratuit vous attend ! Rendez-vous dans votre profil.'**
  String get paymentSuccessAlbumPerk;

  /// No description provided for @subscriptionAlbumClaimTitle.
  ///
  /// In fr, this message translates to:
  /// **'Album Imprimé Gratuit'**
  String get subscriptionAlbumClaimTitle;

  /// No description provided for @subscriptionAlbumClaimSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre cadeau VIP 🎁'**
  String get subscriptionAlbumClaimSubtitle;

  /// No description provided for @subscriptionAlbumClaimInfo.
  ///
  /// In fr, this message translates to:
  /// **'En tant que membre VIP, vous recevez un album photo imprimé de vos plus beaux souvenirs. Remplissez le formulaire ci-dessous.'**
  String get subscriptionAlbumClaimInfo;

  /// No description provided for @subscriptionAlbumClaimSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer ma demande'**
  String get subscriptionAlbumClaimSubmit;

  /// No description provided for @subscriptionAlbumClaimSubmittedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée !'**
  String get subscriptionAlbumClaimSubmittedTitle;

  /// No description provided for @subscriptionAlbumClaimSubmittedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre album imprimé sera préparé et expédié à l\'adresse indiquée. Nous vous contacterons par téléphone pour confirmer.'**
  String get subscriptionAlbumClaimSubmittedMessage;

  /// No description provided for @subscriptionAlbumClaimSelectChildError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un enfant'**
  String get subscriptionAlbumClaimSelectChildError;

  /// No description provided for @subscriptionBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get subscriptionBack;

  /// No description provided for @subscriptionDiamondSponsorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sponsors Diamant'**
  String get subscriptionDiamondSponsorsTitle;

  /// No description provided for @subscriptionDiamondPartnersHero.
  ///
  /// In fr, this message translates to:
  /// **'Nos Partenaires Diamant'**
  String get subscriptionDiamondPartnersHero;

  /// No description provided for @subscriptionDiamondPartnersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Des marques de confiance qui accompagnent\nchaque maman dans son parcours'**
  String get subscriptionDiamondPartnersSubtitle;

  /// No description provided for @subscriptionDiamondPillExclusive.
  ///
  /// In fr, this message translates to:
  /// **'💎 Exclusif'**
  String get subscriptionDiamondPillExclusive;

  /// No description provided for @subscriptionDiamondPillPremium.
  ///
  /// In fr, this message translates to:
  /// **'⭐ Premium'**
  String get subscriptionDiamondPillPremium;

  /// No description provided for @subscriptionDiamondPillCertified.
  ///
  /// In fr, this message translates to:
  /// **'✅ Certifié'**
  String get subscriptionDiamondPillCertified;

  /// No description provided for @subscriptionDiamondLogosSection.
  ///
  /// In fr, this message translates to:
  /// **'Logos & Partenaires'**
  String get subscriptionDiamondLogosSection;

  /// No description provided for @subscriptionDiamondOfficialPartners.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires officiels de l\'application Luckymam'**
  String get subscriptionDiamondOfficialPartners;

  /// No description provided for @subscriptionDiamondBadge.
  ///
  /// In fr, this message translates to:
  /// **'Diamant'**
  String get subscriptionDiamondBadge;

  /// No description provided for @subscriptionDiamondJoinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez nos Sponsors Diamant'**
  String get subscriptionDiamondJoinTitle;

  /// No description provided for @subscriptionDiamondJoinSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Atteignez des milliers de mamans algériennes.\nContactez-nous pour un partenariat Diamant.'**
  String get subscriptionDiamondJoinSubtitle;

  /// No description provided for @subscriptionDiamondContactEmail.
  ///
  /// In fr, this message translates to:
  /// **'sponsors@Luckymam.com'**
  String get subscriptionDiamondContactEmail;

  /// No description provided for @subscriptionDiamondPartner1Name.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire Diamant 1'**
  String get subscriptionDiamondPartner1Name;

  /// No description provided for @subscriptionDiamondPartner1Category.
  ///
  /// In fr, this message translates to:
  /// **'Santé & Maternité'**
  String get subscriptionDiamondPartner1Category;

  /// No description provided for @subscriptionDiamondPartner1Description.
  ///
  /// In fr, this message translates to:
  /// **'Leader en solutions de santé pour femmes et enfants.'**
  String get subscriptionDiamondPartner1Description;

  /// No description provided for @subscriptionDiamondPartner2Name.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire Diamant 2'**
  String get subscriptionDiamondPartner2Name;

  /// No description provided for @subscriptionDiamondPartner2Category.
  ///
  /// In fr, this message translates to:
  /// **'Nutrition Infantile'**
  String get subscriptionDiamondPartner2Category;

  /// No description provided for @subscriptionDiamondPartner2Description.
  ///
  /// In fr, this message translates to:
  /// **'Experts en nutrition pour bébés et jeunes enfants.'**
  String get subscriptionDiamondPartner2Description;

  /// No description provided for @subscriptionDiamondPartner3Name.
  ///
  /// In fr, this message translates to:
  /// **'Partenaire Diamant 3'**
  String get subscriptionDiamondPartner3Name;

  /// No description provided for @subscriptionDiamondPartner3Category.
  ///
  /// In fr, this message translates to:
  /// **'Puériculture'**
  String get subscriptionDiamondPartner3Category;

  /// No description provided for @subscriptionDiamondPartner3Description.
  ///
  /// In fr, this message translates to:
  /// **'Équipements premium pour l\'éveil de votre bébé.'**
  String get subscriptionDiamondPartner3Description;

  /// No description provided for @homeMarketplaceSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Produits bébé & maman de nos partenaires'**
  String get homeMarketplaceSubtitle;

  /// No description provided for @homeHealthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Santé Enfant'**
  String get homeHealthTitle;

  /// No description provided for @homeHealthSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Courbe de croissance · Rendez-vous médicaux'**
  String get homeHealthSubtitle;

  /// No description provided for @homeReelsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos courtes · Conseils parentaux'**
  String get homeReelsSubtitle;

  /// No description provided for @homeMemoryBookAlbumsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 album auto-généré} other{{count} albums auto-générés}}'**
  String homeMemoryBookAlbumsCount(int count);

  /// No description provided for @homeMemoryBookEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos souvenirs en albums'**
  String get homeMemoryBookEmptySubtitle;

  /// No description provided for @homeChildAllGood.
  ///
  /// In fr, this message translates to:
  /// **'Tout va bien !'**
  String get homeChildAllGood;

  /// No description provided for @homeChildVaccineLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vaccin: {codes}'**
  String homeChildVaccineLabel(String codes);

  /// No description provided for @homeYourChildren.
  ///
  /// In fr, this message translates to:
  /// **'Vos Enfants'**
  String get homeYourChildren;

  /// No description provided for @homeRecentCapsulesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre première capsule!'**
  String get homeRecentCapsulesEmpty;

  /// No description provided for @homeVaccineCalendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier Vaccinal'**
  String get homeVaccineCalendarTitle;

  /// No description provided for @homeVaccineCalendarSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Programme National Algérien'**
  String get homeVaccineCalendarSubtitle;

  /// No description provided for @homeVaccineMarkComplete.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme fait'**
  String get homeVaccineMarkComplete;

  /// No description provided for @homeVaccineDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de vaccination'**
  String get homeVaccineDateLabel;

  /// No description provided for @homeVaccineNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Docteur Martin, clinique...'**
  String get homeVaccineNotesHint;

  /// No description provided for @homeVaccineMarkedComplete.
  ///
  /// In fr, this message translates to:
  /// **'Vaccin marqué comme fait ✓'**
  String get homeVaccineMarkedComplete;

  /// No description provided for @homeVaccineCancelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le vaccin ?'**
  String get homeVaccineCancelTitle;

  /// No description provided for @homeVaccineCancelMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous marquer \"{ageLabel}\" comme non fait ?'**
  String homeVaccineCancelMessage(String ageLabel);

  /// No description provided for @homeVaccineNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get homeVaccineNo;

  /// No description provided for @homeVaccineYesCancel.
  ///
  /// In fr, this message translates to:
  /// **'Oui, annuler'**
  String get homeVaccineYesCancel;

  /// No description provided for @homeVaccineNoChildrenHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un enfant dans votre profil pour voir son calendrier vaccinal.'**
  String get homeVaccineNoChildrenHint;

  /// No description provided for @homeLoadDataError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les données'**
  String get homeLoadDataError;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations Personnelles'**
  String get profilePersonalInfo;

  /// No description provided for @profileMedicalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations Médicales'**
  String get profileMedicalInfo;

  /// No description provided for @profileCurrentStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut Actuel'**
  String get profileCurrentStatus;

  /// No description provided for @profileMenstrualCycle.
  ///
  /// In fr, this message translates to:
  /// **'Cycle Menstruel'**
  String get profileMenstrualCycle;

  /// No description provided for @profileMyPregnancy.
  ///
  /// In fr, this message translates to:
  /// **'Ma Grossesse'**
  String get profileMyPregnancy;

  /// No description provided for @profileMySubscription.
  ///
  /// In fr, this message translates to:
  /// **'Mon Abonnement'**
  String get profileMySubscription;

  /// No description provided for @profileSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get profileSettings;

  /// No description provided for @profileNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get profileNotProvided;

  /// No description provided for @profilePhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get profilePhone;

  /// No description provided for @profileBirthDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get profileBirthDate;

  /// No description provided for @profileWilaya.
  ///
  /// In fr, this message translates to:
  /// **'Wilaya'**
  String get profileWilaya;

  /// No description provided for @profileCurrentPhase.
  ///
  /// In fr, this message translates to:
  /// **'Phase actuelle'**
  String get profileCurrentPhase;

  /// No description provided for @profileLastPregnancy.
  ///
  /// In fr, this message translates to:
  /// **'Dernière grossesse'**
  String get profileLastPregnancy;

  /// No description provided for @profileBloodType.
  ///
  /// In fr, this message translates to:
  /// **'Groupe sanguin'**
  String get profileBloodType;

  /// No description provided for @profileAllergies.
  ///
  /// In fr, this message translates to:
  /// **'Allergies'**
  String get profileAllergies;

  /// No description provided for @profileNoKnownAllergies.
  ///
  /// In fr, this message translates to:
  /// **'Aucune allergie connue'**
  String get profileNoKnownAllergies;

  /// No description provided for @profileMedicalConditions.
  ///
  /// In fr, this message translates to:
  /// **'Conditions médicales'**
  String get profileMedicalConditions;

  /// No description provided for @profileNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get profileNone;

  /// No description provided for @profileDoctor.
  ///
  /// In fr, this message translates to:
  /// **'Médecin traitant'**
  String get profileDoctor;

  /// No description provided for @profilePregnancyLmpPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Renseignez votre DDR pour calculer votre DPA et votre semaine d\'aménorrhée.'**
  String get profilePregnancyLmpPrompt;

  /// No description provided for @profileLmpLabel.
  ///
  /// In fr, this message translates to:
  /// **'DDR (dernières règles)'**
  String get profileLmpLabel;

  /// No description provided for @profileGestationalWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine d\'aménorrhée'**
  String get profileGestationalWeek;

  /// No description provided for @profileDueDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'DPA (date présumée)'**
  String get profileDueDateLabel;

  /// No description provided for @profileCountdown.
  ///
  /// In fr, this message translates to:
  /// **'Compte à rebours'**
  String get profileCountdown;

  /// No description provided for @profileLastPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Dernières règles'**
  String get profileLastPeriod;

  /// No description provided for @profileNextPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines règles'**
  String get profileNextPeriod;

  /// No description provided for @profileAverageDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée moyenne'**
  String get profileAverageDuration;

  /// No description provided for @profileCycleNotActive.
  ///
  /// In fr, this message translates to:
  /// **'Suivi du cycle non activé'**
  String get profileCycleNotActive;

  /// No description provided for @profileCycleDays.
  ///
  /// In fr, this message translates to:
  /// **'Cycle de {days} jours'**
  String profileCycleDays(int days);

  /// No description provided for @profileFreePlan.
  ///
  /// In fr, this message translates to:
  /// **'Forfait gratuit'**
  String get profileFreePlan;

  /// No description provided for @profileManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer'**
  String get profileManage;

  /// No description provided for @profileAlbumClaimSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande d\'album envoyée ✓'**
  String get profileAlbumClaimSent;

  /// No description provided for @profileClaimFreeAlbum.
  ///
  /// In fr, this message translates to:
  /// **'Réclamer votre album imprimé gratuit 🎁'**
  String get profileClaimFreeAlbum;

  /// No description provided for @profileDarkTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get profileDarkTheme;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileManageReminders.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les rappels'**
  String get profileManageReminders;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get profileLogout;

  /// No description provided for @profileSelectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get profileSelectLanguage;

  /// No description provided for @profileLanguageFr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get profileLanguageFr;

  /// No description provided for @profileLanguageAr.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get profileLanguageAr;

  /// No description provided for @profileLanguageEn.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileStatusHopeShort.
  ///
  /// In fr, this message translates to:
  /// **'Espoir'**
  String get profileStatusHopeShort;

  /// No description provided for @profileLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get profileLoading;

  /// No description provided for @profileDefaultUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisatrice'**
  String get profileDefaultUser;

  /// No description provided for @profileError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get profileError;

  /// No description provided for @profileEditPersonalInfo.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mes informations'**
  String get profileEditPersonalInfo;

  /// No description provided for @profileEditMedicalInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations médicales'**
  String get profileEditMedicalInfoTitle;

  /// No description provided for @profileAllergiesHint.
  ///
  /// In fr, this message translates to:
  /// **'Allergies (séparées par virgule)'**
  String get profileAllergiesHint;

  /// No description provided for @profileConditionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Conditions médicales (séparées par virgule)'**
  String get profileConditionsHint;

  /// No description provided for @profileDoctorName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du médecin'**
  String get profileDoctorName;

  /// No description provided for @profileDoctorPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone du médecin'**
  String get profileDoctorPhone;

  /// No description provided for @profileEditChild.
  ///
  /// In fr, this message translates to:
  /// **'Modifier enfant'**
  String get profileEditChild;

  /// No description provided for @profileFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get profileFirstName;

  /// No description provided for @profileGirl.
  ///
  /// In fr, this message translates to:
  /// **'Fille'**
  String get profileGirl;

  /// No description provided for @profileBoy.
  ///
  /// In fr, this message translates to:
  /// **'Garçon'**
  String get profileBoy;

  /// No description provided for @profileBirthDateRequired.
  ///
  /// In fr, this message translates to:
  /// **'La date de naissance est obligatoire'**
  String get profileBirthDateRequired;

  /// No description provided for @profileDeleteChildTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet enfant ?'**
  String get profileDeleteChildTitle;

  /// No description provided for @profileIrreversibleAction.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get profileIrreversibleAction;

  /// No description provided for @profileCycleSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres du cycle'**
  String get profileCycleSettings;

  /// No description provided for @profileCycleLength.
  ///
  /// In fr, this message translates to:
  /// **'Durée du cycle'**
  String get profileCycleLength;

  /// No description provided for @profilePeriodDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée des règles'**
  String get profilePeriodDuration;

  /// No description provided for @profileDaysCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} jours'**
  String profileDaysCount(int count);

  /// No description provided for @profileNewCapsule.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle capsule'**
  String get profileNewCapsule;

  /// No description provided for @profileVaccinesDone.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins faits'**
  String get profileVaccinesDone;

  /// No description provided for @profileAge.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get profileAge;

  /// No description provided for @profileVaccinations.
  ///
  /// In fr, this message translates to:
  /// **'Vaccinations'**
  String get profileVaccinations;

  /// No description provided for @profileNoCapsulesForChild.
  ///
  /// In fr, this message translates to:
  /// **'Aucune capsule pour {name}'**
  String profileNoCapsulesForChild(String name);

  /// No description provided for @profileCaptureFirstMemory.
  ///
  /// In fr, this message translates to:
  /// **'Capturez un premier souvenir !'**
  String get profileCaptureFirstMemory;

  /// No description provided for @profileMvpFooter.
  ///
  /// In fr, this message translates to:
  /// **'MVP - {appName} {year}'**
  String profileMvpFooter(String appName, int year);

  /// No description provided for @profileGestationalWeekValue.
  ///
  /// In fr, this message translates to:
  /// **'SA {week} / 40'**
  String profileGestationalWeekValue(int week);

  /// No description provided for @profilePhasePeriod.
  ///
  /// In fr, this message translates to:
  /// **'Règles'**
  String get profilePhasePeriod;

  /// No description provided for @profilePhaseFollicular.
  ///
  /// In fr, this message translates to:
  /// **'Phase Folliculaire'**
  String get profilePhaseFollicular;

  /// No description provided for @profilePhaseOvulatory.
  ///
  /// In fr, this message translates to:
  /// **'Phase Ovulatoire'**
  String get profilePhaseOvulatory;

  /// No description provided for @profilePhaseLuteal.
  ///
  /// In fr, this message translates to:
  /// **'Phase Lutéale'**
  String get profilePhaseLuteal;

  /// No description provided for @profileSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get profileSave;

  /// No description provided for @profileCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get profileCancel;

  /// No description provided for @errorWithMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorWithMessage(String error);

  /// No description provided for @reelsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reels Éducatifs'**
  String get reelsTitle;

  /// No description provided for @reelsFiltered.
  ///
  /// In fr, this message translates to:
  /// **'Filtré : {label}'**
  String reelsFiltered(String label);

  /// No description provided for @reelsEmptyCategory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun reel dans cette catégorie'**
  String get reelsEmptyCategory;

  /// No description provided for @reelsAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get reelsAll;

  /// No description provided for @reelsSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauver'**
  String get reelsSave;

  /// No description provided for @reelCategoryVaccins.
  ///
  /// In fr, this message translates to:
  /// **'Vaccins'**
  String get reelCategoryVaccins;

  /// No description provided for @reelCategoryGrossesseHta.
  ///
  /// In fr, this message translates to:
  /// **'Grossesse & HTA'**
  String get reelCategoryGrossesseHta;

  /// No description provided for @reelCategoryGrossesseDiabete.
  ///
  /// In fr, this message translates to:
  /// **'Grossesse & Diabète'**
  String get reelCategoryGrossesseDiabete;

  /// No description provided for @reelCategorySoutien.
  ///
  /// In fr, this message translates to:
  /// **'Soutien'**
  String get reelCategorySoutien;

  /// No description provided for @reelCategorySoins.
  ///
  /// In fr, this message translates to:
  /// **'Soins'**
  String get reelCategorySoins;

  /// No description provided for @reelCategoryNutrition.
  ///
  /// In fr, this message translates to:
  /// **'Nutrition'**
  String get reelCategoryNutrition;

  /// No description provided for @adsSponsored.
  ///
  /// In fr, this message translates to:
  /// **'Sponsorisé · {sponsor}'**
  String adsSponsored(String sponsor);

  /// No description provided for @authLaw1807LegalRef.
  ///
  /// In fr, this message translates to:
  /// **'Référence d\'alignement légal : Loi Algérienne n° 18-07 relative à la protection des personnes physiques dans le traitement des données à caractère personnel.'**
  String get authLaw1807LegalRef;

  /// No description provided for @authLaw1807ScrollWarning.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez faire défiler tout le texte vers le bas pour activer l\'acceptation.'**
  String get authLaw1807ScrollWarning;

  /// No description provided for @onboardingTitleLine1.
  ///
  /// In fr, this message translates to:
  /// **'Des souvenirs à transmettre,'**
  String get onboardingTitleLine1;

  /// No description provided for @onboardingTitleLine2.
  ///
  /// In fr, this message translates to:
  /// **'des émotions à revivre'**
  String get onboardingTitleLine2;

  /// No description provided for @timelineLifeBook.
  ///
  /// In fr, this message translates to:
  /// **'Le Livre de Vie'**
  String get timelineLifeBook;

  /// No description provided for @timelineLifeBookOf.
  ///
  /// In fr, this message translates to:
  /// **'de {name}'**
  String timelineLifeBookOf(String name);

  /// No description provided for @timelineNoMilestonesPhase.
  ///
  /// In fr, this message translates to:
  /// **'Aucun jalon pour cette phase'**
  String get timelineNoMilestonesPhase;

  /// No description provided for @timelineMilestonesAppear.
  ///
  /// In fr, this message translates to:
  /// **'Les jalons apparaîtront au bon moment'**
  String get timelineMilestonesAppear;

  /// No description provided for @timelineAddChildTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un enfant'**
  String get timelineAddChildTitle;

  /// No description provided for @timelineAddChildHint.
  ///
  /// In fr, this message translates to:
  /// **'Pour voir sa timeline personnalisée'**
  String get timelineAddChildHint;

  /// No description provided for @timelineStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'✓ Réalisé'**
  String get timelineStatusCompleted;

  /// No description provided for @timelineStatusOverdue.
  ///
  /// In fr, this message translates to:
  /// **'À rattraper'**
  String get timelineStatusOverdue;

  /// No description provided for @timelineStatusNow.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get timelineStatusNow;

  /// No description provided for @timelineDueToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get timelineDueToday;

  /// No description provided for @timelineDueDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {days}j'**
  String timelineDueDaysAgo(int days);

  /// No description provided for @timelineDueInDays.
  ///
  /// In fr, this message translates to:
  /// **'dans {days}j'**
  String timelineDueInDays(int days);

  /// No description provided for @timelineDueInMonths.
  ///
  /// In fr, this message translates to:
  /// **'dans {months} mois'**
  String timelineDueInMonths(int months);

  /// No description provided for @timelineDueInYears.
  ///
  /// In fr, this message translates to:
  /// **'dans {years} ans'**
  String timelineDueInYears(int years);

  /// No description provided for @timelineDueInYearsSingular.
  ///
  /// In fr, this message translates to:
  /// **'dans {years} an'**
  String timelineDueInYearsSingular(int years);

  /// No description provided for @timelinePhaseCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get timelinePhaseCurrent;

  /// No description provided for @vaccineDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get vaccineDetails;

  /// No description provided for @vaccineCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le vaccin'**
  String get vaccineCancel;

  /// No description provided for @vaccineMarkDone.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme fait'**
  String get vaccineMarkDone;

  /// No description provided for @vaccineDoneOn.
  ///
  /// In fr, this message translates to:
  /// **'Fait le {date}'**
  String vaccineDoneOn(String date);

  /// No description provided for @vaccineCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Complété'**
  String get vaccineCompleted;

  /// No description provided for @vaccineOverdueDays.
  ///
  /// In fr, this message translates to:
  /// **'En retard de {days} jours'**
  String vaccineOverdueDays(int days);

  /// No description provided for @vaccineDueToday.
  ///
  /// In fr, this message translates to:
  /// **'Prévu aujourd\'hui'**
  String get vaccineDueToday;

  /// No description provided for @vaccineDueInDays.
  ///
  /// In fr, this message translates to:
  /// **'Dans {days} jours'**
  String vaccineDueInDays(int days);

  /// No description provided for @vaccineDone.
  ///
  /// In fr, this message translates to:
  /// **'Fait'**
  String get vaccineDone;

  /// No description provided for @vaccineMark.
  ///
  /// In fr, this message translates to:
  /// **'Marquer'**
  String get vaccineMark;

  /// No description provided for @vaccineLinkedMemoryEmoji.
  ///
  /// In fr, this message translates to:
  /// **'Souvenir lié 🌟'**
  String get vaccineLinkedMemoryEmoji;

  /// No description provided for @authPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité & CGU'**
  String get authPrivacyTitle;

  /// No description provided for @authPrivacyHeroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos données nous tiennent à cœur'**
  String get authPrivacyHeroTitle;

  /// No description provided for @authPrivacyLastUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : 1er mars 2026'**
  String get authPrivacyLastUpdated;

  /// No description provided for @authPrivacyPolicyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de Confidentialité'**
  String get authPrivacyPolicyTitle;

  /// No description provided for @authPrivacySection1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Données collectées'**
  String get authPrivacySection1Title;

  /// No description provided for @authPrivacySection1Body.
  ///
  /// In fr, this message translates to:
  /// **'Lorsque vous créez un compte Luckymam, nous collectons :\n\n• Votre nom et adresse e-mail\n• Votre date du terme (grossesse)\n• La date de naissance de votre bébé\n• Les informations relatives à vos enfants (prénom, date de naissance)\n• Les capsules photos et moments de vie que vous choisissez de partager\n• Les données de santé saisies volontairement (vaccins, suivi médical)'**
  String get authPrivacySection1Body;

  /// No description provided for @authPrivacySection2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Utilisation de vos données'**
  String get authPrivacySection2Title;

  /// No description provided for @authPrivacySection2Body.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont utilisées exclusivement pour :\n\n• Vous fournir les fonctionnalités de l\'application (Timeline, Capsules, Vaccins)\n• Personnaliser votre expérience selon votre profil maternel\n• Vous envoyer des rappels et notifications pertinents\n• Améliorer nos services de manière anonyme et agrégée\n\nNous ne vendons ni ne partageons jamais vos données personnelles avec des tiers à des fins commerciales.'**
  String get authPrivacySection2Body;

  /// No description provided for @authPrivacySection3Title.
  ///
  /// In fr, this message translates to:
  /// **'3. Stockage & Sécurité'**
  String get authPrivacySection3Title;

  /// No description provided for @authPrivacySection3Body.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont stockées de manière sécurisée sur des serveurs Firebase (Google Cloud Platform), certifiés ISO 27001 et conformes au RGPD.\n\n• Chiffrement en transit (TLS 1.3) et au repos (AES-256)\n• Accès restreint à votre seul compte via authentification sécurisée\n• Sauvegardes automatiques chiffrées'**
  String get authPrivacySection3Body;

  /// No description provided for @authPrivacySection4Title.
  ///
  /// In fr, this message translates to:
  /// **'4. Vos droits (RGPD)'**
  String get authPrivacySection4Title;

  /// No description provided for @authPrivacySection4Body.
  ///
  /// In fr, this message translates to:
  /// **'Conformément au Règlement Général sur la Protection des Données, vous disposez des droits suivants :\n\n• Droit d\'accès à vos données personnelles\n• Droit de rectification des données inexactes\n• Droit à l\'effacement (« droit à l\'oubli »)\n• Droit à la portabilité de vos données\n• Droit d\'opposition au traitement\n\nPour exercer ces droits : privacy@Luckymam.com'**
  String get authPrivacySection4Body;

  /// No description provided for @authPrivacySection5Title.
  ///
  /// In fr, this message translates to:
  /// **'5. Conservation des données'**
  String get authPrivacySection5Title;

  /// No description provided for @authPrivacySection5Body.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont conservées tant que votre compte est actif. En cas de suppression du compte, toutes vos données personnelles sont effacées dans un délai de 30 jours.\n\nVous pouvez demander la suppression depuis : Profil → Paramètres → Supprimer mon compte.'**
  String get authPrivacySection5Body;

  /// No description provided for @authTermsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'Utilisation'**
  String get authTermsTitle;

  /// No description provided for @authTermsSection1Title.
  ///
  /// In fr, this message translates to:
  /// **'1. Acceptation des conditions'**
  String get authTermsSection1Title;

  /// No description provided for @authTermsSection1Body.
  ///
  /// In fr, this message translates to:
  /// **'En créant un compte et en utilisant l\'application Luckymam, vous acceptez les présentes conditions d\'utilisation dans leur intégralité. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.'**
  String get authTermsSection1Body;

  /// No description provided for @authTermsSection2Title.
  ///
  /// In fr, this message translates to:
  /// **'2. Description du service'**
  String get authTermsSection2Title;

  /// No description provided for @authTermsSection2Body.
  ///
  /// In fr, this message translates to:
  /// **'Luckymam est une application mobile dédiée à accompagner les mamans dans leur parcours de maternité. Elle propose :\n\n• La création et conservation de capsules photo de vie\n• Le suivi de la Timeline des moments importants\n• Le suivi des vaccinations de l\'enfant\n• L\'accès à des Reels éducatifs sur la grossesse et la maternité\n• Des fonctionnalités premium et VIP sur abonnement'**
  String get authTermsSection2Body;

  /// No description provided for @authTermsSection3Title.
  ///
  /// In fr, this message translates to:
  /// **'3. Responsabilités'**
  String get authTermsSection3Title;

  /// No description provided for @authTermsSection3Body.
  ///
  /// In fr, this message translates to:
  /// **'Luckymam n\'est pas un service médical et ne remplace pas l\'avis d\'un professionnel de santé. Les informations fournies (calendrier vaccinal, conseils de grossesse) sont données à titre indicatif uniquement.\n\nVous êtes responsable de la confidentialité de vos identifiants de connexion et de l\'exactitude des informations que vous saisissez.'**
  String get authTermsSection3Body;

  /// No description provided for @authTermsSection4Title.
  ///
  /// In fr, this message translates to:
  /// **'4. Abonnements & Facturation'**
  String get authTermsSection4Title;

  /// No description provided for @authTermsSection4Body.
  ///
  /// In fr, this message translates to:
  /// **'Luckymam propose trois niveaux d\'accès :\n\n• Gratuit : fonctionnalités de base\n• Prémium : 2 490 DA/an — accès à toutes les fonctionnalités avancées\n• VIP : 9 890 DA/an — carte VIP personnalisée + partenaires exclusifs\n\nLes abonnements sont renouvelés automatiquement. Vous pouvez annuler à tout moment depuis votre espace abonnement.'**
  String get authTermsSection4Body;

  /// No description provided for @authTermsSection5Title.
  ///
  /// In fr, this message translates to:
  /// **'5. Modifications'**
  String get authTermsSection5Title;

  /// No description provided for @authTermsSection5Body.
  ///
  /// In fr, this message translates to:
  /// **'Luckymam se réserve le droit de modifier ces conditions à tout moment. Toute modification sera notifiée par e-mail et dans l\'application. L\'utilisation continue de l\'application après notification vaut acceptation des nouvelles conditions.'**
  String get authTermsSection5Body;

  /// No description provided for @authPrivacyQuestionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Des questions ?'**
  String get authPrivacyQuestionsTitle;

  /// No description provided for @authPrivacyContactEmail.
  ///
  /// In fr, this message translates to:
  /// **'Contactez-nous à privacy@Luckymam.com'**
  String get authPrivacyContactEmail;

  /// No description provided for @vaccineDetailProtectsAgainst.
  ///
  /// In fr, this message translates to:
  /// **'Protège contre : {disease}'**
  String vaccineDetailProtectsAgainst(String disease);

  /// No description provided for @vaccineDetailPurposeTitle.
  ///
  /// In fr, this message translates to:
  /// **'À quoi sert ce vaccin ?'**
  String get vaccineDetailPurposeTitle;

  /// No description provided for @vaccineDetailHowItWorks.
  ///
  /// In fr, this message translates to:
  /// **'Comment fonctionne-t-il ?'**
  String get vaccineDetailHowItWorks;

  /// No description provided for @vaccineDetailSideEffects.
  ///
  /// In fr, this message translates to:
  /// **'Effets secondaires possibles'**
  String get vaccineDetailSideEffects;

  /// No description provided for @vaccineDetailFallback.
  ///
  /// In fr, this message translates to:
  /// **'Ce vaccin fait partie du calendrier vaccinal national algérien. Consultez votre pédiatre pour plus d\'informations.'**
  String get vaccineDetailFallback;

  /// No description provided for @vaccineDetailDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations sont à titre éducatif uniquement. Consultez toujours votre médecin ou pédiatre avant toute décision médicale.'**
  String get vaccineDetailDisclaimer;

  /// No description provided for @subscriptionPlanFreeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get subscriptionPlanFreeTitle;

  /// No description provided for @subscriptionPlanFreeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour commencer'**
  String get subscriptionPlanFreeSubtitle;

  /// No description provided for @subscriptionPlanFreeFeatureCapsules.
  ///
  /// In fr, this message translates to:
  /// **'25 capsules maximum'**
  String get subscriptionPlanFreeFeatureCapsules;

  /// No description provided for @subscriptionPlanFreeFeatureChild.
  ///
  /// In fr, this message translates to:
  /// **'1 enfant'**
  String get subscriptionPlanFreeFeatureChild;

  /// No description provided for @subscriptionPlanFreeFeatureMilestones.
  ///
  /// In fr, this message translates to:
  /// **'Jalons de développement'**
  String get subscriptionPlanFreeFeatureMilestones;

  /// No description provided for @subscriptionPlanFreeFeatureVaccines.
  ///
  /// In fr, this message translates to:
  /// **'Vaccinations'**
  String get subscriptionPlanFreeFeatureVaccines;

  /// No description provided for @subscriptionPlanPremiumTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prémium'**
  String get subscriptionPlanPremiumTitle;

  /// No description provided for @subscriptionPlanPremiumSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour les mamans actives'**
  String get subscriptionPlanPremiumSubtitle;

  /// No description provided for @subscriptionPlanPremiumFeatureUnlimitedCapsules.
  ///
  /// In fr, this message translates to:
  /// **'Capsules illimitées'**
  String get subscriptionPlanPremiumFeatureUnlimitedCapsules;

  /// No description provided for @subscriptionPlanPremiumFeatureAllChildren.
  ///
  /// In fr, this message translates to:
  /// **'Tous les enfants'**
  String get subscriptionPlanPremiumFeatureAllChildren;

  /// No description provided for @subscriptionPlanPremiumFeatureMemoryBook.
  ///
  /// In fr, this message translates to:
  /// **'Livre de Mémoires'**
  String get subscriptionPlanPremiumFeatureMemoryBook;

  /// No description provided for @subscriptionPlanPremiumFeatureFullHealth.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de santé complet'**
  String get subscriptionPlanPremiumFeatureFullHealth;

  /// No description provided for @subscriptionPlanPremiumFeatureNoAds.
  ///
  /// In fr, this message translates to:
  /// **'Sans publicités'**
  String get subscriptionPlanPremiumFeatureNoAds;

  /// No description provided for @subscriptionPlanVipTitle.
  ///
  /// In fr, this message translates to:
  /// **'VIP Annuel'**
  String get subscriptionPlanVipTitle;

  /// No description provided for @subscriptionPlanVipSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L\'expérience complète'**
  String get subscriptionPlanVipSubtitle;

  /// No description provided for @subscriptionPlanVipFeatureAllPremium.
  ///
  /// In fr, this message translates to:
  /// **'Tout Prémium inclus'**
  String get subscriptionPlanVipFeatureAllPremium;

  /// No description provided for @subscriptionPlanVipFeatureFreeAlbum.
  ///
  /// In fr, this message translates to:
  /// **'Album imprimé OFFERT 🎁'**
  String get subscriptionPlanVipFeatureFreeAlbum;

  /// No description provided for @subscriptionPlanVipFeaturePrioritySupport.
  ///
  /// In fr, this message translates to:
  /// **'Support prioritaire'**
  String get subscriptionPlanVipFeaturePrioritySupport;

  /// No description provided for @subscriptionPlanVipFeatureVipCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte VIP personnalisée'**
  String get subscriptionPlanVipFeatureVipCard;

  /// No description provided for @subscriptionPlanVipFeaturePartnerCard.
  ///
  /// In fr, this message translates to:
  /// **'Utilisation de la carte VIP avec nos partenaires*'**
  String get subscriptionPlanVipFeaturePartnerCard;

  /// No description provided for @subscriptionPlanBillingPerYear.
  ///
  /// In fr, this message translates to:
  /// **'/an'**
  String get subscriptionPlanBillingPerYear;

  /// No description provided for @subscriptionPlanFreePrice.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get subscriptionPlanFreePrice;

  /// No description provided for @subscriptionPlanPriceDzd.
  ///
  /// In fr, this message translates to:
  /// **'{price} DZD'**
  String subscriptionPlanPriceDzd(int price);

  /// No description provided for @subscriptionSnackUpgradeSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement {tier} activé !'**
  String subscriptionSnackUpgradeSuccess(String tier);

  /// No description provided for @subscriptionSnackAlbumClaimSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Demande d\'album envoyée ! Nous vous contacterons bientôt.'**
  String get subscriptionSnackAlbumClaimSuccess;

  /// No description provided for @subscriptionSnackError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {details}'**
  String subscriptionSnackError(String details);

  /// No description provided for @profileSnackPersonalInfoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Informations mises à jour'**
  String get profileSnackPersonalInfoUpdated;

  /// No description provided for @profileSnackPhotoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil mise à jour'**
  String get profileSnackPhotoUpdated;

  /// No description provided for @profileSnackStatusUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Statut mis à jour'**
  String get profileSnackStatusUpdated;

  /// No description provided for @profileSnackMedicalUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Informations médicales mises à jour'**
  String get profileSnackMedicalUpdated;

  /// No description provided for @profileSnackCycleUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Cycle mis à jour'**
  String get profileSnackCycleUpdated;

  /// No description provided for @profileSnackPeriodLogged.
  ///
  /// In fr, this message translates to:
  /// **'Règles enregistrées'**
  String get profileSnackPeriodLogged;

  /// No description provided for @profileSnackPregnancyLmpSaved.
  ///
  /// In fr, this message translates to:
  /// **'Date de début de grossesse enregistrée'**
  String get profileSnackPregnancyLmpSaved;

  /// No description provided for @profileSnackChildAdded.
  ///
  /// In fr, this message translates to:
  /// **'Enfant ajouté'**
  String get profileSnackChildAdded;

  /// No description provided for @profileSnackChildUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Enfant mis à jour'**
  String get profileSnackChildUpdated;

  /// No description provided for @profileSnackChildDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Enfant supprimé'**
  String get profileSnackChildDeleted;

  /// No description provided for @profileSnackError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {details}'**
  String profileSnackError(String details);

  /// No description provided for @authErrorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Erreur inconnue'**
  String get authErrorUnknown;

  /// No description provided for @authWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue {name} !'**
  String authWelcome(String name);

  /// No description provided for @notifVaccineChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Vaccinations'**
  String get notifVaccineChannelName;

  /// No description provided for @notifVaccineChannelDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de vaccination'**
  String get notifVaccineChannelDesc;

  /// No description provided for @notifMilestoneChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Jalons'**
  String get notifMilestoneChannelName;

  /// No description provided for @notifMilestoneChannelDesc.
  ///
  /// In fr, this message translates to:
  /// **'Alertes étapes de développement'**
  String get notifMilestoneChannelDesc;

  /// No description provided for @notifCycleChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Cycle Féminin'**
  String get notifCycleChannelName;

  /// No description provided for @notifCycleChannelDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rappels du cycle féminin'**
  String get notifCycleChannelDesc;

  /// No description provided for @notifVaccineReminderTitle.
  ///
  /// In fr, this message translates to:
  /// **'💉 Rappel Vaccin – {childName}'**
  String notifVaccineReminderTitle(String childName);

  /// No description provided for @notifVaccineReminderBody.
  ///
  /// In fr, this message translates to:
  /// **'{vaccineLabel} prévu le {date}'**
  String notifVaccineReminderBody(String vaccineLabel, String date);

  /// No description provided for @notifMilestoneUpcomingTitle.
  ///
  /// In fr, this message translates to:
  /// **'⭐ Étape à venir – {childName}'**
  String notifMilestoneUpcomingTitle(String childName);

  /// No description provided for @notifMilestoneUpcomingBody.
  ///
  /// In fr, this message translates to:
  /// **'\"{milestoneTitle}\" dans 7 jours'**
  String notifMilestoneUpcomingBody(String milestoneTitle);

  /// No description provided for @notifMilestoneCustomTitle.
  ///
  /// In fr, this message translates to:
  /// **'⏰ Rappel – {childName}'**
  String notifMilestoneCustomTitle(String childName);

  /// No description provided for @notifMilestoneCustomBody.
  ///
  /// In fr, this message translates to:
  /// **'\"{milestoneTitle}\" — Appuyez pour ouvrir'**
  String notifMilestoneCustomBody(String milestoneTitle);

  /// No description provided for @notifCyclePeriodTitle.
  ///
  /// In fr, this message translates to:
  /// **'🌸 Règles dans 2 jours'**
  String get notifCyclePeriodTitle;

  /// No description provided for @notifCyclePeriodBody.
  ///
  /// In fr, this message translates to:
  /// **'Pensez à vous préparer pour votre prochain cycle.'**
  String get notifCyclePeriodBody;

  /// No description provided for @notifCycleOvulationTitle.
  ///
  /// In fr, this message translates to:
  /// **'🌿 Phase Ovulatoire demain'**
  String get notifCycleOvulationTitle;

  /// No description provided for @notifCycleOvulationBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre période de fertilité maximale commence demain.'**
  String get notifCycleOvulationBody;

  /// No description provided for @profileAgeMonthsOnly.
  ///
  /// In fr, this message translates to:
  /// **'{count} mois'**
  String profileAgeMonthsOnly(int count);

  /// No description provided for @profileAgeYearsOnly.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 an} other{{count} ans}}'**
  String profileAgeYearsOnly(int count);

  /// No description provided for @profileAgeYearsAndMonths.
  ///
  /// In fr, this message translates to:
  /// **'{years, plural, =1{1 an {months} mois} other{{years} ans {months} mois}}'**
  String profileAgeYearsAndMonths(int years, int months);

  /// No description provided for @signupConsentPrefix.
  ///
  /// In fr, this message translates to:
  /// **'En créant un compte, vous nous donnez la permission de stocker en toute sécurité votre date du terme, la date de naissance de votre bébé et toute autre donnée saisie. En continuant, vous acceptez la '**
  String get signupConsentPrefix;

  /// No description provided for @signupConsentPrivacyLink.
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get signupConsentPrivacyLink;

  /// No description provided for @signupConsentAnd.
  ///
  /// In fr, this message translates to:
  /// **' et les '**
  String get signupConsentAnd;

  /// No description provided for @signupConsentTermsLink.
  ///
  /// In fr, this message translates to:
  /// **'conditions d\'utilisation'**
  String get signupConsentTermsLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
