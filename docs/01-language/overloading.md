# Surcharge (Overloading) dans Astra Core

Astra Core supporte une surcharge **statique**, **résolue au typage**, sans coût
runtime.

## Objectifs

- ergonomie,
- zéro coût,
- pas d’ambiguïté,
- pas de résolution dynamique.

## Types de surcharge

### 1. Surcharge par type

```astra
class Eq a where
  (==) : a -> a -> Bool

