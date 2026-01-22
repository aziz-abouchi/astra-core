# Sémantique d’effacement (Erasure) dans Astra Core

L’effacement garantit que :

- les preuves,
- les indices,
- les raffinements,
- les capacités fantômes,

sont supprimés au runtime.

## Objectifs

- frugalité,
- performance,
- absence de surcharge inutile.

## Éléments effaçables

- preuves,
- indices dépendants,
- types fantômes,
- annotations.

## Éléments non effaçables

- capacités réelles,
- ressources linéaires,
- états de protocole.

## Erasure dépendante

Les indices sont effacés **après** vérification.

## Erasure et distribution

Les valeurs transmises sur le réseau sont :

- compactes,
- normalisées,
- sans preuves.

