# Modèle d’acteurs dans Heaven Core

Heaven Core intègre un modèle d’acteurs inspiré d’OTP, mais typé et frugal.

## Acteurs

Un acteur est :

- une fibre supervisée,
- avec une mailbox typée,
- un protocole explicite,
- des capacités associées.

## Définition

```heaven
actor Counter =
  state : Nat
  protocol =
    Inc : Counter -> Counter
    Get : Counter -> (Counter, Nat)

