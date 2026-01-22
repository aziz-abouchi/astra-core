# Scheduler global d’Astra Core

Le scheduler d’Astra Core est conçu pour concilier :

- **concurrence massive** (fibres légères),
- **distribution** (nœuds multiples),
- **non-déterminisme contrôlé** (miniKanren),
- **frugalité** (budgets, priorités),
- **déterminisme optionnel** (mode reproductible).

## Modèle de fibres

Une fibre est une unité d’exécution légère :

- pile minimale,
- environnement lexical,
- état logique (pour miniKanren),
- budget de ressources.

Les fibres sont gérées par un pool de workers.

## Work-stealing

Chaque worker possède :

- une deque locale de fibres,
- un mécanisme de vol (steal) pour équilibrer la charge.

Stratégie :

- push local (LIFO),
- steal distant (FIFO),
- priorités ajustées selon le budget restant.

## Classes de tâches

Astra distingue plusieurs classes :

- **Compute** : calcul pur, déterministe.
- **IO** : opérations réseau / disque.
- **Logic** : branches miniKanren.
- **System** : supervision, timers, GC local.

Chaque classe peut avoir :

- une file dédiée,
- une politique de scheduling spécifique.

## Budgets

Chaque fibre possède un budget configurable :

- **steps** : nombre maximal d’étapes,
- **time** : durée maximale,
- **memory** : allocation maximale.

Si un budget est dépassé :

- la fibre est suspendue, tronquée ou terminée,
- un superviseur peut décider d’un restart.

## Mode déterministe

Pour les tests et la vérification :

- scheduling déterministe,
- ordre fixe des fibres,
- exploration logique contrôlée.

Ce mode est activé via une annotation ou un flag.

