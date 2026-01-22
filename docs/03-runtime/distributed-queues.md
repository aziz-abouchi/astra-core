# Queues distribuées dans Astra Core

Les queues distribuées permettent :

- la communication inter-nœuds,
- la résilience,
- la frugalité.

## Propriétés

- typées,
- supervisées,
- zero-copy.

## API

```astra
enqueue : QueueCap a -> a -> Eff s s ()
dequeue : QueueCap a -> Eff s s (Maybe a)

