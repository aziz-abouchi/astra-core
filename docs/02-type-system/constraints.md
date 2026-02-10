# Contraintes de typage dans Heaven Core

Les contraintes permettent d’exprimer des relations entre types, indices et
valeurs.

## Types de contraintes

- égalité : `a = b`
- inégalités : `n < m`
- contraintes structurelles : `Vect (S n) a`
- contraintes logiques : `P x`

## Résolution

Le typechecker :

- collecte les contraintes,
- les simplifie,
- appelle l’unificateur,
- génère des obligations de preuve si nécessaire.

## Contraintes dépendantes

```heaven
head : Vect (S n) a -> a

