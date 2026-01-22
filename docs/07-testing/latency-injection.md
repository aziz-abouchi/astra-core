# Injection de latence dans Astra Core

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

```astra
injectLatency : Duration -> Eff s s ()

