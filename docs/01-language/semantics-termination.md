# Sémantique de la terminaison dans Heaven Core

Heaven Core garantit la terminaison pour :

- les fonctions,
- les preuves,
- les types inductifs,
- les protocoles,
- les transitions d’effets.

## Méthodes de vérification

### 1. Induction structurée
La méthode par défaut, basée sur la structure des données.

### 2. Mesures
Permet de définir une fonction décroissante :

```heaven
@[measure size]

