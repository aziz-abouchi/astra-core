# Sémantique de la concurrence dans Astra Core

Astra Core adopte une sémantique de concurrence :

- **sans partage mutable**,
- **basée sur les fibres**,
- **supervisée**,
- **distribuable**,
- **déterministe en mode test**.

## Fibres

Les fibres sont :

- légères,
- isolées,
- supervisées,
- migrables.

## Communication

La communication se fait via :

- canaux typés,
- protocoles,
- acteurs,
- RPC.

## Absence de data races

Garanties :

- ownership linéaire,
- immutabilité par défaut,
- capacités pour les effets.

## Ordonnancement

Le scheduler :

- intercale les fibres,
- respecte les priorités,
- peut être déterministe,
- peut être distribué.

## Logique concurrente

Les goals miniKanren peuvent être :

- parallélisés,
- sharded,
- interleavés.

