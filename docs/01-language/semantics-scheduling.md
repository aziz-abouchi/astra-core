# Sémantique du scheduling dans Heaven Core

Le scheduling dans Heaven Core est :

- déterministe en mode test,
- frugal en mode production,
- distribué,
- piloté par capacités et budgets.

## Modèle général

Le scheduler gère :

- les fibres,
- les acteurs,
- les effets,
- les transitions de protocole.

## Priorités

- `Low`
- `Normal`
- `High`
- `Critical`

Les priorités influencent :

- l’ordre d’exécution,
- la migration,
- la supervision.

## Budgets

Chaque fibre possède :

- un budget CPU,
- un budget mémoire,
- un budget énergie.

## Scheduling distribué

Les nœuds coopèrent pour :

- équilibrer la charge,
- migrer les fibres,
- respecter les budgets globaux.

## Visualisation

- timelines,
- heatmaps,
- graphes de charge.

