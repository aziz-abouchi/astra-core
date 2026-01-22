# Modèle mémoire d’Astra Core

Le modèle mémoire d’Astra Core vise :

- la **sécurité** (pas de data races),
- la **prédictibilité** (comportement déterministe optionnel),
- la **frugalité** (contrôle fin des allocations).

## Segments mémoire

Le runtime distingue :

- **heap** : données partagées, gérées par le runtime,
- **stack de fibre** : pile légère par fibre,
- **zones éphémères** : allocations temporaires (arenas, bump allocators).

## Propriété de non-partage dangereux

Les types linéaires et l’ownership garantissent :

- pas de mutation concurrente non typée,
- pas de partage non contrôlé de ressources mutables.

Les données immuables peuvent être partagées librement.

## Gestion mémoire

Stratégies possibles (configurables) :

- **GC régional / par fibre**,
- **arenas** pour phases de calcul,
- **référence comptée** pour certains objets.

Le modèle exact peut varier par backend (Zig, C, WASM), mais les invariants
typiques restent les mêmes.

## Frugalité

Le runtime expose :

- des compteurs d’allocations,
- des budgets mémoire par fibre / acteur,
- des profils de consommation.

Ces informations peuvent être exploitées par le type system (annotations,
contrats) et par les outils (profiler).

