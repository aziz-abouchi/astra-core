# Sous-typage d’ownership dans Heaven Core

Le sous-typage d’ownership permet :

- de modéliser la perte de permissions,
- de garantir la frugalité,
- d’éviter les duplications.

## Hiérarchie
Owned  <: Borrowed
Borrowed <: ReadOnly

## Règles

### 1. Perte de permissions
On peut toujours affaiblir :

```heaven
Owned a -> Borrowed a
Borrowed a -> ReadOnly a

