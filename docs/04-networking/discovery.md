# Service Discovery dans Heaven Core

Le runtime distribué inclut un système de découverte typé.

## Objectifs

- trouver des services,
- vérifier les protocoles,
- gérer les capacités distantes,
- assurer la frugalité.

## Mécanismes

### 1. Annonces typées

Chaque service annonce :

- son protocole,
- ses capacités,
- ses contraintes.

### 2. Résolution

```heaven
discover : Protocol -> Eff s s (RemoteCap)

