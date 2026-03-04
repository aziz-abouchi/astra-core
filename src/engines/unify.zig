const std = @import("std");
const ast = @import("core");

pub const UnifyError = error{
    MismatchedKinds,
    MismatchedConstants,
    OccursCheckFailed,
    IncompatibleTypes,
};

pub const Unifier = struct {
    allocator: std.mem.Allocator,
    // Stocke les substitutions (ex: n -> 3)
    bindings: std.StringHashMap(*ast.Node),

    pub fn init(allocator: std.mem.Allocator) Unifier {
        return .{
            .allocator = allocator,
            .bindings = std.StringHashMap(*ast.Node).init(allocator),
        };
    }

    pub fn deinit(self: *Unifier) void {
        self.bindings.deinit();
    }

    /// Tente d'unifier deux nœuds de l'AST
    pub fn unify(self: *Unifier, left: *ast.Node, right: *ast.Node) UnifyError!void {
        // 1. Si les deux sont identiques (pointeurs), c't'ast bon.
        if (left == right) return;

        // 2. Logique d'unification par type de nœud
        if (left.kind == .identifier) return try self.bind(left.data.string, right);
        if (right.kind == .identifier) return try self.bind(right.data.string, left);

        if (left.kind != right.kind) return UnifyError.MismatchedKinds;

        switch (left.kind) {
            .constant => {
                if (!std.mem.eql(u8, left.data.string, right.data.string)) 
                    return UnifyError.MismatchedConstants;
            },
            .application => {
                try self.unify(left.data.apply.func, right.data.apply.func);
                try self.unify(left.data.apply.arg, right.data.apply.arg);
            },
            // On ajoutera les autres cas (list_cons, vector_type) ici
            else => return UnifyError.IncompatibleTypes,
        }
    }

    fn bind(self: *Unifier, name: []const u8, node: *ast.Node) UnifyError!void {
        // Ici on devrait vérifier si 'name' n'est pas déjà dans 'bindings'
        // et faire un "occurs check" pour éviter les boucles infinies.
        try self.bindings.put(name, node);
    }
};
