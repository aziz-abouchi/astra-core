# Multicast typé dans Heaven Core

Heaven Core supporte le multicast typé pour :

- diffusion,
- consensus,
- streaming.

## Modèle

Un groupe multicast est :

```heaven
data Group p = MkGroup [Channel p]

