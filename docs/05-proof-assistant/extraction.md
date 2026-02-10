# Extraction de code dans Heaven Core

Le proof assistant permet d’extraire :

- du code optimisé,
- sans preuves,
- sans indices inutiles.

## Objectifs

- zéro coût,
- intégration avec les backends,
- extraction sûre.

## Processus

1. normalisation des preuves,
2. effacement des preuves,
3. effacement des indices,
4. spécialisation,
5. génération IR.

## Extraction partielle

Certaines preuves peuvent être conservées pour :

- guider l’optimisation,
- vérifier des invariants runtime.

## Extraction vers plusieurs backends

- Zig,
- C,
- WASM,
- JS.

## Garanties

- la sémantique est préservée,
- les invariants sont respectés,
- les preuves ne coûtent rien.

