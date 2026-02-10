# Sémantique du streaming dans Heaven Core

Le streaming dans Heaven Core est :

- typé,
- frugal,
- potentiellement distribué,
- compatible avec les effets indexés,
- supervisé.

## Modèle de base

Un flux est une structure potentiellement infinie :

```heaven
data Stream a =
  Cons a (Eff s s (Stream a))
  | End

