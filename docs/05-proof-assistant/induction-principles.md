# Principes d’induction dans Heaven Core

Chaque type inductif génère automatiquement un principe d’induction.

## Exemple : Nat

```heaven
inductionNat :
  P Z ->
  (forall n. P n -> P (S n)) ->
  forall n. P n

