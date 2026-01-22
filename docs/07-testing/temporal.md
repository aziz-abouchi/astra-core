# Tests temporels dans Astra Core

Les tests temporels vérifient :

- les timeouts,
- les délais,
- les budgets,
- les timers.

## Mécanismes

### 1. Horloges simulées

- horloge logique,
- horloge virtuelle.

### 2. Timers typés

```astra
withTimeout : Duration -> Eff s s a -> Eff s s (Maybe a)

