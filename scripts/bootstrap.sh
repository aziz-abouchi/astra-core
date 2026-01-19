
#!/usr/bin/env bash
set -euo pipefail

zig build
zig build run -- examples/std.examples.factorial.astra > zig-out/stage1.pretty.astra

zig build-exe src/vm_extended.zig -O ReleaseSafe -femit-bin=zig-out/bin/astra-vm-extended
./zig-out/bin/astra-vm-extended 5

zig build-exe src/llvm_codegen.zig -O ReleaseSafe -femit-bin=zig-out/bin/astra-llvm
# ⬇️ redirection de stderr (2>) car on utilise std.debug.print
./zig-out/bin/astra-llvm 2> zig-out/factorial_tail.ll

echo "Generated LLVM IR at zig-out/factorial_tail.ll"
