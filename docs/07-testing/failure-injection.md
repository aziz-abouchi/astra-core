# Injection de pannes dans Heaven Core

L’injection de pannes permet :

- de tester la résilience,
- de valider la supervision,
- de simuler des scénarios extrêmes.

## Types de pannes

- crash de fibre,
- crash de nœud,
- perte de messages,
- duplication,
- latence extrême,
- partitions réseau.

## API

```heaven
inject : Failure -> Eff s s ()

