# Fuzzing dans Heaven Core

Heaven Core inclut un moteur de fuzzing typé.

## Objectifs

- trouver des contre-exemples,
- tester les protocoles,
- tester les IO,
- tester les preuves partielles.

## Générateurs

- types primitifs,
- listes,
- vecteurs,
- arbres,
- valeurs dépendantes.

## Fuzzing logique

Les goals miniKanren peuvent être fuzzés :

- génération de substitutions,
- exploration aléatoire des branches.

## Intégration CI

- fuzzing continu,
- seeds reproductibles,
- rapports automatiques.

