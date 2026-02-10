# Phantom Types dans Heaven Core

Les phantom types permettent d’ajouter des informations au type sans coût runtime.

## Définition

```heaven
data Tagged (tag : Type) a = MkTagged a

