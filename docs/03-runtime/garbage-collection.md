# Garbage Collection dans Heaven Core

Heaven Core minimise le GC grâce à :

- l’ownership,
- les régions,
- les buffers linéaires.

## GC régional

Chaque région :

- alloue rapidement,
- libère en bloc,
- évite la fragmentation.

## GC global

Le GC global est :

- compact,
- incrémental,
- frugal.

## GC distribué

Chaque nœud possède son propre GC :

- pas de GC global cluster-wide,
- les migrations transfèrent uniquement les ressources vivantes.

## Optimisations

- zero-copy,
- fusion,
- arènes.

