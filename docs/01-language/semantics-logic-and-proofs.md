# Sémantique : logique, dépendance et preuves

Ce document décrit les briques sémantiques qui sous-tendent :

- la programmation logique (style Prolog / miniKanren),
- les types dépendants et indexés,
- le proof assistant intégré.

## Sous-langage logique

Astra expose un sous-langage logique relationnel, inspiré de miniKanren.

### Primitives

- `fresh (\x, y => goal)` — introduit de nouvelles variables logiques.
- `===` — unification logique.
- `/\` — conjonction de buts.
- `conde [ g1, g2, ... ]` — disjonction (choix non déterministe).

### Sémantique informelle

Un **but** est une relation entre valeurs (potentiellement partielles).  
L’évaluation d’un but produit un **flux de solutions** (potentiellement infini).

- L’unification `t1 === t2` échoue ou produit une substitution.
- `g1 /\ g2` compose les substitutions si possible.
- `conde [g1, g2, ...]` explore les branches de manière interleavée.

Les exemples de `logic_programming.astra` (e.g. `appendo`, `membero`, Sudoku,
N-reines) servent de référence comportementale.

## Types dépendants et indexés

Les types dépendants sont restreints à une forme **pratique** :

- indices finis (e.g. `Nat`, états, labels),
- pas de dépendance arbitraire sur des valeurs runtime non décidables.

### Règle générale

Un type peut être indexé par une valeur d’un type “indice” :

```astra
T : I -> Type -> Type

