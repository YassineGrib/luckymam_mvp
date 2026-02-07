import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

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
  /// **'Capturez chaque moment précieux de votre maternité'**
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
  /// **'support@luckymam.com'**
  String get emailSupportHint;

  /// No description provided for @sendEmailPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-nous un email à support@luckymam.com'**
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
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
