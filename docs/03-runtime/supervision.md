# Supervision dans Heaven Core

La supervision est inspirée d’OTP, mais enrichie par les types.

## Objectifs

- tolérance aux pannes,
- isolation,
- frugalité,
- distribution.

## Superviseurs

Un superviseur gère :

- des fibres,
- des acteurs,
- des services distants.

## Stratégies

- `one_for_one`
- `rest_for_one`
- `one_for_all`
- `transient`
- `permanent`

## Arbres de supervision

Les superviseurs forment un arbre :

- racine : superviseur principal,
- branches : services,
- feuilles : fibres.

## Budgets

Les superviseurs peuvent :

- limiter les ressources,
- redémarrer selon des règles,
- migrer des fibres.

## Distribution

Les superviseurs peuvent s’étendre sur plusieurs nœuds.

