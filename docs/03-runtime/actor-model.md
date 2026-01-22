# Modèle d’acteurs dans Astra Core

Astra Core intègre un modèle d’acteurs inspiré d’OTP, mais typé et frugal.

## Acteurs

Un acteur est :

- une fibre supervisée,
- avec une mailbox typée,
- un protocole explicite,
- des capacités associées.

## Définition

```astra
actor Counter =
  state : Nat
  protocol =
    Inc : Counter -> Counter
    Get : Counter -> (Counter, Nat)

