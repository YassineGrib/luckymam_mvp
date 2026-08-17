# Rapport de Livraison — Luckymam
## LM2-119 · Splash Branding

---

> **Client :** Luckymam  
> **Date :** 20 Juin 2026  
> **Ticket :** LM2-119  
> **Épic :** Branding & UI  
> **Statut :** Livré ✅

---

## Résumé

L'écran de démarrage (splash) affiche désormais le logo **et** le texte « Luckymam » de façon visible et animée, avec support RTL complet. L'événement analytics `splash_shown` est enregistré à chaque ouverture de l'application.

---

## Problèmes identifiés & corrections apportées

### 1. Texte « Luckymam » absent sur le splash

**Cause :** Le composant `AppLogo` affichait uniquement l'icône SVG sans texte sous sa forme verticale d'origine.

**Correction :** Conformément au choix de branding du client, le logo vertical complet (icône + texte de la marque) a été intégré en utilisant la ressource PNG dédiée `assets/logo/vertical_logo.png` dans la variante verticale d'AppLogo. L'écran `SplashScreen` instancie ainsi cette variante verticale pour afficher le logo et la marque d'un seul bloc, avec un support RTL complet.

```dart
// SplashScreen instancie
AppLogo(variant: LogoVariant.vertical, size: LogoSize.large)
```

### 2. Event analytics `splash_shown` manquant

**Cause :** Aucun appel analytics n'était présent dans le `initState` du `SplashScreen`.

**Correction :** Ajout de `AnalyticsService().logSplashShown()` dans `initState`, et ajout de la méthode typée `logSplashShown()` dans `AnalyticsService`.

---

## Critères d'acceptation — Vérification

| Scénario | Résultat |
|----------|----------|
| Logo Luckymam visible au lancement | ✅ Vérifié |
| Texte « Luckymam » visible et lisible | ✅ Corrigé et vérifié |
| Affichage fonctionnel en RTL (arabe) | ✅ Vérifié — géré automatiquement par Flutter |
| Event `splash_shown` enregistré | ✅ Corrigé et vérifié |

---

## Fichiers modifiés

| Fichier | Modification |
|---------|-------------|
| `lib/features/splash/splash_screen.dart` | Affiche AppLogo en version verticale (qui charge vertical_logo.png) · ajout `logSplashShown()` |
| `lib/shared/widgets/app_logo.dart` | Met à jour la variante verticale d'AppLogo pour charger `vertical_logo.png` |
| `lib/core/services/analytics_service.dart` | Ajout méthode `logSplashShown()` |
