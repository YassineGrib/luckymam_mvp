# Rapport — LM2-152 : Assistant Gemini — Cloud Function aiChat et outils

**Date :** 2026-10-22  
**Ticket :** LM2-152  
**Priorité :** Must Have · 13 SP  
**Statut :** ✅ Terminé  

---

## Ce qui a été fait

### 1. Fonction Cloud Serverless v2 `aiChat` (Node.js 20)
Développement de la fonction Firebase Cloud Functions v2 appelable (`onCall`) déployée en région `europe-west1` :
- Authentification Firebase obligatoire (rejet immédiat des requêtes non authentifiées),
- Conservation sécurisée de la clé d'API Google Gemini dans Firebase Secret Manager (`GEMINI_API_KEY`), évitant toute fuite dans les applications mobiles ou les journaux.

### 2. Résilience multi-modèle et bascule automatique
- Séquence de modèles avec réessais exponentiels (sur code 429, 500, 503 ou timeout de 20s) :
  1. `gemini-flash-lite-latest` (rapide et économique),
  2. `gemini-flash-latest` (modèle principal performant),
  3. `gemini-3.8-flash` (repli haute disponibilité).
- Gestion d'erreur utilisateur conviviale évitant l'affichage de codes d'erreur techniques bruts.

### 3. Filtre de sécurité médicale et urgences vitales (Red Flags)
- Interception immédiate des symptômes d'alerte maternelle ou infantile (saignements abondants, absence de mouvements fœtaux, fièvre du nourrisson, détresse respiratoire, convulsions, etc.),
- Aucun appel à l'IA et aucun décompte de quota lors d'une alerte : renvoi direct et instantané vers les urgences médicales et le Samu/Protection Civile (14 / 15).

### 4. Quotas quotidiens selon l'abonnement
- Gestion des quotas journaliers basée sur le fuseau horaire de l'Algérie (`Africa/Algiers` UTC+1) :
  - **Gratuit** : 10 messages / jour,
  - **Premium** : 50 messages / jour,
  - **VIP** : 100 messages / jour.
- Consommation atomique par transaction Firestore (`users/{uid}/aiUsage/{YYYY-MM-DD}`).

### 5. Outils et protection de la vie privée
- Chargement d'un contexte familial anonymisé : pseudonymisation systématique (« enfant 1 », tranche d'âge en mois, semaine gestationnelle) — aucun nom, téléphone ou email n'est transmis à l'IA,
- Respect des situations sensibles (interruption de grossesse récente) : suppression automatique de toute proposition commerciale,
- Outils d'aide à la décision : calendrier vaccinal, recherche de produits par tranche d'âge et compétences, suggestions d'albums et propositions de consultations.

### 6. Intégration Flutter
- Implémentation du service client `GeminiAssistantBackend` utilisant `cloud_functions`,
- Support des environnements de test et démonstration via le flag `ASSISTANT_FAKE` et repli direct `ASSISTANT_DIRECT`.

---

## Déploiement

> **Déploiement : ⏳ À faire — secret `GEMINI_API_KEY` et `firebase deploy --only functions:aiChat` (plan Blaze requis)**

---

## Fichiers créés / modifiés

| Fichier | Changement |
|---------|-----------|
| `functions/ai/gemini.mjs` | Appelant Gemini avec repli multi-modèle et gestion de timeout |
| `functions/ai/redflags.mjs` | Détecteur d'urgences médicales maternelles et néonatales |
| `functions/ai/quota.mjs` | Gestionnaire de quotas quotidiens transactionnel (fuseau Algérie) |
| `functions/ai/tier.mjs` | Évaluation des droits et de la validité de l'abonnement utilisateur |
| `functions/ai/prompt.mjs` | Prompt système pour l'assistante Lucky avec consignes de bienveillance |
| `functions/ai/handler.mjs` | Orchestrateur de discussion et boucle d'exécution d'outils |
| `functions/ai/tools.mjs` | Déclaration et exécution des 8 outils assistants |
| `functions/ai/context.mjs` | Chargement du contexte familial pseudonymisé |
| `functions/ai/aiChat.mjs` | Déclaration de la Cloud Function v2 callable |
| `functions/index.mjs` | Exportation de l'endpoint `aiChat` |
| `lib/features/assistant/services/gemini_assistant_backend.dart` | Client d'appel Flutter avec gestion des exceptions réseau |
| `test/gemini_assistant_backend_test.dart` | 7 tests unitaires Flutter de validation du client |
| `functions/ai/*.test.mjs` | 38 tests unitaires automatisés Node.js réussis |
