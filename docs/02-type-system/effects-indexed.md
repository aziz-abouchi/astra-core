# Effets indexés dans Heaven Core

Les effets indexés permettent de suivre l’évolution d’un état dans les types.

## Syntaxe

```heaven
data Eff : State -> State -> Type -> Type where
  Pure : a -> Eff s s a
  Bind : Eff s1 s2 a -> (a -> Eff s2 s3 b) -> Eff s1 s3 b

