# Compilation incrémentale dans Astra Core

La compilation incrémentale permet :

- des builds rapides,
- une invalidation minimale,
- une reproductibilité totale.

## Mécanismes

### 1. Cache par module

Chaque module possède :

- un hash de contenu,
- un hash de dépendances.

### 2. Invalidation minimale

Seuls les modules dépendants sont recompilés.

### 3. Compilation parallèle

Les modules indépendants sont compilés simultanément.

## Visualisation

- graphes de dépendances,
- temps de compilation,
- invalidations.

