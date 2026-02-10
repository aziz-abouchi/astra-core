# Snapshots distribués dans Heaven Core

Les snapshots distribués permettent :

- la tolérance aux pannes,
- la reprise,
- la simulation,
- le debugging.

## Modèle

Chaque nœud capture :

- ses fibres,
- ses capacités,
- ses régions,
- ses protocoles.

## Snapshot global

Le snapshot global est :

- cohérent,
- typé,
- compressé.

## Algorithme

Inspiré de Chandy–Lamport, mais typé :

1. propagation d’un marqueur,
2. capture locale,
3. synchronisation,
4. agrégation.

## Utilisations

- simulation,
- tests,
- migration,
- reprise.

