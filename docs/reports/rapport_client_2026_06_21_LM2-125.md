# Rapport — LM2-125 : Graphique Poids — Axe jusqu'à 80 kg

**Date :** 2026-06-21  
**Ticket :** LM2-125  
**Priorité :** Should Have · 3 SP  
**Statut :** ✅ Terminé

---

## Ce qui a été fait

### 1. Axe Y dynamique

L'axe vertical du graphique de poids était figé à `maxY: 25 kg`. Il est maintenant calculé dynamiquement :

- **Plancher minimum garanti : 80 kg** (couvre tous les cas adultes)
- Si les données de l'enfant dépassent 80 kg → le plafond monte à `max_poids × 1,15`, arrondi au 10 kg supérieur
- Intervalle de graduation adaptatif :
  - ≤ 30 kg → graduation tous les **5 kg**
  - ≤ 60 kg → graduation tous les **10 kg**
  - > 60 kg → graduation tous les **20 kg**
- Le label du plafond est masqué pour éviter le chevauchement avec le bord supérieur

### 2. Axe X dynamique

L'axe horizontal était figé à `maxX: 60 mois`. Il s'adapte maintenant à l'âge de l'enfant :

- **Minimum : 60 mois** (affiche toujours la courbe OMS complète 0–5 ans)
- Si l'enfant a plus de 5 ans → l'axe s'étend jusqu'à `âge actuel + 6 mois`, arrondi à 12 mois
- Intervalle X : 6 mois (enfant ≤ 5 ans) / 12 mois (enfant > 5 ans)

### 3. Courbe OMS inchangée

La courbe de référence OMS p50 (garçon/fille, 0–60 mois) reste affichée correctement. Au-delà de 60 mois, seules les données réelles de l'enfant sont tracées.

### 4. Analytics

Événement Firebase Analytics ajouté à l'ouverture de l'écran (premier chargement des données) :

- `weight_chart_viewed` avec paramètres `child_id` et `entry_count`

---

## Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `lib/features/health/widgets/growth_chart_widget.dart` | Axes Y et X dynamiques, intervalles adaptatifs, `_computeMaxY`, `_computeMaxX`, `_yInterval` |
| `lib/features/health/screens/growth_screen.dart` | Import analytics + événement `weight_chart_viewed` au chargement |

---

## Résultat

| Critère | Statut |
|---------|--------|
| Axe Y minimum 80 kg garanti | ✅ |
| Axe Y s'adapte au-delà de 80 kg | ✅ |
| Graduation Y adaptative (5 / 10 / 20 kg) | ✅ |
| Axe X s'adapte à l'âge de l'enfant | ✅ |
| Courbe OMS toujours visible (0–60 mois) | ✅ |
| Aucune valeur tronquée | ✅ |
| Analytics `weight_chart_viewed` | ✅ |
| `flutter analyze` clean | ✅ |
