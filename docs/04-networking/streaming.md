# Streaming typé dans Astra Core

Astra Core supporte le streaming typé pour :

- les flux de données,
- les pipelines,
- les microservices.

## Types de flux

```astra
data Stream a =
  Cons a (Eff s s (Stream a))
  | End

