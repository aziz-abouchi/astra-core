# Sémantique acteurs + logique dans Heaven Core

Heaven Core unifie :

- le modèle d’acteurs,
- la logique relationnelle (miniKanren),
- les capacités,
- la distribution.

## Acteurs logiques

Un acteur peut exécuter des goals logiques :

```heaven
logic : ActorCap p -> Logic a -> Eff s s [a]

## Propriétés
- isolation,
- frugalité,
- supervision.

## Logique distribuée
Les branches logiques peuvent être :

- sharded,
- migrées,
- synchronisées.

## Acteurs + substitutions
Les substitutions sont :

- typées,
- compressées,
- distribuées.

## Visualisation
- arbres logiques distribués,
- heatmaps,
- timelines.
