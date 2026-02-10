# Modes de compilation dans Heaven Core

Heaven Core propose plusieurs modes de compilation.

## Modes

### 1. `debug`

- logs,
- traces,
- assertions.

### 2. `release`

- optimisations,
- erasure,
- fusion.

### 3. `deterministic`

- scheduling fixe,
- transitions contrôlées.

### 4. `distributed`

- compilation multi-nœuds,
- optimisation réseau.

## Configuration

```toml
[build]
mode = "release"

