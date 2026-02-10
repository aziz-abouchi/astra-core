# Injection de fautes d’acteurs dans Heaven Core

L’injection de fautes permet :

- de tester la supervision,
- de valider la résilience,
- de simuler des scénarios extrêmes.

## Types de fautes

- crash,
- blocage,
- surcharge,
- latence,
- corruption de message.

## API

```heaven
injectFault : ActorId -> Fault -> Eff s s ()

