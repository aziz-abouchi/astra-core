# Routage QoS dans Astra Core

Le routage QoS permet :

- de prioriser les flux,
- de garantir la latence,
- de contrôler la bande passante.

## Paramètres QoS

- priorité,
- latence,
- jitter,
- bande passante.

## Routage typé

```astra
route : NetCap qos -> Msg p -> Eff s s ()

