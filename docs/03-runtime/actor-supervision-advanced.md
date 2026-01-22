# Supervision avancée des acteurs dans Astra Core

La supervision avancée permet :

- tolérance aux pannes,
- redémarrage contrôlé,
- propagation typée,
- supervision distribuée.

## Stratégies avancées

### 1. `one_for_each`
Chaque acteur est supervisé individuellement.

### 2. `escalate`
Les erreurs remontent au superviseur parent.

### 3. `budgeted`
Les redémarrages sont limités par un budget.

## Supervision distribuée

Les superviseurs peuvent :

- surveiller plusieurs nœuds,
- migrer des acteurs,
- rééquilibrer la charge.

## États supervisés

Les superviseurs suivent :

- l’état des fibres,
- l’état des protocoles,
- l’état des capacités.

## Visualisation

- arbres de supervision,
- timelines,
- heatmaps.

