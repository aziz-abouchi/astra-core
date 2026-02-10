# Zero-Copy dans Heaven Core

Le runtime optimise les transferts mémoire via :

- zero-copy local,
- zero-copy distribué,
- buffers linéaires,
- régions.

## Zero-copy local

Les structures immuables peuvent être :

- partagées,
- transmises sans copie.

## Zero-copy linéaire

Les buffers linéaires peuvent être :

- déplacés,
- transférés,
- consommés.

## Zero-copy distribué

Les messages peuvent être :

- sérialisés sans copie,
- envoyés directement,
- réhydratés efficacement.

## Avantages

- frugalité,
- performance,
- faible latence.

