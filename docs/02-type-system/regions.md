# Régions mémoire dans Heaven Core

Les régions permettent :

- une gestion mémoire frugale,
- une allocation structurée,
- une libération groupée.

## Définition

```heaven
region R in
  let x = alloc R value
  ...
end

