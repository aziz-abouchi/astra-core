# Sécurité mémoire dans Heaven Core

Heaven Core garantit la sécurité mémoire via :

- un ownership strict,
- des types linéaires,
- des capacités,
- un modèle d’immutabilité par défaut.

## Pas de data races

Les invariants :

- les données immuables peuvent être partagées librement,
- les données mutables nécessitent une capacité exclusive,
- les ressources linéaires ne peuvent être dupliquées.

## Zones mémoire

- **Heap immuable** : données persistantes, partage sans copie.
- **Heap mutable contrôlé** : accès via capacités.
- **Arenas** : allocations temporaires, libération en bloc.
- **Stack de fibre** : pile légère par fibre.

## Stratégies de sécurité

- vérification statique (ownership, linéarité),
- vérification dynamique optionnelle (mode debug),
- effacement des preuves pour un runtime minimal.

