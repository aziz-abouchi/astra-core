# Normalisation dans Astra Core

La normalisation garantit que :

- les preuves terminent,
- les termes ont une forme normale,
- la cohérence est préservée.

## Normalisation forte

Tous les termes du proof assistant :

- réduisent en un nombre fini d’étapes,
- ne peuvent pas diverger.

## Normalisation des preuves

Les preuves sont normalisées avant :

- vérification,
- erasure,
- optimisation.

## Normalisation dépendante

Les termes dépendants sont normalisés pour :

- résoudre les contraintes,
- vérifier les indices,
- simplifier les types.

## Interaction avec miniKanren

La logique relationnelle n’est **pas** normalisée :

- elle peut être infinie,
- elle est gérée par le scheduler,
- elle ne compromet pas la cohérence.

