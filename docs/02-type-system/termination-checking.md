# Vérification de terminaison dans Heaven Core

Heaven Core garantit que :

- les fonctions terminent,
- les preuves terminent,
- les récursions sont bien fondées.

## Méthodes

### 1. Induction structurée

La méthode par défaut.

### 2. Mesures

```heaven
@[measure size]

