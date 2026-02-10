# Connection Pooling dans Heaven Core

Le runtime gère un pool de connexions typées.

## Objectifs

- réduire la latence,
- éviter les reconnections,
- optimiser la frugalité.

## Modèle

```heaven
data ConnPool p = ...

