# Automatisation des preuves dans Heaven Core

Heaven Core inclut un moteur d’automatisation léger mais puissant.

## Objectifs

- réduire le travail manuel,
- prouver les obligations simples,
- guider les preuves complexes.

## Outils

### 1. `auto`

- propagation d’égalités,
- simplifications,
- résolution de buts simples.

### 2. `simp`

- réécriture automatique,
- utilisation des lemmes `[simp]`.

### 3. `search`

- exploration limitée de l’espace des preuves,
- heuristiques.

### 4. `solve`

- combinaison de `auto`, `simp`, `rewrite`.

## Limites

- pas de recherche profonde,
- pas de backtracking massif,
- pas de logique non constructive.

## Interaction avec miniKanren

Les preuves peuvent utiliser :

- unification,
- recherche logique,
- contraintes.

