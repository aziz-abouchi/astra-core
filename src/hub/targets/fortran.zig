const std = @import("std");
const ast = @import("../../core/ast.zig");
const Target = @import("../target.zig").Target;

pub const FortranTarget = struct {
    allocator: std.mem.Allocator,
    set_count: usize = 0,
    declarations: std.ArrayListUnmanaged(u8) = .{}, // Stocke les "integer :: ..."

    pub fn init(allocator: std.mem.Allocator) FortranTarget {
        return .{ .allocator = allocator, .declarations = std.ArrayListUnmanaged(u8){}, };
    }

    pub fn deinit(self: *FortranTarget) void {
        self.declarations.deinit(self.allocator);
    }

    pub fn asTarget(self: *FortranTarget) Target {
        return .{
            .ptr = self,
            .emitFn = emitWrapper,
            .deinitFn = deinitWrapper,
        };
    }

    fn emitWrapper(ptr: *anyopaque, node: *ast.Node) anyerror![]const u8 {
        const self: *FortranTarget = @ptrCast(@alignCast(ptr));

        // On nettoie les déclarations précédentes si on réutilise le target
        self.declarations.clearAndFree(self.allocator);
        self.set_count = 0;

        var body = std.ArrayListUnmanaged(u8){};
        defer body.deinit(self.allocator); // Nettoyage auto à la sortie

        try self.emitNode(node, &body);

        // On fusionne : [Déclarations] + \n + [Corps]
        var final = std.ArrayListUnmanaged(u8){};
        try final.appendSlice(self.allocator, self.declarations.items);
        try final.appendSlice(self.allocator, "\n");
        try final.appendSlice(self.allocator, body.items);

        return final.toOwnedSlice(self.allocator);
    }

    fn deinitWrapper(ptr: *anyopaque) void {
        const self: *FortranTarget = @ptrCast(@alignCast(ptr));
        // 1. Libérer le buffer interne de l'ArrayList
        self.declarations.deinit(self.allocator);
        // 2. Libérer la structure elle-même
        self.allocator.destroy(self);
    }

    fn emitNode(self: *FortranTarget, node: *ast.Node, out: *std.ArrayListUnmanaged(u8)) anyerror!void {
        const alloc = self.allocator;
        switch (node.kind) {
            .program => {
                for (node.data.list) |sub| {
                    try self.emitNode(sub, out);
                    try out.appendSlice(alloc, "\n");
                }
            },
            .application => {
                const func_name = node.data.apply.func.data.string;
                const upper_name = try std.ascii.allocUpperString(alloc, func_name);
                defer alloc.free(upper_name);

                try out.writer(alloc).print("{s}(", .{upper_name});
                for (node.data.apply.args, 0..) |arg, i| {
                    if (i > 0) try out.appendSlice(alloc, ", ");
                    try self.emitNode(arg, out);
                }
                
                try out.appendSlice(alloc, ")");
            },
            .access => {
                try self.emitNode(node.data.access.array, out);
                try out.appendSlice(alloc, "(");
                try self.emitNode(node.data.access.index, out);
                try out.appendSlice(alloc, " + 1"); // Décalage automatique Astra -> Fortran
                try out.appendSlice(alloc, ")");
            },
            .forall => {
                const fa = node.data.forall;

                // 1. Enregistrement des déclarations
                // On parcourt les variables pour les déclarer dans le header Fortran
                for (fa.vars) |v| {
                    const type_str = switch (v.resolved_type) {
                        .integer => "integer",
                        .float => "real(8)",
                        else => "integer",
                    };
                    
                    // On écrit "integer :: x" dans le buffer des déclarations
                    const decl_writer = self.declarations.writer(alloc);
                    try decl_writer.print("{s} :: {s}\n", .{type_str, v.data.string});
                }

                // 2. Génération des boucles (ta logique existante)
                // --- CAS : DOMAINES CLASSIQUES ---
                for (fa.vars) |variable| {
                    try out.appendSlice(alloc, "do ");
                    try self.emitNode(variable, out);
                    try out.appendSlice(alloc, " = ");
                
                    if (fa.domain) |dom| {
                        if (std.mem.eql(u8, dom.data.string, "ℕ*")) {
                            try out.appendSlice(alloc, "1, N");
                        } else if (std.mem.eql(u8, dom.data.string, "ℕ")) {
                            try out.appendSlice(alloc, "0, N");
                        } else {
                            try out.appendSlice(alloc, "1, ");
                            try self.emitNode(dom, out);
                        }
                    } else {
                        try out.appendSlice(alloc, "1, N");
                    }
                    try out.appendSlice(alloc, "\n  ");
                }

                try self.emitNode(fa.body, out);

                // On ferme toutes les boucles
                for (fa.vars) |_| {
                    try out.appendSlice(alloc, "\nend do");
                }
            },
            .factorial => {
                try out.appendSlice(alloc, "factorial(");
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, ")");
            },
            .comparison => {
                try self.emitNode(node.data.binary.left, out);
                const op = switch (node.data.binary.op) {
                    .geq => " .GE. ",
                    .leq => " .LE. ",
                    .equal => " .EQ. ",
                    else => " == ",
                };
                try out.appendSlice(alloc, op);
                try self.emitNode(node.data.binary.right, out);
            },
            .constant, .identifier => try out.appendSlice(alloc, node.data.string),
            .abs => {
                try out.appendSlice(alloc, "ABS(");
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, ")");
            },
            .negation => {
                try out.appendSlice(alloc, "-");
                try self.emitNode(node.data.unary, out);
            },
            .constant_pi => try out.appendSlice(alloc, "3.14159265358979323846_8"),
            else => {},
        }
    }
};
