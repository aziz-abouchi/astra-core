Heaven IR (MVP) — src/ir.zig
Cet IR intermédiaire (MIR) sert de base à la monomorphisation et à la génération LLVM IR.

Concepts
Type: I64, Bool, PtrI64
Value: constantes (i64, bool), variables (%vN)
Instr: Alloca, Store, Load, Mul, Sub, IcmpEq, Phi, Br, Ret
Block: label + liste d’instructions
Function: nom, args, type retour, vecteur de blocks
Factorial Tail IR
Construit par build_factorial_tail_ir(alloc) avec 4 blocs : entry, loop, body, exit.

Prochaine étape
Brancher src/llvm_codegen.zig sur ir.Function pour émettre le LLVM IR depuis l’IR.
Étendre l’IR pour inclure Let, App, Match.
