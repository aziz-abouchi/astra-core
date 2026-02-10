# Load Balancing dans Heaven Core

Le runtime distribué inclut un système de répartition de charge typé.

## Objectifs

- équilibrer les fibres,
- répartir les branches logiques,
- optimiser la frugalité,
- respecter les capacités.

## Stratégies

### 1. Round-robin typé

- chaque nœud reçoit une fibre selon son type,
- utile pour les protocoles homogènes.

### 2. Least-loaded

- mesure des fibres actives,
- mesure des budgets consommés.

### 3. Sharding logique

- les branches miniKanren sont réparties,
- chaque nœud explore une partie de l’espace de recherche.

### 4. Affinité de données

- les fibres sont envoyées vers les nœuds possédant les données pertinentes.

## Supervision

Les superviseurs peuvent :

- migrer des fibres,
- rééquilibrer dynamiquement,
- isoler des nœuds saturés.

