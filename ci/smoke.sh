#!/usr/bin/env bash
set -euo pipefail

zig test src/eqsat/tests/test_lexer.zig
zig test src/eqsat/tests/test_sexpr.zig
zig test src/eqsat/tests/test_pattern.zig
zig test src/eqsat/tests/test_matcher.zig
zig test src/eqsat/tests/test_apply_rule.zig
zig test src/eqsat/tests/test_rebuilder.zig
zig test src/eqsat/tests/test_extractor.zig
zig test src/eqsat/eqsat_pass.zig

zig build-exe src/eqsat/examples/extraction_example.zig
./extraction_example | tee /tmp/extraction.out

diff -u rules/goldens/extraction_example.golden /tmp/extraction.out

zig build -Deqsat=true -Drelease-fast
