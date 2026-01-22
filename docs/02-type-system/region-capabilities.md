# Capacités de région dans Astra Core

Les régions sont contrôlées par des capacités :

- allocation,
- lecture,
- écriture,
- libération.

## Définition

```astra
data RegionCap (r : Region) : Mode -> Type

