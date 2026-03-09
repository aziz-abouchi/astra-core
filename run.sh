#!/bin/bash

# 1. Nettoyage et Compilation d'Astra
rm -f output/kernel_* ; echo "--- Compilation de la Forge Astra ---"
zig build || exit 1

INPUT="${1:-"(5 * 2) * vec3(1,2,3)"}"
echo "--- ⚡ Lancement de l'Étincelle : $INPUT ---"
./zig-out/bin/astra "$INPUT"

echo "--- Validation de la Flotte ---"

# Fonction utilitaire pour tester un langage
test_lang() {
    local label=$1
    local cmd=$2
    local file=$3
    local run_cmd=$4

    if command -v "$cmd" >/dev/null 2>&1 && [ -f "$file" ]; then
        printf "[%-10s] -> " "$label"
        eval "$run_cmd"
    fi
}

# --- LA MATRICE DE TEST ---

# Interprétés
test_lang "JS"     "node"    "output/kernel.js"    "node output/kernel.js"
test_lang "Python" "python3" "output/kernel.py"    "PYTHONPATH=. python3 output/kernel.py"
test_lang "PHP"    "php"     "output/kernel.php"   "php output/kernel.php"

# Compilés (Natif)
test_lang "C"      "gcc"      "output/kernel.c"    "gcc output/kernel.c -o output/k_c && ./output/k_c"
test_lang "Rust" "rustc" "output/kernel.rs" "rustc output/kernel.rs -o output/k_rs && ./output/k_rs"

# --- SECTION ZIG ---
if [ -f "output/kernel.zig" ]; then
    printf "[Zig       ] -> "
    cp lib/heaven.zig output/ 2>/dev/null
    sed -i 's/\.\.\/lib\/heaven\.zig/heaven\.zig/g' output/kernel.zig
    (cd output && zig run kernel.zig)
fi

# --- SECTION FORTRAN ---
if command -v gfortran >/dev/null 2>&1 && [ -f "output/kernel.f90" ]; then
    printf "[Fortran   ] -> "
    # On entoure l'expression d'un programme minimal si ce n'est pas déjà fait
    gfortran output/kernel.f90 -o output/k_f90 && ./output/k_f90
fi

# --- SECTION WASM (WebAssembly Text) ---
if command -v wat2wasm >/dev/null 2>&1 && [ -f "output/kernel.wat" ]; then
    printf "[Wasm      ] -> "
    if wat2wasm output/kernel.wat -o output/kernel.wasm; then
        node -e "
        const fs = require('fs');
        const wasmBuffer = fs.readFileSync('./output/kernel.wasm');
        // Structure correcte de l'importObject
        const importObject = {
            env: {
                log_f64: (v) => console.log(v),
                log_vec3: (x, y, z) => console.log('[' + x + ',' + y + ',' + z + ']')
            }
        };
        WebAssembly.instantiate(wasmBuffer, importObject).then(obj => {
            obj.instance.exports.main();
        }).catch(err => { console.error(err); process.exit(1); });
        "
    else
        echo "Erreur de compilation WAT"
    fi
fi

# Esotériques & Spécifiques
test_lang "Forth"  "gforth"   "output/kernel.forth" "gforth output/kernel.forth -e 'bye' | tail -n 1"
test_lang "Odin"   "odin"     "output/kernel.odin"  "odin run output/kernel.odin -file"

echo "------------------------------------------"
# Nettoyage des binaires de test
rm -f output/k_* output/heaven.zig
