# Détection de pannes dans Heaven Core

La détection de pannes est essentielle pour :

- la supervision,
- la migration,
- la réplication.

## Mécanismes

### 1. Heartbeats typés

Chaque nœud envoie des heartbeats typés.

### 2. Timeouts

Les superviseurs détectent :

- les nœuds silencieux,
- les fibres bloquées.

### 3. Gossip

Propagation rapide des informations.

### 4. Consensus

Les pannes sont intégrées dans les algorithmes de consensus.

## États de panne

- crash,
- partition,
- surcharge,
- latence extrême.

## Visualisation

- graphes de pannes,
- timelines,
- logs.

