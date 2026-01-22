# Métathéorie du proof assistant Astra Core

Ce document résume les propriétés fondamentales du système.

## Propriétés garanties

### 1. **Cohérence**

Il est impossible de prouver `False`.

### 2. **Normalisation forte**

Toutes les preuves terminent.

### 3. **Subject Reduction**

Si `e : T` et `e → e'`, alors `e' : T`.

### 4. **Progress**

Une expression bien typée :

- est une valeur,
- ou peut réduire.

### 5. **Erasure préserve la sémantique**

L’effacement des preuves :

- ne change pas le comportement,
- ne casse pas les invariants.

## Fondations

Le système repose sur :

- un calcul de types dépendants restreint,
- un noyau minimal vérifiable,
- unificateur de Robinson,
- induction structurée.

## Interaction avec la logique relationnelle

Les goals miniKanren :

- ne compromettent pas la cohérence,
- sont isolés dans un effet logique,
- ne peuvent pas prouver des propositions.

