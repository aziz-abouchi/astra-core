# Frugality

## Objectifs
- Langage conscient des ressources.
- Estimation statique avant exécution.

## Ressources
- Temps CPU.
- Mémoire.
- Énergie.

## Exemple
```astra
runWithBudget task { cpu=50ms, mem=128MB, energy=10J }

## Intégration
Refus d’exécution si budget dépassé.
SLA garantis en distribué.
