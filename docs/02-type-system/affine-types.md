# Types affines dans Heaven Core

Les types affines permettent :

- un usage limité,
- une gestion mémoire frugale,
- une sécurité renforcée.

## Principe

Un type affine peut être utilisé **au plus une fois**, mais pas nécessairement exactement une fois (contrairement aux types linéaires).

## Syntaxe

```heaven
f : Affine Resource -> Result

