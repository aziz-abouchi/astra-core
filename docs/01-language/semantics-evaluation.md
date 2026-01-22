# Sémantique d’évaluation dans Astra Core

Astra Core adopte une sémantique :

- **stricte** par défaut,
- **déterministe** en mode test,
- **effet-indexée** pour les IO et protocoles,
- **non-déterministe contrôlée** pour la logique.

## Stratégie d’évaluation

### Stricte (call-by-value)

- les arguments sont évalués avant l’application,
- les valeurs sont immuables,
- les effets sont séquencés explicitement.

### Exceptions

Les goals miniKanren utilisent une évaluation paresseuse interne :

- exploration interleavée,
- génération progressive des substitutions.

## Ordre d’évaluation

- gauche → droite,
- déterministe sauf dans les effets logiques,
- contrôlé par le scheduler.

## Valeurs

- lambdas,
- constructeurs,
- tuples,
- vecteurs,
- preuves (avant erasure).

## Réduction

La réduction suit :

- les règles du λ-calcul,
- les règles des types dépendants,
- les règles des effets indexés.

## Erasure

Les preuves et indices non nécessaires sont effacés avant exécution.

