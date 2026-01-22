# Tests distribués dans Astra Core

Astra Core permet de tester des systèmes distribués de manière déterministe.

## Objectifs

- reproductibilité,
- isolation,
- simulation de pannes,
- tests de protocoles typés.

## Mécanismes

### 1. Cluster simulé

Le framework crée :

- plusieurs nœuds virtuels,
- un scheduler distribué déterministe,
- des canaux typés simulés.

### 2. Injection de pannes

- perte de messages,
- crash de nœud,
- invalidation de capacités,
- partitions réseau.

### 3. Assertions typées

```astra
assert (state counter == 42)

