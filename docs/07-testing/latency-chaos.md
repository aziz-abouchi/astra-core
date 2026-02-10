# Latency Chaos Testing dans Heaven Core

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

```heaven
injectLatency : Duration -> Eff s s ()

