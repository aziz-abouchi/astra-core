# Égalité définitionnelle dans Heaven Core

L’égalité définitionnelle est au cœur du proof assistant.

## Définition

Deux termes sont définitionnellement égaux s’ils :

- se réduisent à la même forme normale,
- sont convertibles par β, ι, δ.

## Règles

### β-réduction

```heaven
(\x => f x) y  →  f y

