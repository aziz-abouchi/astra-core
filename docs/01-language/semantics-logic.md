# Sémantique de la logique dans Astra Core

Astra Core intègre deux couches logiques :

1. **Logique relationnelle (miniKanren)** — non-déterministe, exploratoire.
2. **Logique propositionnelle (Curry–Howard)** — constructive, prouvable.

## Logique relationnelle

Les goals sont des relations :

- `===` : unification,
- `/\` : conjonction,
- `conde` : disjonction,
- `fresh` : introduction de variables logiques.

### Sémantique

- l’unification produit des substitutions,
- la conjonction compose les substitutions,
- la disjonction explore plusieurs branches,
- le scheduler gère l’interleaving.

### Résultats

Les goals produisent :

- zéro solution,
- une solution,
- une infinité de solutions.

## Logique propositionnelle

Basée sur Curry–Howard :

- `A -> B` : implication,
- `A * B` : conjonction,
- `A + B` : disjonction,
- `Sigma A P` : existentiel,
- `Eq a b` : égalité.

### Sémantique

- les preuves sont des programmes,
- les programmes sont normalisables,
- les preuves sont effacées au runtime.

## Interaction entre les deux logiques

- la logique relationnelle ne peut pas prouver des propositions,
- la logique propositionnelle peut raisonner sur les résultats relationnels,
- les deux sont isolées par les effets.

