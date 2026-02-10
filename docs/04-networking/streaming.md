# Streaming typé dans Heaven Core

Heaven Core supporte le streaming typé pour :

- les flux de données,
- les pipelines,
- les microservices.

## Types de flux

```heaven
data Stream a =
  Cons a (Eff s s (Stream a))
  | End

