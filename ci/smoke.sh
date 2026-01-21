#!/usr/bin/env bash
set -euo pipefail

zig test src/eqsat/eqsat_pass.zig
zig build
./zig-out/bin/extraction_example | tee /tmp/extraction.out
diff -u rules/goldens/extraction_example.golden /tmp/extraction.out || true
