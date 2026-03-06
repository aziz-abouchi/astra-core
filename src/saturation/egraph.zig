const std = @import("std");
const hash_mod = @import("../common/hash.zig");
const lexer = @import("../lens/lexer.zig");
const Token = lexer.Token;

pub const EClassId = u32;

pub const OpType = enum { Add, Sub, Mul, Div, Dot, Cross };

pub const Node = union(enum) {
    Atomic: [32]u8, // "x", "y", "a"
    Constant: f64,  // 2.0, 42.0
    Vector: struct { x: f64, y: f64, z: f64 }, // Un vecteur spatial
    Operation: struct {
        op: OpType,
        left: EClassId,
        right: EClassId,
    },
};

pub const EGraph = struct {
    allocator: std.mem.Allocator,
    nodes: []Node,
    parents: []EClassId,
    len: usize,
    cap: usize,
    memo: std.AutoHashMap(Node, EClassId),

    pub fn init(allocator: std.mem.Allocator) EGraph {
        return .{
            .allocator = allocator,
            .nodes = &.{},
            .parents = &.{},
            .len = 0,
            .cap = 0,
            .memo = std.AutoHashMap(Node, EClassId).init(allocator),
        };
    }

    pub fn addNode(self: *EGraph, node: Node) !EClassId {
        // GUPI vérifie si ce nœud existe déjà (Dédoublonnage)
        for (self.nodes[0..self.len], 0..) |existing, i| {
            if (std.meta.eql(existing, node)) {
                return @intCast(i);
            }
        }

        if (self.len >= self.cap) {
            const new_cap = if (self.cap == 0) 8 else self.cap * 2;
            self.nodes = try self.allocator.realloc(self.nodes, new_cap);
            self.parents = try self.allocator.realloc(self.parents, new_cap);
            self.cap = new_cap;
        }

        const id = @as(u32, @intCast(self.len));
        self.nodes[self.len] = node;
        self.parents[self.len] = id;
        self.len += 1;
        return id;
    }

    pub fn getBest(self: *EGraph, id: EClassId) EClassId {
        // GUPI : "Parmi toutes les versions équivalentes, laquelle est la plus simple ?"
        const root = self.find(id);
        // Pour l'instant, on retourne le premier trouvé, 
        // mais ici on implémentera le calcul du poids (AST depth).
        return root;
    }

    pub fn getBestId(self: *EGraph, id: EClassId) EClassId {
        const root = self.find(id);
        var best_id = root;
        var min_cost: f64 = 999999.0;

        // GUPI scanne tous les nœuds qui pointent vers cette idée
        for (self.nodes[0..self.len], 0..) |node, i| {
            if (self.find(@intCast(i)) == root) {
                const cost = self.calculateCost(node);
                if (cost < min_cost) {
                    min_cost = cost;
                    best_id = @intCast(i);
                }
            }
        }
        return best_id;
    }

    fn calculateCost(self: *EGraph, node: Node) f64 {
        _ = self;
        return switch (node) {
            .Constant => 1.0,  // Très peu coûteux
            .Atomic => 1.5,    // Variable
            .Operation => 10.0, // Coûteux (nécessite un calcul)
            else => 100.0,
        };
    }


    pub fn find(self: *EGraph, id: EClassId) EClassId {
        if (self.parents[id] == id) return id;
        self.parents[id] = self.find(self.parents[id]); // Compression de chemin
        return self.parents[id];
    }

    pub fn unionConcepts(self: *EGraph, id1: EClassId, id2: EClassId) void {
        const root1 = self.find(id1);
        const root2 = self.find(id2);
        if (root1 != root2) {
            self.parents[root1] = root2;
        }
    }
 
    pub fn isVector(self: *EGraph, id: EClassId) bool { // Retire le 'const' ici
        const best_id = self.getBestId(id);
        const node = self.nodes[best_id];

        return switch (node) {
            .Vector => true,
            .Operation => |op| {
                // Récursion sur l'enfant gauche pour propager le type
                return self.isVector(op.left);
            },
            .Atomic => |name| std.mem.startsWith(u8, &name, "vec3"),
            else => false,
        };
    }

    pub fn deinit(self: *EGraph) void {
        self.allocator.free(self.nodes);
        self.allocator.free(self.parents);
    }
};
