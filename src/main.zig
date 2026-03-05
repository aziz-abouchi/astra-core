const std = @import("std");
const core = @import("core/ast.zig");
const Unifier = @import("core/unify.zig");
const LatexFrontend = @import("core/frontends/latex.zig");
const HeavenTarget = @import("hub/targets/heaven.zig");
const ForthTarget = @import("hub/targets/forth.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 1. INPUT : Lecture d'une source LaTeX
    const source_tex = "\\forall x \\in \\mathbb{N}^* : x! \\geq 1";
    var frontend = LatexFrontend.init(allocator);
    const ast_root = try frontend.parse(source_tex);

    // 2. BRAIN : Unification et Inférence de domaines
    var unifier = Unifier.init(allocator);
    try unifier.verifyConstraints(ast_root); 
    // Ici, le système "comprend" que x est un entier positif.

    // 3. MULTI-TARGET : Projection vers les cibles
    
    // Vers HEAVEN (Documentation simplifiée)
    var heaven_target = HeavenTarget.init(allocator);
    const heaven_code = try heaven_target.project(ast_root);
    std.debug.print("Heaven Output: {s}\n", .{heaven_code});

    // Vers FORTH (Calcul haute performance / Embarqué)
    var forth_target = ForthTarget.init(allocator);
    const forth_code = try forth_target.project(ast_root);
    std.debug.print("Forth Output: {s}\n", .{forth_code});
}
