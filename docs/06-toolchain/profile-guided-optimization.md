# Optimisation guidée par profil (PGO) dans Astra Core

Le toolchain supporte la PGO pour :

- optimiser les hot paths,
- réduire la latence,
- améliorer la frugalité.

## Étapes

### 1. Instrumentation

Le code est compilé avec instrumentation.

### 2. Exécution

Les benchmarks collectent :

- fréquences,
- latences,
- allocations.

### 3. Optimisation

Le compilateur :

- inline,
- fusionne,
- réorganise.

## Visualisation

- graphes,
- statistiques,
- heatmaps.

