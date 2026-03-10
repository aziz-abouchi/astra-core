const std = @import("std");
const hash_mod = @import("../common/hash.zig");
const lexer = @import("../lens/lexer.zig");
const Token = lexer.Token;

pub const EClassId = u32;

pub const OpType = enum { Add, Sub, Mul, Div, Dot, Cross };

pub const Justification = union(enum) {
    Axiom: []const u8,        // ex: "Commutativité"
    Computation: []const u8,   // ex: "Pliage (9.81 * 50 * 10)"
    DimensionalAnalysis: []const u8, // ex: "L1 * M1 * L1 * T-2 = L2 M1 T-2"
};

pub const UnionEntry = struct {
    id1: EClassId,
    id2: EClassId,
    reason: Justification,
};

pub const Units = struct {
    m: i8 = 0, // Masse (kg)
    l: i8 = 0, // Longueur (m)
    t: i8 = 0, // Temps (s)
    i: i8 = 0, // Courant (A)

    pub fn add(a: Units, b: Units) Units {
        return .{ .m = a.m + b.m, .l = a.l + b.l, .t = a.t + b.t, .i = a.i + b.i };
    }
    pub fn sub(a: Units, b: Units) Units {
        return .{ .m = a.m - b.m, .l = a.l - b.l, .t = a.t - b.t, .i = a.i - b.i };
    }
};

pub const Quantity = struct {
    value: f64,
    mantissa: f64, // ex: 1.23
    uncertainty: f64, // ex: 0.1 pour 10m ± 0.1
    exponent: i16, // ex: -9 pour 1.23e-9
    unit: Units,

    pub fn fromF64(v: f64, unit: Units) Quantity {
        return .{
            .value = v,
            .mantissa = v,
            .exponent = 0,
            .uncertainty = 0.0,
            .unit = unit,
        };
    }

    pub fn toF64(self: Quantity) f64 {
        return self.mantissa * std.math.pow(f64, 10, @floatFromInt(self.exponent));
    }

    pub fn formatDisplay(self: Quantity, buf: []u8) ![]u8 {
        // Utilise {f} pour forcer le formatage flottant si {d} pose problème
        return std.fmt.bufPrint(buf, "{d}e{d} ± {d}", .{ 
            @as(f64, self.mantissa), 
            self.exponent, 
            @as(f64, self.uncertainty) 
        });
    }

    pub fn format(
        self: Quantity,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        // On utilise .{} pour les arguments et on s'assure que ce sont des types simples
        try writer.print("{d}e{i} ± {d}", .{ 
            self.mantissa, 
            self.exponent, 
            self.uncertainty 
        });
    }    
};

pub const Node = union(enum) {
    Atomic: [32]u8, // "x", "y", "a"
    Scalar: Quantity, // Remplace Constant
    Vector: struct {
        data: []Quantity,
    },
    Operation: struct {
        op: OpType,
        left: EClassId,
        right: EClassId,
        dim: u32, // Le type dépendant : la dimension est stockée ici
    },
    Hole: struct { expected_unit: Units },
};

fn nodesAreEqual(a: Node, b: Node) bool {
    // 1. Vérifie si les tags (Atomic, Constant, etc.) sont identiques
    if (@as(std.meta.Tag(Node), a) != @as(std.meta.Tag(Node), b)) return false;

    // 2. Vérifie le contenu selon le type
    return switch (a) {
        .Scalar => |qa| {
            const qb = b.Scalar;
            // Égalité physique : (Valeur * 10^Exp) == (Valeur * 10^Exp) ET Unités identiques
            return (qa.toF64() == qb.toF64()) and std.meta.eql(qa.unit, qb.unit);
        },
        .Atomic => |v| std.mem.eql(u8, &v, &b.Atomic),
        .Vector => |va| {
            if (va.data.len != b.Vector.data.len) return false;
            for (va.data, 0..) |qa, idx| {
                const qb = b.Vector.data[idx];
                if (qa.toF64() != qb.toF64() or !std.meta.eql(qa.unit, qb.unit)) return false;
            }
            return true;
        },
        //.Vector => |v| std.mem.eql(f64, v.data, b.Vector.data), // Comparaison de CONTENU
        .Hole => |ha| {
            const hb = b.Hole;
            return std.meta.eql(ha.expected_unit, hb.expected_unit);
        },
        .Operation => |v| {
            const b_op = b.Operation;
            return v.op == b_op.op and 
                   v.left == b_op.left and 
                   v.right == b_op.right and 
                   v.dim == b_op.dim;
        },
    };
}

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
        // Dédoublonnage manuel avec comparaison profonde
        for (self.nodes[0..self.len], 0..) |existing, i| {
            if (nodesAreEqual(existing, node)) {
                // Si c'est un vecteur qu'on vient de nous passer et qu'on l'a déjà,
                // on doit libérer la mémoire du "nouveau" car on ne l'utilisera pas.
                // (Seulement si GUPI a alloué spécifiquement pour cet appel)
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
            .Scalar => 1.0,  // Très peu coûteux
            .Vector => 1.2,    // On rend les vecteurs numériques très attractifs
            .Atomic => 50.0,   // On rend les variables très "chères" pour forcer l'expansion
            .Hole => 100.0, // Très cher : on veut boucher les trous !
            .Operation => |op| {
                _ = op;
                // Un calcul est plus cher qu'une valeur brute, mais moins qu'une variable inconnue
                return 10.0; 
            },
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

    pub fn isVector(self: *EGraph, id: EClassId) bool {
        return self.getDim(self.getBestId(id)) > 0;
    } 

    pub fn addVector(self: *EGraph, values: []const f64) !EClassId {
        const data = try self.allocator.alloc(Quantity, values.len);
        for (values, 0..) |v, i| {
            data[i] = .{
                .value = v,
                .mantissa = v, // Simplification pour l'instant
                .uncertainty = 0,
                .exponent = 0,
                .unit = .{ .m = 0, .l = 0, .t = 0, .i = 0 },
            };
        }
        return self.addNode(.{ .Vector = .{ .data = data } });
    }

    // La fonction de typage dépendant
    pub fn getDim(self: *EGraph, id: EClassId) u32 {
        const node = self.nodes[id];
        return switch (node) {
            .Scalar => 0,
            .Vector => |v| @intCast(v.data.len),
            .Operation => |op| op.dim,
            .Hole => 0, // Par défaut
            .Atomic => |name| {
                const n = std.mem.trim(u8, &name, " ");
                if (std.mem.eql(u8, n, "x") or std.mem.eql(u8, n, "y")) return 0;
                return 3; // Par défaut pour les atomes inconnus
            },
        };
    }

    pub fn deinit(self: *EGraph) void {
        // On utilise 'self.len' au lieu de 'node_count'
        for (self.nodes[0..self.len]) |node| {
            switch (node) {
                .Vector => |v| self.allocator.free(v.data),
                else => {},
            }
        }
        self.allocator.free(self.nodes);
        self.allocator.free(self.parents);
        self.memo.deinit(); // N'oublie pas la HashMap !
    }
};
