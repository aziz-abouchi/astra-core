# Kinds dans Astra Core

Les kinds décrivent la structure des types.

## Kinds de base

- `Type` — type ordinaire,
- `Nat` — kind d’indices naturels,
- `State` — kind d’états de protocoles.

## Kinds fléchés

```astra
Vect : Nat -> Type -> Type

