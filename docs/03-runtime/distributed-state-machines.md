# Machines à états distribuées dans Astra Core

Les machines à états distribuées permettent :

- de modéliser des protocoles,
- de synchroniser des transitions,
- de garantir la cohérence.

## Définition

```astra
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
