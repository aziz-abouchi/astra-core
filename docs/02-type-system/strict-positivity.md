# Strict Positivity dans Astra Core

La strict positivité garantit :

- la terminaison,
- la cohérence,
- la sécurité des types inductifs.

## Règle

Un type inductif ne peut référencer son propre type :

- qu’en position strictement positive,
- jamais dans une position négative (argument de fonction).

## Exemple valide

```astra
data List a = Nil | Cons a (List a)

