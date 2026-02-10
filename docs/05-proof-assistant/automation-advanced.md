# Automatisation avancée dans Heaven Core

Le proof assistant inclut des outils avancés d’automatisation.

## Outils

### 1. `auto*`
Version étendue de `auto` :

- propagation profonde,
- réécriture multiple,
- heuristiques.

### 2. `simp*`
Simplification agressive :

- normalisation,
- réécriture contextuelle,
- élimination de preuves triviales.

### 3. `search-depth`
Recherche limitée en profondeur.

### 4. `solve-by`
Combinaison de tactiques :

```heaven
solve-by [simp, auto, rewrite]

