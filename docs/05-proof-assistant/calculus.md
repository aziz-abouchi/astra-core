# Calculus du proof assistant Astra Core

Le proof assistant repose sur un **calcul minimal** :

- égalité,
- induction structurée,
- combinateurs de preuves.

## Types de base

- `Eq a b` — égalité.
- Connecteurs logiques encodés via types (Curry–Howard) :
  - `A * B` pour la conjonction,
  - `A + B` pour la disjonction,
  - `A -> B` pour l’implication,
  - `Sigma A P` pour l’existentiel.

## Induction

Les types inductifs (e.g. `Nat`, `List a`) viennent avec un principe d’induction :

- généré automatiquement,
- utilisable dans les preuves.

## Règles

- Réflexivité, symétrie, transitivité.
- Congruence.
- Induction structurée.

Le bloc `calc` est une couche syntaxique au-dessus de ces règles.

## Terminaison

Les définitions récursives utilisées dans les preuves doivent :

- être structurées sur un argument décroissant,
- ou être annotées avec une relation bien fondée.

Le proof assistant vérifie (ou fait vérifier) la terminaison.

