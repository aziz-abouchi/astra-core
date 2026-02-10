# Kinds sécurisés dans Heaven Core

Les kinds sécurisés permettent :

- de classifier les types selon leur niveau de sûreté,
- de contrôler les effets,
- de garantir la frugalité.

## Kinds principaux

- `Data` — valeurs pures,
- `Effect` — effets,
- `Cap` — capacités,
- `Proto` — protocoles,
- `Secure` — types sensibles.

## Sous-typage

Secure <: Data
Cap    <: Effect
Proto  <: Effect

## Kinds dépendants

Les kinds peuvent dépendre :

- d’indices,
- de capacités,
- de régions.

## Distribution

Les kinds sécurisés sont préservés lors de la migration.

