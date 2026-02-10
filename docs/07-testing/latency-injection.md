# Injection de latence dans Heaven Core

L’injection de latence permet :

- de tester la résilience,
- de simuler des réseaux réels,
- de valider les protocoles.

## Types de latence

- fixe,
- variable,
- jitter,
- burst.

## API

```heaven
injectLatency : Duration -> Eff s s ()

