# Multicast typé dans Astra Core

Astra Core supporte le multicast typé pour :

- diffusion,
- consensus,
- streaming.

## Modèle

Un groupe multicast est :

```astra
data Group p = MkGroup [Channel p]

