# Queues distribuées avancées dans Astra Core

Les queues distribuées avancées permettent :

- la communication inter‑nœuds,
- la résilience,
- la frugalité.

## Propriétés

- typées,
- supervisées,
- zero‑copy.

## API

```astra
enqueue : DistQueueCap a -> a -> Eff s s ()
dequeue : DistQueueCap a -> Eff s s (Maybe a)

## Distribution
Les queues peuvent être :

- sharded,
- répliquées,
- migrées.

## Visualisation
- heatmaps,
- timelines,
- métriques.
