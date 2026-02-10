# Chaos Testing d’acteurs dans Heaven Core

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

```heaven
injectChaos : ActorId -> Chaos -> Eff s s ()

