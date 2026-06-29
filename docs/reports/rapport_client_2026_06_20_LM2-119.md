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

**Cause :** Le composant `AppLogo` était appelé avec `variant: LogoVariant.vertical`, qui affiche uniquement l'icône SVG sans texte (`showText: false`).

**Correction :** Le `variant` a été changé en `LogoVariant.horizontal`, qui appelle `LuckymamLogo(showText: true)` et affiche l'icône + le texte « Luckymam » côte à côte.

```dart
// Avant
AppLogo(variant: LogoVariant.vertical, size: LogoSize.large)

// Après
AppLogo(variant: LogoVariant.horizontal, size: LogoSize.large)
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
| `lib/features/splash/splash_screen.dart` | `variant: vertical` → `horizontal` · ajout `logSplashShown()` |
| `lib/core/services/analytics_service.dart` | Ajout méthode `logSplashShown()` |
