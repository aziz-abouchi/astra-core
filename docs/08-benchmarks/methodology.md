# Méthodologie de benchmarks Heaven Core

Les benchmarks d’Heaven Core doivent être :

- reproductibles,
- frugaux,
- multi-backends,
- multi-langages.

## Dimensions mesurées

- temps d’exécution,
- allocations,
- consommation mémoire,
- énergie (si support matériel),
- taille du binaire,
- latence réseau (runtime distribué).

## Protocoles

- warmup contrôlé,
- exécution déterministe optionnelle,
- budgets fixes,
- seeds reproductibles.

## Comparaisons

Heaven peut être comparé à :

- Roc,
- Zig,
- Bun.js,
- PHP,
- Lys,
- Rust.

Les scripts doivent être automatisés.

