// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Luckymam';

  @override
  String get welcomeTitle => 'Bienvenue sur';

  @override
  String get welcomeSubtitle =>
      'Capturez chaque moment précieux de votre maternité';

  @override
  String get getStarted => 'Commencer';

  @override
  String get swipeToGetStarted => 'Glissez pour commencer';

  @override
  String get login => 'Connexion';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get loginTitle => 'Connectez-vous à votre compte';

  @override
  String get loginSubtitle =>
      'Accédez à votre compte pour gérer vos paramètres et explorer les fonctionnalités';

  @override
  String get signUpTitle => 'Créez votre compte';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get or => 'OU';

  @override
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get signInWithApple => 'Continuer avec Apple';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get continueText => 'Continuer';

  @override
  String get errorRequired => 'Ce champ est requis';

  @override
  String get errorInvalidEmail => 'E-mail invalide';

  @override
  String get errorPasswordTooShort =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get errorPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get name => 'Nom complet';

  @override
  String get nameHint => 'Votre nom complet';

  @override
  String get errorNameTooShort => 'Le nom doit contenir au moins 2 caractères';
}
