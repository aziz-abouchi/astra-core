# Interruptions dans Heaven Core

Le runtime gère les interruptions pour :

- les timeouts,
- les budgets,
- la supervision,
- les signaux externes.

## Types d’interruptions

### 1. Interruptions temporelles

- expiration de timer,
- dépassement de budget.

### 2. Interruptions logiques

- branche logique abandonnée,
- exploration limitée.

### 3. Interruptions système

- arrêt de fibre,
- migration forcée.

## Gestion

Les interruptions sont :

- typées,
- capturables,
- supervisées.

## Exemple

```heaven
withTimeout 1s (compute x)

