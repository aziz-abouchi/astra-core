# Energy Chaos Testing dans Heaven Core

Le energy chaos testing permet :

- de tester la frugalité,
- de détecter les pics énergétiques,
- de valider les budgets.

## Types de chaos énergétique

- surcharge CPU,
- surcharge mémoire,
- surcharge réseau,
- latence énergétique,
- oscillations.

## API

```heaven
injectEnergyChaos : NodeId -> Chaos -> Eff s s ()

