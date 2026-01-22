# Scheduling de transport dans Astra Core

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

```astra
send : NetCap qos -> Msg p -> Eff s s ()

