# Bibliothèque de tactiques du proof assistant

Heaven Core fournit une bibliothèque standard de tactiques.

## Tactiques de base

- `intro`
- `apply`
- `rewrite`
- `simp`
- `cases`
- `induction`

## Tactiques avancées

- `calc` — raisonnement équationnel,
- `auto` — heuristiques,
- `have` — lemme intermédiaire,
- `by` — composition de tactiques,
- `contradiction` — détecte les impossibilités,
- `exists` — construit un `Sigma`.

## Tactiques logiques

- `left`, `right` — pour les sommes,
- `split` — pour les produits,
- `exact` — fournit une preuve explicite.

## Extensibilité

Les utilisateurs peuvent définir :

- leurs propres tactiques,
- des tactiques spécialisées pour des domaines,
- des tactiques de réécriture personnalisées.

