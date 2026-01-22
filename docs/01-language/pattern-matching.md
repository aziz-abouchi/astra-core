# Pattern matching dans Astra Core

Le pattern matching est central dans Astra :

- pour les données algébriques,
- pour les preuves,
- pour les structures indexées.

## Syntaxe de base

```astra
case xs of
  []      => ...
  x :: xs => ...

