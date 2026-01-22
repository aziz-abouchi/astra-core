# Polymorphisme de régions dans Astra Core

Le polymorphisme de régions permet :

- la réutilisation de code,
- la frugalité mémoire,
- la sécurité.

## Définition

```astra
f : forall (r : Region). Ref r Int -> Eff s s Int

