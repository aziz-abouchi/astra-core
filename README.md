# Astra Core

**Astra** est un langage de programmation et un écosystème massivement concurrent, parallèle et distribué.  
Ce dépôt `astra-core` constitue le noyau du langage : compilateur, runtime, bibliothèque standard et outils.

## Objectifs
- Modèle de concurrence et de distribution natif (acteurs, MPST, libp2p).
- Sécurité mémoire via QTT et capabilités inspirées de Pony/Goblins.
- Auto‑hébergement : écrit en Astra lui‑même, avec un bootstrap initial en Zig.
- Abstractions zéro‑cost : aucune surcharge inutile au runtime.
- Pivot universel pour la transpilation bidirectionnelle (C, LLVM, WASM, BEAM, JVM, JS).
- Proof assistant intégré et workflow type‑driven development.
- Automatisation des tests (QuickCheck et dérivés).
- Frugalité : estimation et gestion des budgets de ressources (temps, mémoire, CPU, énergie).

## Structure
- `compiler/` : compilateur Astra (Zig d’abord, puis Astra).
- `runtime/` : scheduler, mémoire, IO, primitives de concurrence.
- `std/` : bibliothèque standard (types de base, collections, concurrence, distribué).
- `docs/` : spécifications du langage, modèles mémoire, types, réseau, transpilation, etc.
- `examples/` : programmes exemples en Astra.
- `tools/` : CLI, formatteur, linter.
- `tests/` : tests unitaires et de propriétés.

# Astra v4.1.1 (Zig 0.15.2)

- build.zig: createModule + root_module (API 0.15.x)
- Tree-sitter: grammar avec `field(...)` + `tree-sitter.json` (ABI 15)
- queries: `locals.scm` & `tags.scm` synchronisées (version **avec champs**)
- src/parser.c: **placeholder** (générer via `tree-sitter generate`)
- Golden runner stable (sans sous-processus), plugin VSCode, exemples HM

## Build
zig build -Doptimize=ReleaseSafe

## Générer le parser Tree-sitter
cd vendor/tree-sitter-astra
# (nécessite Node pour `generate`)  
tree-sitter generate
# (optionnel, nécessite `cc`)  
tree-sitter test
cd ../..
zig build -Doptimize=ReleaseSafe

## Licence
MIT (modifiable selon les besoins).
