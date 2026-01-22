# Règles de typage : dépendants, indexés, linéaires

Ce document esquisse les règles de typage pour :

- les types indexés (e.g. `Vect n a`, `Socket s`),
- les types dépendants simples (Sigma),
- les types linéaires.

## Contexte de typage

On distingue :

- un contexte de termes Γ,
- un contexte de types / indices Δ,
- un contexte de ressources linéaires Λ.

### Variables

- Variables ordinaires : `x : A` dans Γ.
- Variables linéaires : `x ⊸ A` dans Λ (doit être consommée exactement une fois).

## Types indexés

Pour un type `T : I -> Type -> Type` :

- Si `i : I` et `A : Type`, alors `T i A : Type`.

Exemple :

```astra
data Vect : Nat -> Type -> Type where
  VNil  : Vect Z a
  VCons : a -> Vect n a -> Vect (S n) a

