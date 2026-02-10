# Caches distribués dans Heaven Core

Heaven Core fournit des caches distribués :

- typés,
- frugaux,
- supervisés.

## Modèle

Un cache distribué est :

- partitionné,
- répliqué,
- cohérent.

## API

```heaven
get : CacheCap k v -> k -> Eff s s (Maybe v)
put : CacheCap k v -> k -> v -> Eff s s ()

