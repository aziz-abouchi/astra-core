# Benchmark Runner Heaven Core

Le benchmark runner orchestre :

- compilation,
- exécution,
- collecte de métriques,
- visualisation.

## Fonctionnalités

- multi-backends,
- multi-langages,
- seeds reproductibles,
- budgets,
- scénarios distribués.

## Configuration

```toml
[benchmark]
runs = 30
backend = "zig"
deterministic = true

