# Stratégies de réécriture dans Astra Core

Le moteur de réécriture supporte plusieurs stratégies.

## Stratégies

### 1. Normalisation complète

- β,
- ι,
- δ.

### 2. Réécriture orientée

- règles `[simp]`,
- équations.

### 3. Réécriture contextuelle

- sous-termes,
- contextes typés.

### 4. Réécriture dépendante

- `subst`,
- `transport`,
- `cong`.

### 5. Réécriture ciblée

```astra
rewriteAt path lemma

