# Queues distribuées avancées dans Heaven Core

Les queues distribuées avancées permettent :

- la communication inter‑nœuds,
- la résilience,
- la frugalité.

## Propriétés

- typées,
- supervisées,
- zero‑copy.

## API

```heaven
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
