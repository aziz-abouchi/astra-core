#!/bin/bash

# --- CONFIGURATION ---
OUTPUT_DIR="output"
mkdir -p $OUTPUT_DIR

# 1. Compilation d'Astra
echo "--- Compilation d'Astra-Core ---"
zig build || exit 1

# 2. Compilation du moteur WASM pour l'interface (optionnel mais recommandé)
zig build-lib src/forge/wasm.zig -target wasm32-freestanding -dynamic -rdynamic --name astra_engine 2>/dev/null

# 3. Récupération de l'input
INPUT="${1:-"tests/facto.hvn"}"

echo "--- Lancement de l'Intelligence Astra (Génération) ---"
# Premier passage : on génère les fichiers kernel.*
# On ne met PAS --serve ici pour que ça ne bloque pas les tests
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
test_lang "JS"      "node"    "output/kernel.js"    "node output/kernel.js"
test_lang "Python"  "python3" "output/kernel.py"    "PYTHONPATH=. python3 output/kernel.py"
test_lang "PHP"     "php"     "output/kernel.php"   "php output/kernel.php"
test_lang "C"       "gcc"     "output/kernel.c"     "gcc output/kernel.c -o output/k_c && ./output/k_c"
test_lang "Rust"    "rustc"   "output/kernel.rs"    "rustc output/kernel.rs -o output/k_rs && ./output/k_rs"

# Section Zig
if [ -f "output/kernel.zig" ]; then
    printf "[Zig       ] -> "
    cp lib/heaven.zig output/ 2>/dev/null
    sed -i 's/\.\.\/lib\/heaven\.zig/heaven\.zig/g' output/kernel.zig
    (cd output && zig run kernel.zig)
fi

# Section Fortran
if command -v gfortran >/dev/null 2>&1 && [ -f "output/kernel.f90" ]; then
    printf "[Fortran   ] -> "
    gfortran output/kernel.f90 -o output/k_f90 && ./output/k_f90
fi

# Section Wasm (Node.js runtime)
if command -v wat2wasm >/dev/null 2>&1 && [ -f "output/kernel.wat" ]; then
    printf "[Wasm      ] -> "
    if wat2wasm output/kernel.wat -o output/kernel.wasm; then
        node -e "
        const fs = require('fs');
        const wasmBuffer = fs.readFileSync('./output/kernel.wasm');
        const importObject = { env: { 
            log_f64: (v) => console.log(v),
            log_vec3: (x, y, z) => console.log('[' + x + ',' + y + ',' + z + ']')
        }};
        WebAssembly.instantiate(wasmBuffer, importObject).then(obj => obj.instance.exports.main());
        "
    fi
fi

# Esotériques
test_lang "Forth" "gforth" "output/kernel.forth" "gforth output/kernel.forth -e 'bye' | tail -n 1"

# --- GESTION DU VISUALISEUR ---
# Si l'argument --serve est détecté dans la commande initiale
if [[ "$*" == *"--serve"* ]]; then
    echo ""
    echo "------------------------------------------------"
    echo "Lancement du Visualiseur Astra (Mode Interactif)"
    echo "URL: http://localhost:8080"
    echo "------------------------------------------------"
    
    # On relance Astra au PREMIER PLAN. 
    # Ton main.zig bloquera proprement sur le read(0)
    ./zig-out/bin/astra "$INPUT" --serve
fi

# Nettoyage
rm -f output/k_*
echo "--- Fin de mission Astra ---"
