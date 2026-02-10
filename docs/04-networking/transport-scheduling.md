# Scheduling de transport dans Heaven Core

Le scheduling réseau permet :

- d’optimiser la latence,
- de garantir la QoS,
- de réduire la consommation.

## Paramètres

- priorité,
- bande passante,
- latence,
- jitter.

## Scheduling typé

```heaven
send : NetCap qos -> Msg p -> Eff s s ()

