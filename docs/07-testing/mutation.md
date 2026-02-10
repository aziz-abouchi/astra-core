# Mutation Testing dans Heaven Core

Le mutation testing mesure la robustesse des tests.

## Principe

- générer des mutations du code,
- exécuter les tests,
- vérifier qu’ils échouent.

## Types de mutations

- inversion de conditions,
- suppression de branches,
- modification de constantes,
- altération de protocoles.

## Score de mutation

```text
score = mutants_killed / mutants_total

