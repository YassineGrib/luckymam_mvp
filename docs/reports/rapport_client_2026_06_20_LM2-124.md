# Rapport — LM2-124 : Grossesse — DPA & Âge Gestationnel

**Date :** 2026-06-20  
**Ticket :** LM2-124  
**Priorité :** Must Have · 8 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Calcul DPA & semaine d'aménorrhée (SA)

Trois méthodes utilitaires ajoutées dans `CycleTrackingSection` :

- **`_pregnancyWeek(lmp)`** : semaine en cours = `(now - lmp).inDays ~/ 7`
- **`_dpa(lmp)`** : date présumée d'accouchement = `lmp + 280 jours`
- **`_daysUntilDpa(lmp)`** : compte à rebours J−XX = `dpa - now`

La base de calcul respecte la règle obstétricale standard (280 jours / 40 semaines à partir de la DDR).

### 2. Affichage en-tête adaptatif

Quand le statut est **ENCEINTE** :
- Le titre passe à **"Ma Grossesse"** (traduit en `My Pregnancy` en anglais / `حملي` en arabe).
- Le sous-titre s'affiche dynamiquement selon la langue active (par exemple: `الأسبوع 12 · الولادة المتوقعة خلال 196 يوم` en arabe / `Week 12 · Due in 196 days` en anglais / `Semaine 12 · DPA dans 196 j` en français).

### 3. Panneau expansible grossesse (`_buildPregnancyContent`)

Tous les textes, descriptions, badges et boutons du panneau s'adaptent dynamiquement à la langue active (FR / AR / EN) :
- **Si DDR non renseignée :**
  - Message explicatif invitant à saisir la DDR (traduit)
  - Bouton d'action `"Entrer ma DDR"` (traduit en `Enter my LMP` / `إدخال تاريخ آخر دورة`)
- **Si DDR connue :**
  - Anneau `CircularProgressIndicator` affichant la semaine courante avec label d'unité (`SA` / `Weeks` / `أسبوع`)
  - Badge **DPA** : formaté selon le modèle `JJ/MM/AAAA`
  - Badge **J−XX** : compte à rebours traduit (ex: `باقي 196 يوم على الولادة` / `196 days left until delivery`)
  - Bouton secondaire de modification (traduit en `Modify my LMP` / `تعديل تاريخ آخر دورة`)

Le style respecte la charte graphique existante : fond `AppColors.primaryGradient`, texte blanc, `GoogleFonts.outfit`, `BorderRadius.circular(18)`.

### 4. Saisie & persistance DDR (`_enterLmp`)

- Réutilise `showDatePicker` avec le même thème rose que le reste de l'app
- Appelle `ref.read(profileActionsProvider.notifier).savePregnancyLmp(date)` pour persister dans Firestore via `CycleInfo.lastPeriodDate`

### 5. Analytics

Trois événements Firebase Analytics :
- `pregnancy_panel_viewed` — à chaque ouverture du panneau grossesse
- `lmp_saved` — à chaque enregistrement de DDR
- `edd_computed` — avec paramètres `edd` (ISO 8601) et `week` courant

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/home/widgets/cycle_tracking_section.dart` | Ajout calculs grossesse, header adaptatif, `_buildPregnancyContent`, `_enterLmp`, analytics |
| `lib/features/profile/services/profile_service.dart` | Ajout `savePregnancyLmp(DateTime)` |
| `lib/features/profile/providers/profile_providers.dart` | Ajout action `savePregnancyLmp` dans `ProfileActionsNotifier` |

---

## Résultat

| Critère | Statut |
|---------|--------|
| DPA calculé à partir DDR (Naegele) | ✅ |
| Semaine d'aménorrhée affichée | ✅ |
| Compte à rebours J−XX | ✅ |
| Saisie DDR si absente | ✅ |
| Persistance Firestore | ✅ |
| Analytics 3 événements | ✅ |
| Style conforme à la charte app | ✅ |
| `flutter analyze` clean | ✅ |
