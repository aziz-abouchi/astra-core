# Tactiques du proof assistant

Astra Core fournit un ensemble minimal mais puissant de tactiques.

## Tactiques de base

- `refl` — prouve `x = x`.
- `sym p` — symétrie.
- `trans p q` — transitivité.
- `cong f p` — congruence.

## Tactiques d’induction

- `induction x` — induction structurée.
- `cases x` — analyse de cas.

## Tactiques avancées

- `rewrite p` — réécrit selon `p`.
- `calc` — chaîne équationnelle.
- `auto` — heuristiques simples.
- `simp` — simplification basée sur des lemmes marqués.

## Tactiques logiques

- `intro` — introduit une hypothèse.
- `apply` — applique un lemme.
- `exists` — construit un `Sigma`.

