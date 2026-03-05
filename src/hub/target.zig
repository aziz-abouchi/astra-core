const std = @import("std");
const ast = @import("../core/ast.zig");

/// Interface générique pour les générateurs de code (backends).
/// Utilise le pattern "Type Erasure" pour permettre au Projector de manipuler 
/// n'importe quelle cible sans connaître son type concret.
pub const Target = struct {
    /// Pointeur opaque vers l'instance concrète (ex: *FortranTarget)
    ptr: *anyopaque,

    /// Fonction de génération : prend le pointeur opaque et l'AST, renvoie le code.
    emitFn: *const fn (ptr: *anyopaque, node: *ast.Node) anyerror![]const u8,

    /// Fonction de nettoyage : libère la mémoire allouée pour l'instance du Target.
    deinitFn: *const fn (ptr: *anyopaque) void,
};
