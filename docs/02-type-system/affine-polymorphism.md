# Polymorphisme affine dans Heaven Core

Le polymorphisme affine permet :

- de contrôler l’usage des ressources,
- de garantir la frugalité,
- de modéliser des effets optionnels.

## Syntaxe

```heaven
f : forall (a : Type). Affine a -> Eff s s ()

