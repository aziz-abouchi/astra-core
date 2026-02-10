# Sémantique du FFI distribué dans Heaven Core

Le FFI distribué permet :

- d’appeler du code natif sur d’autres nœuds,
- de transporter des capacités,
- de garantir la sûreté et la frugalité.

## Modèle

Un appel FFI peut être :

- local,
- distant,
- migré.

## Appels distants

```heaven
foreign remote "libmath.so sin"
  sinRemote : NodeId -> Float -> Eff s s Float

