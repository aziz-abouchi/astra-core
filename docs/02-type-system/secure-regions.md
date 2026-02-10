# Régions sécurisées dans Heaven Core

Les régions sécurisées permettent :

- de contrôler l’accès mémoire,
- de garantir la confidentialité,
- de modéliser des zones sensibles.

## Définition

```heaven
data SecureRegion (lvl : SecurityLevel) : Region

## Propriétés
- isolation,
- chiffrement optionnel,
- capacités linéaires.

## Régions dépendantes
Les régions peuvent dépendre :

- de niveaux de sécurité,
- de capacités,
- de budgets.

## Distribution
Les régions sécurisées peuvent être migrées sous supervision.
