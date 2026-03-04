const std = @import("std");
const core = @import("core");
const ast = core.ast; 

pub const Projector = struct {
    allocator: std.mem.Allocator,
    indent_level: u32 = 0,

    pub fn init(allocator: std.mem.Allocator) Projector {
        return .{ .allocator = allocator };
    }

    fn writeIndent(self: *Projector, out: *std.ArrayListUnmanaged(u8)) !void {
        var i: u32 = 0;
        while (i < self.indent_level) : (i += 1) {
            try out.appendSlice(self.allocator, "    "); // 4 espaces
        }
    }

    fn findBoundValue(self: *Projector, root: *ast.Node, name: []const u8) ?[]const u8 {
        _ = self;
        if (root.kind != .program) return null;

        for (root.data.list) |node| {
            if (node.kind == .definition) {
                const lhs = node.data.equation.lhs;
                const rhs = node.data.equation.rhs;

                // Si le côté gauche est notre variable (ex: 'n')
                // et le côté droit est un nombre constant
                if (lhs.kind == .identifier and 
                    std.mem.eql(u8, lhs.data.string, name) and 
                    rhs.kind == .constant) {
                    return rhs.data.string;
                }
            }
        }
        return null;
    }

    pub fn toForth(self: *Projector, node: *ast.Node) ![]const u8 {
        var out = std.ArrayListUnmanaged(u8){};
        errdefer out.deinit(self.allocator);

        // 1. Analyse : on cherche les tableaux
        var tables = std.StringHashMap(void).init(self.allocator);
        defer tables.deinit();
        try self.collectTables(node, &tables);

        // 2. Génération des entêtes Forth
        var it = tables.keyIterator();
        while (it.next()) |name| {
            const bound = self.findBoundValue(node, "n") orelse "1024";
            try out.writer(self.allocator).print("create {s} {s} cells allot\n", .{ name.*, bound });
        }

        // 3. Génération du reste du code
        try self.emitForth(node, &out);

        return out.toOwnedSlice(self.allocator);
    }

    fn collectTables(self: *Projector, node: *ast.Node, tables: *std.StringHashMap(void)) !void {
        switch (node.kind) {
            .subscript => {
                // On récupère le nom du tableau (qui est le fils .array)
                const array_node = node.data.subscript.array;
                if (array_node.kind == .identifier) {
                    try tables.put(array_node.data.string, {});
                }
            },
            .program => {
                for (node.data.list) |sub| try self.collectTables(sub, tables);
            },
            .forall => {
                try self.collectTables(node.data.forall.body, tables);
            },
            .definition => {
                try self.collectTables(node.data.equation.lhs, tables);
                try self.collectTables(node.data.equation.rhs, tables);
            },
            // ... gère les autres nœuds récursifs (application, etc.)
            else => {},
        }
    }
    fn emitForth(self: *Projector, node: *ast.Node, out: *std.ArrayListUnmanaged(u8)) !void {
        switch (node.kind) {
            .forall => {
                const fa = node.data.forall;
                try self.emitForth(fa.end, out);
                try out.appendSlice(self.allocator, " 1+ ");
                try self.emitForth(fa.start, out);
                try out.appendSlice(self.allocator, " do ");

                try self.emitForth(fa.body, out);
                try out.appendSlice(self.allocator, " ");

                if (fa.step) |step_node| {
                    try self.emitForth(step_node, out);
                    try out.appendSlice(self.allocator, " +loop");
                } else {
                    try out.appendSlice(self.allocator, "loop");
                }
            },
            .program => {
                for (node.data.list) |sub_node| {
                    try self.emitForth(sub_node, out);
                    try out.writer(self.allocator).print("\n", .{}); // Une ligne par def
                }
            },
            .constant, .identifier => {
                try out.writer(self.allocator).print("{s} ", .{node.data.string});
            },
            .application => {
                if (node.data.apply.func.kind == .application) {
                    try self.emitForth(node.data.apply.func.data.apply.arg, out);
                    try self.emitForth(node.data.apply.arg, out);
                    try self.emitForth(node.data.apply.func.data.apply.func, out);
                } else {
                    try self.emitForth(node.data.apply.arg, out);
                    try self.emitForth(node.data.apply.func, out);
                }
            },
            .definition => {
                const lhs = node.data.equation.lhs;
                const rhs = node.data.equation.rhs;

                if (lhs.kind == .subscript) {
                    // [Valeur] [Adresse] !
                    try self.emitForth(rhs, out); 
                    try out.appendSlice(self.allocator, " ");
                    // On appelle directement emitForth sur le subscript pour profiter du 1-
                    try self.emitForth(lhs, out); 
                    try out.appendSlice(self.allocator, " !");
                } else {
                    try out.appendSlice(self.allocator, ": ");
                    try self.emitForth(lhs, out);
                    try out.appendSlice(self.allocator, " ");
                    try self.emitForth(rhs, out);
                    try out.appendSlice(self.allocator, " ;");
                }
            },
            .subscript => {
                const sub = node.data.subscript;
                try self.emitForth(sub.array, out);
                try out.appendSlice(self.allocator, " ");
                try self.emitForth(sub.index, out);
                try out.appendSlice(self.allocator, " 1- cells +");

                // Calcule l'adresse : base + (index * taille)
                //try self.emitForth(node.data.subscript.index, out);
                //try out.appendSlice(self.allocator, " cells "); // 'cells' multiplie par la taille d'un mot
                //try self.emitForth(node.data.subscript.array, out);
                //try out.appendSlice(self.allocator, " + "); // Additionne à l'adresse de base
            },
            else => {
                // Très important pour le debug : voir ce qu'on rate
                std.log.warn("Nœud ignoré : {any}", .{node.kind});
            },
        }
    }

    pub fn toFortran(self: *Projector, root: *ast.Node) ![]u8 {
        var out = std.ArrayListUnmanaged(u8){};
        errdefer out.deinit(self.allocator);
        try self.emitFortran(root, &out);
        return out.toOwnedSlice(self.allocator);
    }

    fn emitFortran(self: *Projector, node: *ast.Node, out: *std.ArrayListUnmanaged(u8)) !void {
        switch (node.kind) {
            .forall => {
                const fa = node.data.forall;
                try out.appendSlice(self.allocator, "do ");
                try self.emitFortran(fa.variable, out);
                try out.appendSlice(self.allocator, " = ");
                try self.emitFortran(fa.start, out);
                try out.appendSlice(self.allocator, ", ");
                try self.emitFortran(fa.end, out);

                if (fa.step) |step_node| {
                    try out.appendSlice(self.allocator, ", ");
                    try self.emitFortran(step_node, out);
                }

                try out.appendSlice(self.allocator, "\n    ");
                try self.emitFortran(fa.body, out);
                try out.appendSlice(self.allocator, "\nend do");
            },
            .program => {
                for (node.data.list) |sub_node| {
                    try self.writeIndent(out); 
                    try self.emitFortran(sub_node, out);
                    try out.writer(self.allocator).print("\n", .{}); // Une ligne par def
                }
            },
            .constant, .identifier => {
                try out.writer(self.allocator).print("{s}", .{node.data.string});
            },
            .application => {
                if (node.data.apply.func.kind == .application) {
                    // C'est un opérateur binaire (notre structure App(App(op, L), R))
                    try out.writer(self.allocator).print("(", .{});
                    try self.emitFortran(node.data.apply.func.data.apply.arg, out);
                    try out.writer(self.allocator).print(" {s} ", .{node.data.apply.func.data.apply.func.data.string});
                    try self.emitFortran(node.data.apply.arg, out);
                    try out.writer(self.allocator).print(")", .{});
                } else {
                    // C'est un appel de fonction simple : func(arg)
                    try self.emitFortran(node.data.apply.func, out);
                    try out.writer(self.allocator).print("(", .{});
                    try self.emitFortran(node.data.apply.arg, out);
                    try out.writer(self.allocator).print(")", .{});
                }
            },
            .definition => {
                const lhs = node.data.equation.lhs;
                const rhs = node.data.equation.rhs;

                try self.emitFortran(lhs, out);

                try out.appendSlice(self.allocator, " = ");

                try self.emitFortran(rhs, out);
            },
            .subscript => {
                try self.emitFortran(node.data.subscript.array, out);
                try out.appendSlice(self.allocator, "(");
                try self.emitFortran(node.data.subscript.index, out);
                try out.appendSlice(self.allocator, ")");
            },
            else => {},
        }
    }
};
