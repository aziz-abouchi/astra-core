# Égalité définitionnelle dans Astra Core

L’égalité définitionnelle est au cœur du proof assistant.

## Définition

Deux termes sont définitionnellement égaux s’ils :

- se réduisent à la même forme normale,
- sont convertibles par β, ι, δ.

## Règles

### β-réduction

```astra
(\x => f x) y  →  f y

