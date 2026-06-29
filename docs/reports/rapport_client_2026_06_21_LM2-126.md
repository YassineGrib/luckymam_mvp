# Rapport — LM2-126 : Raccourci Notifications

**Date :** 2026-06-21  
**Ticket :** LM2-126  
**Priorité :** Should Have · 3 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Icône raccourci dans le hero banner

Un bouton ⚙️ a été ajouté à droite du banner gradient de l'écran Notifications :

- Icône `settings_rounded` dans un container blanc translucide (`Colors.white.withValues(alpha: 0.2)`)
- `Tooltip` : "Paramètres système"
- Style cohérent avec les autres éléments du banner (même `BorderRadius.circular(12)`, même padding)

### 2. Ouverture des paramètres système Android

Au tap, l'app ouvre directement la page de réglages de notifications Android pour l'application (`Settings.ACTION_APP_NOTIFICATION_SETTINGS`).

**Implémentation :**
- Nouveau `MethodChannel('luckymam/settings')` côté Flutter
- `MainActivity.kt` étendu pour gérer l'appel natif et déclencher l'`Intent` Android
- Gestion silencieuse des erreurs (try/catch + `debugPrint`)

### 3. Analytics

Deux événements Firebase Analytics :

- `notif_shortcut_opened` — à chaque tap sur l'icône ⚙️
- `notif_prefs_updated` — à chaque modification d'un toggle de catégorie, avec paramètres :
  - `channel` : `vaccine` | `milestone` | `cycle`
  - `enabled` : `true` | `false`

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/notifications/notifications_screen.dart` | Ajout bouton ⚙️ dans hero, analytics sur toggles |
| `android/app/src/main/kotlin/com/luckmam/luckmam_mvp/MainActivity.kt` | `MethodChannel('luckymam/settings')` + intent `ACTION_APP_NOTIFICATION_SETTINGS` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Icône raccourci visible dans le hero | ✅ |
| Ouvre les paramètres Android au tap | ✅ |
| Style cohérent avec le banner existant | ✅ |
| Analytics `notif_shortcut_opened` | ✅ |
| Analytics `notif_prefs_updated` sur chaque toggle | ✅ |
| `flutter analyze` clean | ✅ |
