# Pureté, effets et séparation logique

Heaven Core distingue trois catégories :

1. **Pur** : aucune interaction avec le monde extérieur.
2. **Effets contrôlés** : via capacités.
3. **Logique** : non-déterminisme, unification, recherche.

## Pureté

Une fonction pure :

- ne lit ni n’écrit d’état,
- ne fait pas d’IO,
- ne dépend que de ses arguments.

Le compilateur peut :

- optimiser agressivement,
- réordonner,
- fusionner.

## Effets contrôlés

Les effets nécessitent une capacité :

```heaven
readFile : FileCap -> Path -> String

