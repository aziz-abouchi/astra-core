# Chaos Testing d’acteurs dans Astra Core

Le chaos testing permet :

- de tester la résilience,
- de valider la supervision,
- de simuler des scénarios extrêmes.

## Types de chaos

- crash,
- surcharge,
- latence,
- partition,
- duplication de messages.

## API

```astra
injectChaos : ActorId -> Chaos -> Eff s s ()

