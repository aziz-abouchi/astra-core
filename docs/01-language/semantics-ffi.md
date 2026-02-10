# Sémantique FFI avancée dans Heaven Core

Le FFI d’Heaven Core est conçu pour être :

- sûr,
- frugal,
- typé,
- compatible avec les capacités,
- compatible avec la distribution.

## Objectifs

- interopérer avec C, Zig, Rust, JS, WASM,
- garantir l’absence d’UB,
- préserver les invariants du type system,
- éviter les copies inutiles.

## Déclaration

```heaven
foreign import ccall "math.h sin"
  sin : Float -> Float

