# Sémantique de l’évaluation non déterministe dans Astra Core

Astra Core intègre un modèle non déterministe contrôlé, principalement via :

- la logique relationnelle (miniKanren),
- les effets indexés,
- le scheduling interleavé,
- la distribution.

## Sources de non-déterminisme

### 1. Logique relationnelle

Les goals peuvent produire :

- zéro solution,
- une solution,
- plusieurs solutions,
- une infinité de solutions.

### 2. Scheduling

Le scheduler peut :

- intercaler les branches,
- explorer en largeur ou profondeur,
- respecter les budgets.

### 3. Distribution

Les branches peuvent être :

- sharded,
- migrées,
- parallélisées.

## Contrôle du non-déterminisme

Astra Core garantit :

- absence de divergence non contrôlée,
- budgets logiques,
- exploration déterministe en mode test.

## Effets non déterministes

Les effets logiques sont encapsulés dans :

```astra
Logic a

