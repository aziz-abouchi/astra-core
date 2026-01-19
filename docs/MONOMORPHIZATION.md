Monomorphization (MVP)
Exemple: factorial_tail : Nat -> Nat

Pas de paramètre type: déjà monomorphe.
Génération IR LLVM directe (zig-out/factorial_tail.ll).
Exemple polymorphe: contains : forall a . [Eq a] => a -> List a -> Bool

Solveur résout [Eq a] pour a = Nat ➜ spécialisation contains_Nat : Nat -> List Nat -> Bool.
Codegen LLVM générera une version spécialisée (zero‑cost, sans dicos runtime).
