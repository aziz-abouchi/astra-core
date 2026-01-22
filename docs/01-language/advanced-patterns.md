# Patterns avancés dans Astra Core

Astra Core étend le pattern matching avec :

- des patterns dépendants,
- des patterns sur indices,
- des guards typés,
- des patterns imbriqués,
- des patterns sur preuves.

## Patterns dépendants

Pour les types indexés :

```astra
case v of
  VNil        => ...
  VCons x xs  => ...

