# Variance dans Astra Core

La variance décrit comment les types réagissent aux sous-types.

## Types de variance

- **Covariance** : `A <: B` implique `F A <: F B`
- **Contravariance** : `A <: B` implique `F B <: F A`
- **Invariance** : pas de relation

## Règles générales

### Fonctions

```text
(A1 -> B1) <: (A2 -> B2)
si A2 <: A1 (contravariant)
et B1 <: B2 (covariant)

