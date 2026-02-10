# Sémantique avancée des types quotient dans Heaven Core

Les types quotient permettent de raisonner modulo une relation d’équivalence tout en
préservant :

- la cohérence,
- la normalisation,
- la sécurité du noyau,
- la frugalité.

## Structure générale

```heaven
quotient : (A : Type) -> (R : A -> A -> Prop) -> Type

