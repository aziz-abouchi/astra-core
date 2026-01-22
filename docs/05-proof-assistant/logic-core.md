# Noyau logique du proof assistant

Le proof assistant repose sur un noyau minimal, inspiré de :

- Martin-Löf,
- Curry–Howard,
- miniKanren pour la logique relationnelle.

## Types logiques

- `Eq a b`
- `Sigma A P`
- `A -> B`
- `A * B`
- `A + B`

## Règles fondamentales

- introduction / élimination pour chaque connecteur,
- induction pour les types inductifs,
- égalité définie par `Refl`.

## Unification

Le proof assistant utilise :

- unification de Robinson,
- résolution de contraintes,
- propagation dans les types dépendants.

## Interaction avec le typechecker

Le proof assistant :

- génère des obligations de preuve,
- vérifie les preuves fournies,
- efface les preuves après vérification.

