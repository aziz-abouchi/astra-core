# Compilateur Astra Core

Le compilateur Astra est conçu comme :

- un **pipeline modulaire**,
- un **backend multiple** (Zig, C, WASM, JS),
- un **pont** avec le proof assistant.

## Pipeline

Étapes principales :

1. **Parsing** → AST brut.
2. **Résolution** → noms, modules, imports.
3. **Typage** → type system (dépendants, linéaires, logique).
4. **Elaboration** → insertion d’annotations, erasure des preuves.
5. **Core IR** → langage intermédiaire minimal.
6. **Optimisations** → inlining, fusion, élimination de preuves.
7. **Backend** → génération Zig/C/WASM/JS.

## Erasure des preuves

Les preuves sont :

- vérifiées au niveau du typechecker,
- effacées dans l’IR (sauf si utilisées pour des optimisations).

## Intégration avec le proof assistant

Le compilateur :

- peut appeler un moteur de preuve externe / interne,
- peut refuser de compiler si certaines obligations ne sont pas prouvées,
- peut générer des obligations de preuve (VCs) à partir du code.

