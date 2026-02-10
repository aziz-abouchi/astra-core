# Capacités de région dans Heaven Core

Les régions sont contrôlées par des capacités :

- allocation,
- lecture,
- écriture,
- libération.

## Définition

```heaven
data RegionCap (r : Region) : Mode -> Type

