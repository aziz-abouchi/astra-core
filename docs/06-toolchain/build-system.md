# Système de build Heaven Core

Le système de build est :

- incrémental,
- modulaire,
- multi-backends,
- reproductible.

## Étapes

1. parsing,
2. résolution,
3. typage,
4. élaboration,
5. optimisation,
6. génération backend,
7. linking.

## Cache

- cache par module,
- invalidation minimale,
- hash des dépendances.

## Configuration

```toml
[build]
backend = "zig"
opt-level = 3
deterministic = true

