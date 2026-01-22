# Checkpointing dans Astra Core

Le runtime permet de sauvegarder et restaurer :

- l’état des fibres,
- l’état logique,
- les capacités,
- les protocoles.

## Objectifs

- tolérance aux pannes,
- migration,
- tests déterministes,
- simulation.

## Checkpoints locaux

Chaque fibre peut être checkpointée :

- pile,
- environnement,
- substitutions miniKanren,
- capacités locales.

## Checkpoints distribués

Les nœuds peuvent :

- synchroniser leurs checkpoints,
- restaurer un cluster entier,
- rejouer des scénarios.

## Frugalité

Les checkpoints sont :

- compressés,
- incrémentaux,
- typés.

