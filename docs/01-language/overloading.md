# Surcharge (Overloading) dans Heaven Core

Heaven Core supporte une surcharge **statique**, **résolue au typage**, sans coût
runtime.

## Objectifs

- ergonomie,
- zéro coût,
- pas d’ambiguïté,
- pas de résolution dynamique.

## Types de surcharge

### 1. Surcharge par type

```heaven
class Eq a where
  (==) : a -> a -> Bool

