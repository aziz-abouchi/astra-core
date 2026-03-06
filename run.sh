#!/bin/bash
# run.sh - Astra Launcher

echo "Compilation de la forge Astra..."
zig build

if [ $? -eq 0 ]; then
    echo "Compilation réussie."
    echo "Lancement de l'Étincelle Initiale..."
    ./zig-out/bin/astra "$@"
    echo "[GUPI]: Exécution du kernel JavaScript..."
    if command -v node > /dev/null; then
        RESULT_JS=$(node output/kernel.js)
        echo -e "\033[1;32m[JS-Result]: $RESULT_JS\033[0m"
    else
        echo "[!] Node.js non trouvé, exécution JS sautée."
    fi

    # Optionnel : Si tu veux aussi tester le Forth automatiquement
    if command -v gforth > /dev/null; then
       echo "[GUPI]: Exécution du kernel Forth..."
       gforth output/kernel.forth -e "main bye"
    fi
else
    echo "Échec de la forge."
    exit 1
fi
