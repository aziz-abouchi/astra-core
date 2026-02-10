# Tests basés sur les propriétés (Property-Based Testing)

Heaven Core inclut un framework de tests génératifs.

## Principe

Au lieu d’exemples :

- on définit une propriété,
- le framework génère des cas,
- il cherche un contre-exemple minimal.

## Syntaxe

```heaven
property reverseReverse xs =
  reverse (reverse xs) == xs

