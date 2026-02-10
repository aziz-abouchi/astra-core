# Ghost Types dans Heaven Core

Les ghost types permettent d’ajouter des informations au type sans impact runtime.

## Définition

```heaven
data Ghost (g : Type) a = MkGhost a

