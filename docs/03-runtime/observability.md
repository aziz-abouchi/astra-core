# Observabilité dans Heaven Core

L’observabilité permet :

- de comprendre le runtime,
- de diagnostiquer,
- de superviser,
- d’optimiser.

## Piliers

### 1. Logs typés

Les logs incluent :

- fibres,
- protocoles,
- capacités,
- transitions.

### 2. Traces

Les traces capturent :

- scheduling,
- messages,
- substitutions miniKanren.

### 3. Métriques

- CPU,
- mémoire,
- réseau,
- énergie.

### 4. Événements

Les événements sont typés :

```heaven
data Event = FiberSpawn | FiberExit | MsgSend | MsgRecv | ...

