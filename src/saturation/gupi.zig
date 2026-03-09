const std = @import("std");
const EGraph = @import("egraph.zig");

pub const GUPI = struct {
    pub fn saturate(self: *GUPI, eg: *EGraph.EGraph, root: EGraph.EClassId) !void {
        _ = self;
        _ = root;

        var i: usize = 0;
        while (i < eg.len) : (i += 1) {
            const node = eg.nodes[i];
            if (node == .Operation) {
                const op = node.Operation;

                // --- Règle 1 : Factorielle (Hack Mul(x, x)) ---
                if (op.op == .Mul and eg.find(op.left) == eg.find(op.right)) {
                    const val_node = eg.nodes[eg.find(op.left)];
                    switch (val_node) {
                        .Constant => |n| {
                            var res: f64 = 1.0;
                            var j: f64 = 1.0;
                            while (j <= n) : (j += 1.0) res *= j;

                            eg.nodes[i] = .{ .Constant = res };
                            std.debug.print("[GUPI]: Réduction {d}! -> {d}\n", .{ n, res });
                        },
                        else => {},
                    }
                }

                // --- Règle 2 : Produit Π (Mul avec domaine Sub) ---
                if (op.op == .Mul) {
                    const domain_node = eg.nodes[eg.find(op.left)];
                    if (domain_node == .Operation and domain_node.Operation.op == .Sub) {
                        const start_node = eg.nodes[eg.find(domain_node.Operation.left)];
                        const end_node = eg.nodes[eg.find(domain_node.Operation.right)];

                        if (start_node == .Constant and end_node == .Constant) {
                            const start = start_node.Constant;
                            const end = end_node.Constant;
                            var res: f64 = 1.0;
                            var k = start;
                            while (k <= end) : (k += 1.0) res *= k;

                            eg.nodes[i] = .{ .Constant = res };
                            std.debug.print("[GUPI]: Π({d}..{d}) réduit à {d}\n", .{ start, end, res });
                        }
                    }
                }
            }
        }
    }

    pub fn meditate(self: *GUPI, eg: *EGraph.EGraph) !void {
        _ = self;
        std.debug.print("[GUPI]: Analyse des constantes et réduction algébrique...\n", .{});

        var changed = true;
        var passes: usize = 0;
        // On limite les passes pour éviter toute explosion imprévue
        while (changed and passes < 50) : (passes += 1) {
            changed = false;
            const current_len = eg.len;
            var i: usize = 0;

            while (i < current_len) : (i += 1) {
                const node = eg.nodes[i];
                if (node == .Operation) {
                    const op = node.Operation;
                    const left = eg.nodes[eg.find(op.left)];
                    const right = eg.nodes[eg.find(op.right)];

                    // 1. Pliage des constantes (Constant Folding)
                    if (left == .Constant and right == .Constant) {
                        const val_l = left.Constant;
                        const val_r = right.Constant;

                        const result = switch (op.op) {
                            .Add => val_l + val_r,
                            .Sub => val_l - val_r,
                            .Mul => val_l * val_r,
                            .Div => if (val_r != 0) val_l / val_r else val_l,
                            else => null,
                        };

                        if (result) |res| {
                            const new_id = try eg.addNode(.{ .Constant = res });
                            if (eg.find(@intCast(i)) != eg.find(new_id)) {
                                eg.unionConcepts(@intCast(i), new_id);
                                changed = true;
                            }
                        }
                    }

                    // 2. Multiplication par 1 ou 0
                    if (op.op == .Mul) {
                        if (right == .Constant and right.Constant == 1.0) {
                            if (eg.find(@intCast(i)) != eg.find(op.left)) {
                                eg.unionConcepts(@intCast(i), op.left);
                                changed = true;
                            }
                        } else if (left == .Constant and left.Constant == 1.0) {
                            if (eg.find(@intCast(i)) != eg.find(op.right)) {
                                eg.unionConcepts(@intCast(i), op.right);
                                changed = true;
                            }
                        } else if ((left == .Constant and left.Constant == 0.0) or (right == .Constant and right.Constant == 0.0)) {
                            const zero_id = try eg.addNode(.{ .Constant = 0.0 });
                            if (eg.find(@intCast(i)) != eg.find(zero_id)) {
                                eg.unionConcepts(@intCast(i), zero_id);
                                changed = true;
                            }
                        }
                    }

                    // 3. Commutativité (Add/Mul/Dot)
                    if (op.op == .Add or op.op == .Mul or op.op == .Dot) {
                        const mirror_node = try eg.addNode(.{ .Operation = .{
                            .op = op.op,
                            .left = op.right,
                            .right = op.left,
                            .dim = op.dim,
                        } });

                        if (eg.find(@intCast(i)) != eg.find(mirror_node)) {
                            eg.unionConcepts(@intCast(i), mirror_node);
                            changed = true;
                        }
                    }

                    // 4. Scalaire * Vecteur
                    if (op.op == .Mul) {
                        const s_node = if (left == .Constant) left else if (right == .Constant) right else null;
                        const v_node = if (left == .Vector) left else if (right == .Vector) right else null;

                        if (s_node != null and v_node != null) {
                            const s = s_node.?.Constant;
                            const v_data = v_node.?.Vector.data;

                            var new_vec_data = try eg.allocator.alloc(f64, v_data.len);
                            for (v_data, 0..) |val, j| { new_vec_data[j] = val * s; }

                            const new_id = try eg.addNode(.{ .Vector = .{ .data = new_vec_data } });
                            
                            // On vérifie si addNode a utilisé notre nouveau pointeur ou un ancien
                            if (eg.nodes[new_id].Vector.data.ptr != new_vec_data.ptr) {
                                eg.allocator.free(new_vec_data);
                            }

                            if (eg.find(@intCast(i)) != eg.find(new_id)) {
                                eg.unionConcepts(@intCast(i), new_id);
                                changed = true;
                            }
                        }
                    }

                    // 5. Produit Scalaire (Dot Product)
                    if (op.op == .Dot) {
                        if (left == .Vector and right == .Vector) {
                            var res: f64 = 0;
                            const len = @min(left.Vector.data.len, right.Vector.data.len);
                            for (0..len) |j| {
                                res += left.Vector.data[j] * right.Vector.data[j];
                            }

                            const new_id = try eg.addNode(.{ .Constant = res });
                            if (eg.find(@intCast(i)) != eg.find(new_id)) {
                                eg.unionConcepts(@intCast(i), new_id);
                                changed = true;
                            }
                        }
                    }
                }
            }
        }
    }
};
