# Effets sécurisés dans Astra Core

Les effets sécurisés garantissent :

- la confidentialité,
- l’intégrité,
- la supervision.

## Syntaxe

```astra
Eff (secure = k) s1 s2 a

## Propriétés
- isolation,
- chiffrement,
- contrôle des capacités.

## Effets dépendants
Les effets sécurisés peuvent dépendre :

- d’indices,
- de capacités,
- de régions.

## Distribution
Les effets sécurisés sont préservés lors de la migration.
