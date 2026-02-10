# Tests parallèles dans Heaven Core

Les tests peuvent être exécutés en parallèle :

- fibres,
- acteurs,
- clusters simulés.

## Objectifs

- rapidité,
- scalabilité,
- couverture.

## Mécanismes

### 1. Scheduling déterministe

Même en parallèle, les tests sont reproductibles.

### 2. Isolation

Chaque test possède :

- ses fibres,
- ses capacités,
- ses régions.

### 3. Distribution

Les tests peuvent utiliser :

- plusieurs nœuds,
- plusieurs clusters,
- plusieurs topologies.

## Visualisation

- timelines,
- heatmaps,
- logs typés.

