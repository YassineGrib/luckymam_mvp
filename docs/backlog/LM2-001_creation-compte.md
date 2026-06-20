# LM2-001 — Création de compte

| Champ | Valeur |
|-------|--------|
| **Épic** | Onboarding & Compte |
| **Priorité** | 🔴 Must |
| **Story Points** | 8 |
| **Phase** | M1-M3 |
| **i18n** | FR / AR |
| **Analytics** | `signup_started`, `signup_completed` |

## User Story
En tant qu'utilisatrice, je veux créer un compte (email/tel)

## Description
Compte + vérification OTP + mot de passe fort.

## Critères d'acceptation
```gherkin
Given nouvelle utilisatrice
When je saisis email/tel + mdp fort
Then OTP envoyé et compte créé non-vérifié
```

## Données personnelles
Email / Tel

## Sécurité
Hash mdp + OTP expirable + rate-limit
