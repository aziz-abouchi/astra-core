# Multicast QoS dans Astra Core

Le multicast QoS permet :

- de prioriser les flux,
- de garantir la latence,
- de contrôler la bande passante.

## Paramètres

- priorité,
- latence,
- jitter,
- bande passante.

## API

```astra
multicastQoS : QoS -> Group p -> Msg p -> Eff s s ()

## Visualisation
- heatmaps,
- métriques,
- timelines.
