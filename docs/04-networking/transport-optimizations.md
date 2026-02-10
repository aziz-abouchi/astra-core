# Optimisations de transport dans Heaven Core

Le runtime optimise les transports réseau via :

- zero-copy,
- batching,
- compression,
- multiplexage.

## Zero-copy

Les buffers linéaires sont envoyés sans copie.

## Batching

Les messages peuvent être regroupés :

- par protocole,
- par priorité,
- par QoS.

## Compression typée

Les messages peuvent être compressés selon leur structure.

## Multiplexage

Plusieurs flux peuvent partager une même connexion.

## Visualisation

- métriques,
- heatmaps,
- timelines.

