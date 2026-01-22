# Types raffinés dans Astra Core

Les types raffinés permettent d’exprimer des contraintes logiques sur les
valeurs.

## Syntaxe

```astra
type Positive = { x : Int | x > 0 }

