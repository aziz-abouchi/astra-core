
# scripts/bootstrap_parser.sh
#!/usr/bin/env bash
set -euo pipefail
cd vendor/tree-sitter-astra
# Génération parser C (ABI 15 si tree-sitter.json présent)
tree-sitter generate
# Tests (si corpus présent)
tree-sitter test || true
cd ../..
zig build -Doptimize=ReleaseSafe

