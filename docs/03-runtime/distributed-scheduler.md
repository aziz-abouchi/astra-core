# Scheduler distribué d’Astra Core

Le scheduler distribué coordonne l’exécution des fibres à travers plusieurs
nœuds d’un cluster Astra.

## Objectifs

- équilibrage de charge global,
- tolérance aux pannes,
- distribution des branches logiques,
- frugalité (budgets par nœud),
- supervision typée.

## Architecture

Chaque nœud possède :

- un scheduler local (work-stealing),
- une file d’import/export de fibres,
- un superviseur distribué,
- un gestionnaire de capacités distantes.

## Migration de fibres

Une fibre peut être migrée :

- pour équilibrer la charge,
- pour rapprocher les données,
- pour isoler une recherche logique.

La migration transporte :

- l’environnement,
- l’état logique (substitutions),
- les capacités transférables.

## Stratégies

- **Push** : un nœud surchargé pousse des fibres ailleurs.
- **Pull** : un nœud sous-chargé vole des fibres distantes.
- **Sharding logique** : les branches miniKanren sont réparties.

## Déterminisme optionnel

Le scheduler distribué peut fonctionner en mode :

- **nondet** : performance maximale,
- **det** : reproductibilité totale (tests, preuves).

