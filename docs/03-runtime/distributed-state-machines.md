# Machines à états distribuées dans Heaven Core

Les machines à états distribuées permettent :

- de modéliser des protocoles,
- de synchroniser des transitions,
- de garantir la cohérence.

## Définition

```heaven
data DStateMachine p = ...

## Propriétés
- transitions typées,
- supervision,
- frugalité.

## Distribution
Les machines peuvent être :

- migrées,
- répliquées,
- supervisées.

## Visualisation
- graphes d’états,
- timelines,
- heatmaps.
