# Sécurité réseau dans Astra Core

La sécurité est intégrée au modèle de capacités et aux protocoles typés.

## Principes

- pas d’effet sans capacité,
- pas de message hors protocole,
- sérialisation typée,
- isolation des nœuds.

## Authentification

Les capacités distantes peuvent être :

- signées,
- chiffrées,
- limitées dans le temps.

## Autorisation

Les capacités définissent :

- les opérations autorisées,
- les ressources accessibles,
- les limites d’usage.

## Isolation

Chaque nœud :

- exécute les fibres dans un sandbox,
- valide les capacités entrantes,
- vérifie les protocoles.

## Résistance aux attaques

- pas d’injection de messages,
- pas de duplication de capacités,
- pas de bypass de protocole.

