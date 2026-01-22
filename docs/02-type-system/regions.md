# Régions mémoire dans Astra Core

Les régions permettent :

- une gestion mémoire frugale,
- une allocation structurée,
- une libération groupée.

## Définition

```astra
region R in
  let x = alloc R value
  ...
end

