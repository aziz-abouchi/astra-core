# Sémantique des types dans Heaven Core

La sémantique des types d’Heaven Core repose sur :

- un noyau dépendant restreint,
- des indices effaçables,
- des capacités,
- des effets indexés,
- des preuves effaçables.

## Types comme invariants

Chaque type encode :

- une forme,
- une contrainte,
- un invariant,
- un protocole,
- un état.

Exemples :

- `Vect n a` encode la taille,
- `Socket s` encode l’état réseau,
- `Eff s1 s2 a` encode une transition d’état,
- `Sigma A P` encode une propriété.

## Types effaçables

Les indices sont effacés sauf si marqués :

```heaven
@[runtime] n

