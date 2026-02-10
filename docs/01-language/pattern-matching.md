# Pattern matching dans Heaven Core

Le pattern matching est central dans Heaven :

- pour les données algébriques,
- pour les preuves,
- pour les structures indexées.

## Syntaxe de base

```heaven
case xs of
  []      => ...
  x :: xs => ...

