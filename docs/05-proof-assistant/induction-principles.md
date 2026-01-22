# Principes d’induction dans Astra Core

Chaque type inductif génère automatiquement un principe d’induction.

## Exemple : Nat

```astra
inductionNat :
  P Z ->
  (forall n. P n -> P (S n)) ->
  forall n. P n

