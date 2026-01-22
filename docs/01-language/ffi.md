# FFI (Foreign Function Interface) dans Astra Core

Astra Core permet d’appeler du code externe de manière sûre et frugale.

## Objectifs

- interopérabilité avec C, Zig, Rust, JS, WASM,
- contrôle des effets via capacités,
- zéro coût d’abstraction.

## Déclaration d’une fonction externe

```astra
foreign import ccall "math.h sin"
  sin : Float -> Float

