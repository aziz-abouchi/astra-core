const std = @import("std");

/// Les différents types de nœuds pour la syntaxe équationnelle de Heaven.
pub const NodeKind = enum {
    program,
    subscript,
    // Terminaux
    constant,    // Valeurs (3.14, "texte")
    identifier,  // Noms de variables ou fonctions
    
    // Logique & Types
    declaration, // name : type
    definition,  // head := body
    assertion,   // context |- property
    
    // Structures de données
    application, // f x
    list_cons,   // x :: xs
    vector_type, // Vec T N
    
    // Quantificateurs (Types Dépendants)
    forall,      // forall (x : T), U
    exists,      // exists (x : T), U
};

pub const Module = struct {
    name: []const u8,
    equations: std.ArrayListUnmanaged(*Node), // Changement ici
    
    pub fn init(name: []const u8) Module {
        return .{
            .name = name,
            .equations = .{}, // Initialisation vide
        };
    }

    pub fn deinit(self: *Module, allocator: std.mem.Allocator) void {
        self.equations.deinit(allocator);
    }
};

pub const Node = struct {
    kind: NodeKind,
    // On utilise une union pour économiser de la mémoire tout en restant flexible
    data: union {
        string: []const u8,         // Pour constants et identifiers
        decl: struct {              // Pour :
            name: *Node,
            type_expr: *Node,
        },
        equation: struct {          // Pour :=
            lhs: *Node,
            rhs: *Node,
        },
        apply: struct {             // Pour l'application de fonction
            func: *Node,
            arg: *Node,
        },
        quantifier: struct {        // Pour forall/exists
            variable: []const u8,
            type_expr: *Node,
            body: *Node,
        },
        list: []*Node,
        forall: struct {
            variable: *Node, // L'identifiant (ex: i)
            start: *Node,
            end: *Node,
            step: ?*Node,
            body: *Node,     // Le contenu de la boucle
        },
        subscript: struct {
            array: *Node,
            index: *Node,
        },
    },

    pub fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        switch (self.kind) {
            .program => {
                for (self.data.list) |child| {
                    child.deinit(allocator);
                }
                allocator.free(self.data.list);
            },
            .constant, .identifier => {
                allocator.free(self.data.string);
            },
            .definition => {
                self.data.equation.lhs.deinit(allocator);
                self.data.equation.rhs.deinit(allocator);
            },
            .application => {
                self.data.apply.func.deinit(allocator);
                self.data.apply.arg.deinit(allocator);
            },
            .forall => {
                // LIBÉRATION CRUCIALE : on nettoie l'indice et le corps
                self.data.forall.variable.deinit(allocator);
                self.data.forall.start.deinit(allocator);
                self.data.forall.end.deinit(allocator);
                if (self.data.forall.step) |s| s.deinit(allocator);
                self.data.forall.body.deinit(allocator);
            },
            .subscript => {
                self.data.subscript.array.deinit(allocator);
                self.data.subscript.index.deinit(allocator);
            },
            // Ajoute les autres cas (quantifier, decl, etc.) ici
            else => {},
        }
        allocator.destroy(self);
    }

    /// Fonction utilitaire pour créer un nœud de constante
    pub fn newConstant(allocator: std.mem.Allocator, val: []const u8) !*Node {
        const node = try allocator.create(Node);
        node.* = .{ .kind = .constant, .data = .{ .string = try allocator.dupe(u8, val) } };
        return node;
    }

    /// Fonction utilitaire pour créer une équation (A := B)
    pub fn newEquation(allocator: std.mem.Allocator, lhs: *Node, rhs: *Node) !*Node {
        const node = try allocator.create(Node);
        node.* = .{ .kind = .definition, .data = .{ .equation = .{ .lhs = lhs, .rhs = rhs } } };
        return node;
    }
};

/// Structure pour l'Arbre complet d'un module
pub const AST = struct {
    allocator: std.mem.Allocator,
    root_nodes: std.ArrayList(*Node),

    pub fn init(allocator: std.mem.Allocator) AST {
        return .{
            .allocator = allocator,
            .root_nodes = std.ArrayList(*Node).init(allocator),
        };
    }

    pub fn deinit(self: *AST) void {
        self.root_nodes.deinit();
    }
};
