# Sémantique du streaming dans Astra Core

Le streaming dans Astra Core est :

- typé,
- frugal,
- potentiellement distribué,
- compatible avec les effets indexés,
- supervisé.

## Modèle de base

Un flux est une structure potentiellement infinie :

```astra
data Stream a =
  Cons a (Eff s s (Stream a))
  | End

