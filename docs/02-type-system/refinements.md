# Types raffinés dans Heaven Core

Les types raffinés permettent d’exprimer des contraintes logiques sur les
valeurs.

## Syntaxe

```heaven
type Positive = { x : Int | x > 0 }

