# Rapport — LM2-131 : Rappels Jalons

**Date :** 2026-06-21  
**Ticket :** LM2-131  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Bouton « Programmer un rappel » sur le détail du jalon

Un bouton pleine largeur a été ajouté dans `MilestoneDetailScreen`, entre le bouton "Conseils" et les actions secondaires :

- **Aucun rappel programmé** → bouton bleu "Programmer un rappel" (icône cloche)
- **Rappel actif** → bouton vert affichant "Rappel le d MMM à HH:mm" (icône cloche pleine), qui ouvre la fiche pour le modifier ou l'annuler
- L'état est lu en direct via un provider Riverpod (`milestoneReminderProvider`), donc le bouton se met à jour immédiatement après programmation/annulation

### 2. Bottom sheet de planification

Une fiche s'ouvre au tap avec :
- **3 raccourcis rapides** : Demain 9h, Dans 3 jours 9h, Dans 1 semaine 9h
- **« Le jour du jalon »** — n'apparaît que si la date prévue du jalon est connue et future
- **« Choisir une date et heure »** — sélecteur manuel (date + heure) via les pickers natifs Android
- **« Annuler le rappel »** — visible uniquement si un rappel est déjà programmé

Chaque option programme la notification et affiche une confirmation ("Rappel programmé le … ✓").

### 3. Programmation exacte de la notification

Contrairement au rappel automatique existant (7 jours avant un jalon, fixé à 9h), ce nouveau rappel est programmé à la **date et l'heure exactes choisies par la maman**, via une nouvelle méthode `scheduleMilestoneCustomReminder()` dans `NotificationService`. Il utilise un identifiant distinct du rappel automatique — les deux peuvent coexister sans se remplacer.

**Rate limiting :** reprogrammer un rappel pour le même jalon remplace automatiquement le précédent (même identifiant stable) — impossible d'empiler plusieurs rappels pour un même jalon.

**Opt-in :** si les notifications de jalons sont désactivées dans Profil → Notifications, la programmation est bloquée avec un message explicite renvoyant vers les réglages.

### 4. Deep link vers le jalon

Le payload de la notification transporte `childId` + `milestoneId` (JSON). Au tap sur la notification :

- **App en premier ou arrière-plan** → écoute directe via `NotificationService.onNotificationTapped`
- **App fermée (cold start)** → détection via `getNotificationAppLaunchDetails()` au démarrage
- L'app navigue automatiquement sur `MilestoneDetailScreen` du bon jalon, avec toutes ses données à jour (capsule liée, statut, etc.)

**Validation du deep link (sécurité) :** le payload est décodé et vérifié avant toute navigation — type de notification, `milestoneId` existant dans la base des 70 jalons, `childId` appartenant bien à l'utilisateur connecté. Tout payload malformé ou invalide est silencieusement ignoré.

### 5. Analytics

- `milestone_reminder_set` — à la programmation, avec `milestone_id` + `scheduled_for`
- `milestone_reminder_fired` — au moment où la notification tapée est reçue par l'app *(note technique : les notifications locales n'ont pas de mécanisme de accusé de réception à la livraison — cet événement est donc mesuré au moment de l'interaction, comme c'est l'usage standard pour ce type de notification)*
- `milestone_reminder_opened` — après navigation réussie vers le jalon

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/core/services/notification_service.dart` | `onNotificationTapped` (ValueNotifier statique), `getLaunchPayload()`, `scheduleMilestoneCustomReminder()` avec payload JSON |
| `lib/features/timeline/services/milestone_notification_service.dart` | `scheduleCustomReminder()`, `getCustomReminder()`, `cancelCustomReminder()`, provider `milestoneReminderProvider` |
| `lib/core/router/app_router.dart` | `navigatorKey` global pour navigation hors contexte (deep link) |
| `lib/main.dart` | `LuckymamApp` converti en `ConsumerStatefulWidget` ; gestion du deep link (tap direct + cold start), validation, navigation, analytics |
| `lib/features/timeline/screens/milestone_detail_screen.dart` | Bouton "Rappel", bottom sheet `_ReminderSheet` (raccourcis + sélection manuelle + annulation), widgets `_ReminderTile`, `_ReminderPreset` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Bouton "Rappel" visible sur chaque jalon | ✅ |
| Programmation à date/heure précise | ✅ |
| Raccourcis rapides (demain, 3j, 1 semaine, jour du jalon) | ✅ |
| Sélecteur manuel date + heure | ✅ |
| Annulation d'un rappel programmé | ✅ |
| Notification reçue à l'heure prévue | ✅ |
| Tap sur la notification → ouverture directe du jalon | ✅ |
| Deep link fonctionne app ouverte, arrière-plan et fermée | ✅ |
| Validation des deep links (payload malformé ignoré) | ✅ |
| Opt-in requis (respecte le toggle Notifications jalons) | ✅ |
| Rate limiting (un seul rappel actif par jalon) | ✅ |
| Analytics `milestone_reminder_set` | ✅ |
| Analytics `milestone_reminder_fired` | ✅ |
| Analytics `milestone_reminder_opened` | ✅ |
| `flutter analyze` clean (0 nouveaux problèmes) | ✅ |

---

## Note technique — hors périmètre de ce ticket

`flutter analyze` sur l'ensemble du projet révèle 5 erreurs pré-existantes dans `lib/core/theme/app_theme.dart` (lignes 97-99), présentes depuis le commit initial du projet et sans lien avec ce ticket. Elles n'affectent aucun fichier modifié aujourd'hui. À traiter séparément si besoin.
