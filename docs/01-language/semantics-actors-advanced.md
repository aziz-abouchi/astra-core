# Sémantique avancée des acteurs dans Heaven Core

Heaven Core pousse le modèle d’acteurs plus loin grâce à :

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

```heaven
actor Counter : State n where
  inc : Msg -> State (S n)
  get : Msg -> (State n, Nat)

