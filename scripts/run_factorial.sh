#!/usr/bin/env bash
set -euo pipefail
INPUT=${1:-5}
echo "Running Heaven VM simulation for factorial_tail($INPUT)"
zig build-exe src/vm_extended.zig -O ReleaseSafe -femit-bin=zig-out/bin/heaven-vm-extended ./zig-out/bin/heaven-vm-extended "$INPUT"
