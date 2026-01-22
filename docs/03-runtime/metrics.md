# Métriques du runtime Astra Core

Le runtime expose des métriques pour :

- la frugalité,
- le profiling,
- la supervision,
- les tests.

## Métriques disponibles

### Fibres

- nombre de fibres actives,
- temps CPU par fibre,
- allocations par fibre,
- profondeur logique.

### Mémoire

- heap utilisée,
- heap maximale,
- allocations par seconde,
- fragmentation.

### Réseau

- messages envoyés/reçus,
- latence,
- bande passante.

### Distribution

- migrations de fibres,
- charge par nœud,
- invalidations de capacités.

## Export

Les métriques peuvent être exportées :

- en JSON,
- en binaire compact,
- vers un dashboard externe.

