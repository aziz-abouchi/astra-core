# Sémantique avancée des acteurs dans Astra Core

Astra Core pousse le modèle d’acteurs plus loin grâce à :

- des protocoles typés,
- des capacités linéaires,
- la supervision avancée,
- la distribution native,
- la frugalité.

## États d’acteurs

Chaque acteur possède :

- un état interne typé,
- une mailbox typée,
- un protocole d’évolution.

```astra
actor Counter : State n where
  inc : Msg -> State (S n)
  get : Msg -> (State n, Nat)

