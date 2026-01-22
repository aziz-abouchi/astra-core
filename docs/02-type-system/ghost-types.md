# Ghost Types dans Astra Core

Les ghost types permettent d’ajouter des informations au type sans impact runtime.

## Définition

```astra
data Ghost (g : Type) a = MkGhost a

