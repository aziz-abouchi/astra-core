const std = @import("std");
const ast = @import("../../core/ast.zig");
const Target = @import("../target.zig").Target;

pub const ForthTarget = struct {
    allocator: std.mem.Allocator,
    variables: std.StringHashMap(void),

    pub fn init(allocator: std.mem.Allocator) ForthTarget {
        return .{ .allocator = allocator, .variables = std.StringHashMap(void).init(allocator), };
    }

    pub fn asTarget(self: *ForthTarget) Target {
        return .{ .ptr = self, .emitFn = emitWrapper, .deinitFn = deinitWrapper };
    }

    fn emitWrapper(ptr: *anyopaque, node: *ast.Node) anyerror![]const u8 {
        const self: *ForthTarget = @ptrCast(@alignCast(ptr));

        // 1. Nettoyage automatique des variables collectées
        defer self.variables.clearAndFree();

        var body_out = std.ArrayListUnmanaged(u8){};
        defer body_out.deinit(self.allocator);

        var header_out = std.ArrayListUnmanaged(u8){};
        errdefer {
            body_out.deinit(self.allocator);
            header_out.deinit(self.allocator);
        }
        
        // 1. Première passe : on émet le corps (ceci remplit self.variables)
        try self.emitNode(node, &body_out);
        
        // 2. Génération du Header (déclarations Forth)
        var it = self.variables.keyIterator();
        while (it.next()) |var_name| {
            try header_out.appendSlice(self.allocator, "variable ");
            try header_out.appendSlice(self.allocator, var_name.*);
            try header_out.appendSlice(self.allocator, "\n");
        }
        
        // 3. Fusion Header + Body
        try header_out.appendSlice(self.allocator, body_out.items);
        return header_out.toOwnedSlice(self.allocator);
    }

    fn deinitWrapper(ptr: *anyopaque) void {
        const self: *ForthTarget = @ptrCast(@alignCast(ptr));
        self.variables.deinit();
        self.allocator.destroy(self);
    }

    // Dans le cas .application ou .comparison
    // Si un argument est Float et l'autre est Integer, on doit promouvoir l'Integer
    fn emitWithPromotion(self: *ForthTarget, node: *ast.Node, target_is_float: bool) !void {
        try self.emitNode(node, &self.buffer);

        // Si le nœud est un entier mais qu'on est dans un contexte flottant :
        if (target_is_float and node.resolved_type == .integer) {
            try self.buffer.appendSlice(self.allocator, " s>f ");
        } else {
            try self.buffer.appendSlice(self.allocator, " ");
        }
    }


    fn emitNode(self: *ForthTarget, node: *ast.Node, out: *std.ArrayListUnmanaged(u8)) anyerror!void {
        const alloc = self.allocator;
        switch (node.kind) {
            .identifier => {
                try out.appendSlice(alloc, node.data.string);
                // On choisit l'opérateur de lecture selon le type résolu
                const op = if (node.resolved_type == .float) " f@ " else " @ ";
                try out.appendSlice(alloc, op);
            },

            .application => {
                const func_name = node.data.apply.func.data.string;
                
                // On émet les arguments (ils s'empileront sur la pile respective)
                for (node.data.apply.args) |arg| {
                    try self.emitNode(arg, out);
                }

                // Dispatch pour max
                if (std.mem.eql(u8, func_name, "max")) {
                    const op = if (node.resolved_type == .float) "fmax " else "max ";
                    try out.appendSlice(alloc, op);
                } else {
                    try out.appendSlice(alloc, func_name);
                    try out.appendSlice(alloc, " ");
                }
            },

            .comparison => {
                try self.emitNode(node.data.binary.left, out);
                try self.emitNode(node.data.binary.right, out);

                // Les comparaisons flottantes en Forth finissent souvent par 'f' (ex: f>=)
                const is_float = (node.data.binary.left.resolved_type == .float or 
                                 node.data.binary.right.resolved_type == .float);

                const op = switch (node.data.binary.op) {
                    .geq => if (is_float) "f>= " else ">= ",
                    .leq => if (is_float) "f<= " else "<= ",
                    .equal => if (is_float) "f= " else "= ",
                    else => "== ",
                };
                try out.appendSlice(alloc, op);
            },
            .program => {
                for (node.data.list) |sub| {
                    try self.emitNode(sub, out);
                    try out.appendSlice(alloc, " ");
                }
            },
            .forall => {
                const fa = node.data.forall;

                // 1. Déclarer les variables au début si nécessaire 
                // (Ou s'assurer qu'elles sont déclarées ailleurs)

                // 2. Générer les boucles imbriquées
                for (fa.vars) |variable| {
                    // On suppose un domaine par défaut 0..N pour Forth ici
                    try out.appendSlice(alloc, "N 0 do ");

                    // On assigne l'index de boucle 'i' à la variable nommée
                    try out.writer(alloc).print("i {s} ! ", .{variable.data.string});
                }

                // 3. Le corps de la boucle
                try self.emitNode(fa.body, out);

                // 4. Fermer les boucles
                for (fa.vars) |_| {
                    try out.appendSlice(alloc, " loop ");
                }
            },
            .factorial => {
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, " FACT");
            },
            .constant => try out.appendSlice(alloc, node.data.string),
            .access => {
                try self.emitNode(node.data.access.array, out);
                try out.appendSlice(alloc, " ");
                try self.emitNode(node.data.access.index, out);
                try out.appendSlice(alloc, " CELLS + @");
            },
            .abs => {
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, " ABS"); // Le mot 'ABS' existe en Forth standard
            },
            .negation => {
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, " NEGATE");
            },
            .constant_pi => try out.appendSlice(alloc, " FPI"), // Ou 3.14159e si pas de constante
            else => {},
        }
    }
};
