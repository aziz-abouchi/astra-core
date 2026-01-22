# Verrous distribués dans Astra Core

Astra Core fournit des verrous distribués typés pour :

- la coordination,
- la synchronisation,
- la cohérence.

## Modèle

Les verrous sont :

- typés,
- supervisés,
- frugaux.

## API

```astra
acquire : LockCap -> Eff s s LockToken
release : LockToken -> Eff s s ()

