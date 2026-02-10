# Sémantique des capacités distribuées dans Heaven Core

Les capacités distribuées permettent :

- de contrôler les effets à distance,
- de garantir la sûreté inter‑nœuds,
- de préserver la frugalité,
- de modéliser des permissions globales.

## Propriétés

- non‑duplicables,
- sérialisables sous conditions,
- migrables,
- supervisées.

## Capacités distantes

```heaven
data DistCap (n : NodeId) (c : Cap) : Type

## Transitions
Les capacités peuvent être :

- transférées,
- invalidées,
- renouvelées.

## Sécurité
- authentification,
- intégrité,
- supervision.

## Visualisation
- graphes de capacités,
- timelines,
- heatmaps.
