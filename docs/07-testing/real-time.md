# Tests temps réel dans Heaven Core

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

```heaven
assertDeadline 5ms (compute x)

