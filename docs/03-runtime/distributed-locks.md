# Verrous distribués dans Heaven Core

Heaven Core fournit des verrous distribués typés pour :

- la coordination,
- la synchronisation,
- la cohérence.

## Modèle

Les verrous sont :

- typés,
- supervisés,
- frugaux.

## API

```heaven
acquire : LockCap -> Eff s s LockToken
release : LockToken -> Eff s s ()

