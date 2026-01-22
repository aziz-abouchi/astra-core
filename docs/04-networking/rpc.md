# RPC typé dans Astra Core

Astra Core fournit un système RPC typé, basé sur :

- les capacités,
- les protocoles,
- la sérialisation typée.

## Définition d’un service

```astra
service Math =
  add : Int -> Int -> Int
  mul : Int -> Int -> Int

