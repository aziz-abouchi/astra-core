# Sémantique des quotients logiques dans Astra Core

Les quotients logiques unifient :

- la logique relationnelle,
- les types quotient,
- la réécriture modulo équivalences,
- la distribution.

## Quotients logiques

Un quotient logique identifie des branches logiques équivalentes :

```astra
quotLogic : Logic a -> (a -> a -> Prop) -> Logic a

## Propriétés
- élimination contrôlée,
- cohérence,
- normalisation,
- frugalité.

## Réécriture modulo équivalences
Les branches équivalentes sont fusionnées :

- AC,
- arithmétique,
- équivalences structurelles.

## Distribution
Les quotients logiques sont :

- sharded,
- synchronisés,
- compressés.

## Visualisation
- arbres quotientés,
- heatmaps,
- logs.
