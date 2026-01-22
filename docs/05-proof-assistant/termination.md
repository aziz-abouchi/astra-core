# Terminaison et récursion bien fondée

Astra Core exige que les fonctions et preuves récursives soient terminantes.

## Méthodes de vérification

### 1. Induction structurée
La forme la plus simple :

- l’argument récursif doit être strictement plus petit,
- vérifié automatiquement.

### 2. Relations bien fondées
Pour les cas complexes :

```astra
measure size

