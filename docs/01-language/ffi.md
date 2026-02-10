# FFI (Foreign Function Interface) dans Heaven Core

Heaven Core permet d’appeler du code externe de manière sûre et frugale.

## Objectifs

- interopérabilité avec C, Zig, Rust, JS, WASM,
- contrôle des effets via capacités,
- zéro coût d’abstraction.

## Déclaration d’une fonction externe

```heaven
foreign import ccall "math.h sin"
  sin : Float -> Float

