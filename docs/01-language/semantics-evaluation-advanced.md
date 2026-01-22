# Sémantique avancée de l’évaluation dans Astra Core

Astra Core combine plusieurs couches d’évaluation :

- évaluation stricte,
- évaluation contrôlée par effets,
- évaluation logique interleavée,
- évaluation distribuée,
- évaluation déterministe en mode test.

## Évaluation stricte

Par défaut :

- les arguments sont évalués avant l’application,
- les valeurs sont immuables,
- les effets sont explicites.

## Évaluation logique

Les goals miniKanren utilisent :

- une évaluation paresseuse,
- une exploration interleavée,
- un scheduler logique.

## Évaluation distribuée

Les expressions peuvent être évaluées :

- localement,
- sur un autre nœud,
- dans un cluster fédéré.

## Évaluation déterministe

En mode test :

- l’ordre des réductions est fixé,
- les effets sont séquencés,
- les transitions sont reproductibles.

## Effacement

Les preuves et indices sont effacés avant exécution.

