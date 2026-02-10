# RPC typé dans Heaven Core

Heaven Core fournit un système RPC typé, basé sur :

- les capacités,
- les protocoles,
- la sérialisation typée.

## Définition d’un service

```heaven
service Math =
  add : Int -> Int -> Int
  mul : Int -> Int -> Int

