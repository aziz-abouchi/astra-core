# Queues distribuées dans Heaven Core

Les queues distribuées permettent :

- la communication inter-nœuds,
- la résilience,
- la frugalité.

## Propriétés

- typées,
- supervisées,
- zero-copy.

## API

```heaven
enqueue : QueueCap a -> a -> Eff s s ()
dequeue : QueueCap a -> Eff s s (Maybe a)

