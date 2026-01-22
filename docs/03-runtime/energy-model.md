# Modèle énergétique du runtime Astra Core

Astra Core intègre un modèle énergétique pour :

- optimiser la frugalité,
- mesurer la consommation,
- guider le scheduling.

## Sources d’énergie

- CPU,
- mémoire,
- réseau,
- stockage.

## Compteurs

Le runtime expose :

- énergie par fibre,
- énergie par protocole,
- énergie par nœud,
- énergie par opération.

## Budgets énergétiques

Les fibres peuvent être limitées :

```astra
@[energy 1000]
compute x

