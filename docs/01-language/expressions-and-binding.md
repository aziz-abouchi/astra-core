# Expressions, portée et liaison

Astra Core adopte un modèle lexical simple et prévisible.

## Liaison

- Les variables sont liées lexicalement.
- Les lambdas introduisent des portées.
- Les `let` sont des liaisons locales non récursives.
- Les `let rec` permettent la récursion mutuelle.

## Expressions

- application : `f x y`
- lambda : `\x, y => expr`
- let : `let x = e1 in e2`
- case : `case e of { ... }`
- tuples : `(x, y)`
- listes : `[x, y, z]`

## Évaluation

- stratégie : **évaluation stricte** par défaut,
- exceptions : certains effets logiques peuvent être paresseux (miniKanren),
- déterminisme optionnel via un mode de compilation.

