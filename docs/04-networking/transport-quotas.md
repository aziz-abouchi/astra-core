# Quotas de transport dans Heaven Core

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

```heaven
withQuota : Quota -> Eff s s a -> Eff s s a

## Visualisation
- courbes,
- heatmaps,
- logs.
