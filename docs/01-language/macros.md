# Macros dans Astra Core

Astra Core inclut un système de macros **hygiéniques**, **typiées** et **zéro‑coût**.

## Objectifs

- étendre la syntaxe,
- générer du code dépendant des types,
- éviter la duplication,
- conserver la sûreté.

## Types de macros

### 1. Macros de syntaxe

Permettent d’introduire de nouveaux motifs syntaxiques :

```astra
macro unless cond body =
  if cond then () else body

