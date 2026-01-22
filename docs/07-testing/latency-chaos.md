# Latency Chaos Testing dans Astra Core

Le latency chaos testing permet :

- de simuler des réseaux réels,
- de tester la résilience,
- de valider les protocoles.

## Types de latence

- fixe,
- jitter,
- burst,
- extrême,
- oscillante.

## API

```astra
injectLatency : Duration -> Eff s s ()

