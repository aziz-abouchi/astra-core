# Garbage Collection distribué dans Astra Core

Astra Core minimise le GC, mais fournit un GC distribué pour :

- les ressources partagées,
- les capacités distantes,
- les régions migrées.

## Modèle

Chaque nœud :

- collecte localement,
- synchronise les références,
- invalide les ressources mortes.

## Algorithme

- comptage de références typé,
- propagation,
- synchronisation,
- libération.

## Avantages

- frugalité,
- absence de fuite,
- sécurité.

## Visualisation

- graphes de références,
- heatmaps,
- logs.

