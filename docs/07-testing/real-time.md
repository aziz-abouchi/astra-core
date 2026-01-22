# Tests temps réel dans Astra Core

Les tests temps réel vérifient :

- les deadlines,
- les priorités,
- les budgets.

## Horloges

- horloge monotone,
- horloge logique,
- horloge virtuelle.

## Tests

### 1. Deadlines

```astra
assertDeadline 5ms (compute x)

