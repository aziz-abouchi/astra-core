const std = @import("std");
const ast = @import("ast.zig");
const Type = @import("types.zig").Type;

pub const Checker = struct {
    allocator: std.mem.Allocator,
    symbols: std.StringHashMap(Type),

    pub fn init(allocator: std.mem.Allocator) Checker {
        return .{
            .allocator = allocator,
            .symbols = std.StringHashMap(Type).init(allocator),
        };
    }

    pub fn deinit(self: *Checker) void {
        self.symbols.deinit();
    }

    pub fn check(self: *Checker, node: *ast.Node) anyerror!Type {
        const t = try self.resolveType(node);
        node.resolved_type = t;
        return t;
    }

    fn resolveType(self: *Checker, node: *ast.Node) anyerror!Type {
        switch (node.kind) {
            .program => {
                for (node.data.list) |sub| _ = try self.check(sub);
                return .void;
            },
            .constant => return .integer,
            .constant_pi => return .float,
            
            .identifier => {
                const name = node.data.string;
                return self.symbols.get(name) orelse {
                    std.debug.print("Erreur : '{s}' non défini.\n", .{name});
                    return error.UndefinedVariable;
                };
            },

            .forall => {
                const fa = node.data.forall;
                // On check le domaine, même si on ne stocke pas le résultat pour l'instant
                _ = if (fa.domain) |d| try self.check(d) else .domain;
                
                const var_t: Type = .integer;

                // Allocation d'un slice temporaire sur le tas pour sauver le scope
                // fa.vars.len est connu à l'exécution ici.
                const saved_types = try self.allocator.alloc(?Type, fa.vars.len);
                defer self.allocator.free(saved_types);

                for (fa.vars, 0..) |v, i| {
                    const name = v.data.string;
                    saved_types[i] = self.symbols.get(name);
                    try self.symbols.put(name, var_t);
                    v.resolved_type = var_t;
                }

                const body_t = try self.check(fa.body);

                // Restauration de l'état précédent (Pop Scope)
                for (fa.vars, 0..) |v, i| {
                    if (saved_types[i]) |prev| {
                        try self.symbols.put(v.data.string, prev);
                    } else {
                        _ = self.symbols.remove(v.data.string);
                    }
                }

                return body_t;
            },

            .binary, .comparison => {
                const lt = try self.check(node.data.binary.left);
                const rt = try self.check(node.data.binary.right);
                if (node.kind == .comparison) return .boolean;
                return if (lt == .float or rt == .float) .float else .integer;
            },

            .application => {
                for (node.data.apply.args) |arg| _ = try self.check(arg);
                return .float;
            },

            .domain => return .domain,
            .set => return .set,
            else => return .invalid,
        }
    }
};
