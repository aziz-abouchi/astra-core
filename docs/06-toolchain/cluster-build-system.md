# Système de build cluster dans Heaven Core

Le build system distribué permet :

- compilation parallèle,
- caching distribué,
- invalidation minimale.

## Fonctionnalités

- compilation multi-nœuds,
- hashing de modules,
- distribution des artefacts,
- supervision.

## Configuration

```toml
[cluster.build]
nodes = 16
cache = true

