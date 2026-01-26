# Quotas de transport dans Astra Core

Les quotas permettent :

- de limiter la bande passante,
- de garantir la frugalité,
- de contrôler les flux.

## Paramètres

- bande passante,
- messages,
- énergie,
- latence.

## API

```astra
withQuota : Quota -> Eff s s a -> Eff s s a

## Visualisation
- courbes,
- heatmaps,
- logs.
