# Patterns avancés dans Heaven Core

Heaven Core étend le pattern matching avec :

- des patterns dépendants,
- des patterns sur indices,
- des guards typés,
- des patterns imbriqués,
- des patterns sur preuves.

## Patterns dépendants

Pour les types indexés :

```heaven
case v of
  VNil        => ...
  VCons x xs  => ...

