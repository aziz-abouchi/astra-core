# Transpilation

## Objectifs
- Heaven pivot de transpilation bidirectionnelle.
- Source → Heaven → C/LLVM/WASM/BEAM/JVM/JS.
- C/LLVM/WASM/BEAM/JVM/JS → Heaven.

## Architecture
- Frontend Heaven : parser + typechecker.
- IR interne Heaven.
- Backends multiples.
- Importers FFI.

## Exemple
```heaven
foreign c "math.h" {
  sin : Double -> Double
}

