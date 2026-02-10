# Polymorphisme de régions dans Heaven Core

Le polymorphisme de régions permet :

- la réutilisation de code,
- la frugalité mémoire,
- la sécurité.

## Définition

```heaven
f : forall (r : Region). Ref r Int -> Eff s s Int

