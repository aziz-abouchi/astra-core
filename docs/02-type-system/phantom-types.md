# Phantom Types dans Astra Core

Les phantom types permettent d’ajouter des informations au type sans coût runtime.

## Définition

```astra
data Tagged (tag : Type) a = MkTagged a

