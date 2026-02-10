# Optimiseur Heaven Core

L’optimiseur transforme le Core IR en code frugal et performant.

## Passes principales

### 1. Inlining

- fonctions petites,
- preuves effacées,
- wrappers de capacités.

### 2. Fusion

- fusion de maps,
- fusion de folds,
- élimination des intermédiaires.

### 3. Spécialisation

- fonctions dépendantes,
- protocoles typés,
- vecteurs dimensionnés.

### 4. Dead Code Elimination

- preuves,
- branches impossibles,
- indices effacés.

### 5. Allocation sinking

- déplace les allocations vers les branches nécessaires,
- réduit la pression mémoire.

## Backends

Chaque backend peut ajouter :

- passes spécifiques,
- optimisations mémoire,
- stratégies de GC.

