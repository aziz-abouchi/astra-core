# Transpilation

## Objectifs
- Astra pivot de transpilation bidirectionnelle.
- Source → Astra → C/LLVM/WASM/BEAM/JVM/JS.
- C/LLVM/WASM/BEAM/JVM/JS → Astra.

## Architecture
- Frontend Astra : parser + typechecker.
- IR interne Astra.
- Backends multiples.
- Importers FFI.

## Exemple
```astra
foreign c "math.h" {
  sin : Double -> Double
}

