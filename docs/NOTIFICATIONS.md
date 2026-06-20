# 🔔 Notification System — Documentation

> **Last updated:** February 2026  
> **Package:** `flutter_local_notifications` + `timezone`

---

## Overview

The notification system schedules **local** (on-device) reminders — no server needed. It covers three health domains:

| Domain | Channel ID | Lead Time | Time |
|---|---|---|---|
| 💉 Vaccinations | `vaccine_channel` | 2 days before due date | 09:00 |
| ⭐ Milestones | `milestone_channel` | 7 days before due date | 09:00 |
| 🌸 Cycle Féminin | `cycle_channel` | Period D-2 + Ovulation D+12 | 08:00 |

All times are in **Algeria local time** (`Africa/Algiers`, UTC+1, no DST).

---

## Architecture

```
main.dart
  └─ NotificationService.requestPermissions()   ← ask on first launch

User logs period
  └─ logPeriodStart()
        └─ CycleNotificationService.scheduleReminders()
              └─ NotificationService.scheduleCycleReminders()

User opens Timeline tab
  └─ milestoneRemindersProvider(childId)         ← auto-triggered by ref.watch
        └─ MilestoneNotificationService.scheduleAllReminders()
              └─ NotificationService.scheduleMilestoneReminder()

VaccineService.loadVaccines()
  └─ NotificationService.scheduleVaccineReminder()   ← existing flow
```

---

## File Map

| File | Role |
|---|---|
| `lib/core/services/notification_service.dart` | Core service — init, scheduling, cancellation |
| `lib/core/services/cycle_notification_service.dart` | Wraps cycle-specific logic |
| `lib/features/timeline/services/milestone_notification_service.dart` | Wraps milestone logic |
| `lib/features/notifications/notifications_screen.dart` | Settings UI + `NotificationPrefsNotifier` |
| `android/app/src/main/AndroidManifest.xml` | Permissions |

---

## Notification Channels

Three Android channels are registered at init time inside `NotificationService._init()`:

```dart
// Channel IDs (defined as top-level constants)
const _vaccineChannelId   = 'vaccine_channel';
const _milestoneChannelId = 'milestone_channel';
const _cycleChannelId     = 'cycle_channel';
```

Each channel maps to a separate system notification category, allowing users to individually mute them in Android Settings.

---

## Notification ID Strategy

IDs must be unique integers to avoid collisions.

| Type | Formula | Example |
|---|---|---|
| Vaccine | `(childId + groupId).hashCode.abs()` | varies |
| Milestone | `(childId + milestoneId).hashCode.abs()` | varies |
| Period alert | Fixed `10001` | always `10001` |
| Ovulation alert | Fixed `10002` | always `10002` |

Fixed IDs for cycle allow safe re-scheduling — calling `scheduleCycleReminders()` always cancels `10001` and `10002` first.

---

## Scheduling Flow

### Vaccine Reminder
```
dueDate  →  dueDate - 2 days  →  set to 09:00 local  →  zonedSchedule()
```

### Milestone Reminder
```
dueDate  →  dueDate - 7 days  →  set to 09:00 local  →  zonedSchedule()
            ↑ skipped if reminder date has already passed
```

### Cycle Reminders (2 reminders per cycle)
```
lastPeriodDate + 12 days  →  set to 08:00  →  "Phase Ovulatoire demain" (ID 10002)
nextPeriodDate - 2 days   →  set to 08:00  →  "Règles dans 2 jours"     (ID 10001)
            ↑ both skipped if date is in the past
```

---

## Android Permissions

Two permissions are required in `AndroidManifest.xml`:

```xml
<!-- Android 13+ runtime notification permission -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Android 12+ exact alarm permission -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

`requestPermissions()` is called in `main()` before the app UI mounts.

---

## User Preferences

Each channel has an on/off toggle stored in `SharedPreferences`:

| Key | Default |
|---|---|
| `notif_vaccine` | `true` |
| `notif_milestone` | `true` |
| `notif_cycle` | `true` |

**Turning off a channel:**
- Cycle: immediately cancels IDs `10001` and `10002`.
- Vaccine/Milestone: prevents future scheduling (hash-based IDs can't be enumerated to cancel retroactively — existing pending notifications expire naturally).

The UI is at: **Profil → Paramètres → Notifications** or via the **🔔 bell** in the home header.

---

## How to Add a New Reminder Type

1. Add a new channel constant in `notification_service.dart`.
2. Add a typed `scheduleXxxReminder()` method using `_zonedSchedule()`.
3. Create a `XxxNotificationService` wrapper in the relevant feature folder.
4. Wire it into a Riverpod provider that watches the relevant data.
5. Add a toggle in `NotificationsScreen` and `NotificationPrefsNotifier`.
6. Register the channel in Android manifest if a custom sound/importance is needed.

---

## Debugging Tips

Every schedule and cancel logs to the debug console:

```
[Notif] scheduled id=10001 "🌸 Règles dans 2 jours" at 2026-03-14 08:00:00.000+0100
[Notif] cancelNotificationsByChannel: cycle
```

To inspect all pending notifications during development:

```dart
final pending = await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
for (final n in pending) print('${n.id} ${n.title}');
```
