# Orchestrateur de benchmarks Heaven Core

L’orchestrateur permet :

- d’exécuter des benchmarks complexes,
- de gérer plusieurs nœuds,
- de collecter les métriques.

## Fonctionnalités

- scénarios distribués,
- seeds reproductibles,
- multi-backends,
- multi-langages.

## Configuration

```toml
[orchestrator]
nodes = 8
scenario = "distributed_pingpong"

