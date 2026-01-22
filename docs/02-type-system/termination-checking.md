# Vérification de terminaison dans Astra Core

Astra Core garantit que :

- les fonctions terminent,
- les preuves terminent,
- les récursions sont bien fondées.

## Méthodes

### 1. Induction structurée

La méthode par défaut.

### 2. Mesures

```astra
@[measure size]

