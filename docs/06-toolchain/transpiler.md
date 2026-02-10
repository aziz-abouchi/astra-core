# Transpiler Heaven Core

Le transpiler convertit le Core IR vers :

- Zig,
- C,
- WASM,
- JavaScript.

## Objectifs

- frugalité,
- portabilité,
- performance,
- simplicité d’intégration.

## Pipeline

1. IR → IR optimisé
2. IR → backend spécifique
3. génération de code
4. linking

## Backend Zig

- idéal pour la frugalité,
- contrôle mémoire fin,
- intégration avec les capacités.

## Backend WASM

- sandboxing,
- portabilité web,
- GC optionnel.

## Backend JS

- mode debug,
- prototypage rapide.

