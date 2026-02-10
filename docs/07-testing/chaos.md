# Chaos Testing dans Heaven Core

Le chaos testing permet de tester la résilience du système distribué.

## Objectifs

- robustesse,
- tolérance aux pannes,
- stabilité.

## Actions de chaos

- crash de nœud,
- perte de messages,
- duplication de messages,
- latence extrême,
- partitions réseau,
- invalidation de capacités.

## Scénarios

Les scénarios sont typés :

```heaven
scenario : ChaosCap -> Eff s s ()

