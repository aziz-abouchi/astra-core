# Formatter Astra Core

Le formatter garantit un style cohérent et lisible.

## Objectifs

- lisibilité,
- cohérence,
- intégration LSP,
- zéro configuration par défaut.

## Règles

- indentation à 2 espaces,
- lignes courtes,
- alignement des `=>`,
- alignement des `=` dans les preuves,
- formatage des blocs `calc`.

## Exemple

```astra
calc
  x + 0
    ={ plusZeroRight x }=
  x
  QED

