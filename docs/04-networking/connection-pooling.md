# Connection Pooling dans Astra Core

Le runtime gère un pool de connexions typées.

## Objectifs

- réduire la latence,
- éviter les reconnections,
- optimiser la frugalité.

## Modèle

```astra
data ConnPool p = ...

