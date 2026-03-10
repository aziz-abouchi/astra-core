const std = @import("std");
const Units = @import("egraph.zig").Units;
const Quantity = @import("egraph.zig").Quantity;
const EClassId = @import("egraph.zig").EClassId;
const EGraph = @import("egraph.zig").EGraph;

pub const GUPI = struct {
    pub fn saturate(self: *GUPI, eg: *EGraph, root: EClassId) !void {
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
                        .Scalar => |n| {
                            var res: f64 = 1.0;
                            var j: f64 = 1.0;
                            while (j <= n.value) : (j += 1.0) res *= j;

                            eg.nodes[i] = .{ .Scalar = .{
                                .value = res,
                                .mantissa = res,
                                .exponent = 0,
                                .uncertainty = 0.0,
                                .unit = n.unit, 
                            } };

                            std.debug.print("[GUPI]: Réduction {d}! -> {d}\n", .{ n.toF64(), res });
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

                        if (start_node == .Scalar and end_node == .Scalar) {
                            const start = start_node.Scalar;
                            const end = end_node.Scalar;
                            var res: f64 = 1.0;
                            var k: f64 = start.value;
                            while (k <= end.value) : (k += 1.0) res *= k;

                            eg.nodes[i] = .{ .Scalar = .{
                                .value = res,
                                .mantissa = res,
                                .exponent = 0,
                                .uncertainty = 0.0,
                                .unit = start_node.Scalar.unit,
                            } };

                            std.debug.print("[GUPI]: Π({d}..{d}) réduit à {d}\n", .{ start.toF64(), end.toF64(), res });
                        }
                    }
                }
            }
        }
    }

    pub fn meditate(self: *GUPI, eg: *EGraph) !void {
        _ = self;
        std.debug.print("[GUPI]: Analyse des constantes et réduction algébrique...\n", .{});

        var changed = true;
        var passes: usize = 0;
        while (changed and passes < 50) : (passes += 1) {
            changed = false;
            const current_len = eg.len;
            var i: usize = 0;
            const target_unit = Units{ .m = 1, .l = 2, .t = -2 }; 

            while (i < current_len) : (i += 1) {
                const node = eg.nodes[i];

                if (node == .Operation) {
                    const op = node.Operation;
                    const left = eg.nodes[eg.find(op.left)];
                    const right = eg.nodes[eg.find(op.right)];

                    // --- Inférence d'unité pour les trous ---
                    if (op.op == .Mul or op.op == .Dot) {
                        if (left == .Scalar and right == .Hole) {
                            const inferred_unit = Units.sub(target_unit, left.Scalar.unit);
                            eg.nodes[eg.find(op.right)].Hole.expected_unit = inferred_unit;
                            std.debug.print("[Assistant]: Unité déduite pour le trou : {any}\n", .{inferred_unit});
                        }
                    }

                    // --- 1. Pliage des constantes (Scalar Folding) ---
                    if (left == .Scalar and right == .Scalar) {
                        const val_l = left.Scalar;
                        const val_r = right.Scalar;

                        const result_f64 = switch (op.op) {
                            .Add => val_l.value + val_r.value,
                            .Sub => val_l.value - val_r.value,
                            .Mul => val_l.value * val_r.value,
                            .Div => if (val_r.value != 0) val_l.value / val_r.value else val_l.value,
                            else => null,
                        };

                        if (result_f64) |res| {
                            const abs_res = @abs(res);
                            const exp = if (abs_res > 0) @as(i16, @intFromFloat(@floor(std.math.log10(abs_res)))) else 0;
                            const mantissa = res / std.math.pow(f64, 10, @floatFromInt(exp));

                            const new_id = try eg.addNode(.{ .Scalar = .{
                                .value = res,
                                .mantissa = mantissa,
                                .uncertainty = 0.0,
                                .exponent = exp,
                                .unit = if (op.op == .Add or op.op == .Sub) val_l.unit else Units.add(val_l.unit, val_r.unit),
                            } });

                            if (eg.find(@intCast(i)) != eg.find(new_id)) {
                                eg.unionConcepts(@intCast(i), new_id);
                                changed = true;
                            }
                        }
                    }

                    // --- 2. Neutralité et Annulation ---
                    if (op.op == .Mul) {
                        if (right == .Scalar and right.Scalar.value == 1.0) {
                            if (eg.find(@intCast(i)) != eg.find(op.left)) {
                                eg.unionConcepts(@intCast(i), op.left);
                                changed = true;
                            }
                        } else if (left == .Scalar and left.Scalar.value == 1.0) {
                            if (eg.find(@intCast(i)) != eg.find(op.right)) {
                                eg.unionConcepts(@intCast(i), op.right);
                                changed = true;
                            }
                        } else if ((left == .Scalar and left.Scalar.value == 0.0) or (right == .Scalar and right.Scalar.value == 0.0)) {
                            const unit_to_keep = if (left == .Scalar) left.Scalar.unit else if (right == .Scalar) right.Scalar.unit else Units{ .m = 0, .l = 0, .t = 0 };
                            const zero_id = try eg.addNode(.{ .Scalar = .{
                                .value = 0.0, .mantissa = 0.0, .exponent = 0, .uncertainty = 0.0, .unit = unit_to_keep,
                            } });
                            if (eg.find(@intCast(i)) != eg.find(zero_id)) {
                                eg.unionConcepts(@intCast(i), zero_id);
                                changed = true;
                            }
                        }
                    }

                    // --- 3. Validation et Propagation des Unités (SÉCURISÉ) ---
                    if (left == .Scalar and right == .Scalar) {
                        if (op.op == .Add) {
                            if (!std.meta.eql(left.Scalar.unit, right.Scalar.unit)) {
                                return error.IncompatibleUnits;
                            }
                        }
                        if (op.op == .Mul) {
                            const res_unit = Units.add(left.Scalar.unit, right.Scalar.unit);
                            std.debug.print("[GUPI]: Propagation unité -> {any}\n", .{res_unit});
                        }
                    }

                    // --- 4. Commutativité ---
                    if (op.op == .Add or op.op == .Mul or op.op == .Dot) {
                        const mirror_node = try eg.addNode(.{ .Operation = .{
                            .op = op.op, .left = op.right, .right = op.left, .dim = op.dim,
                        } });
                        if (eg.find(@intCast(i)) != eg.find(mirror_node)) {
                            eg.unionConcepts(@intCast(i), mirror_node);
                            changed = true;
                        }
                    }

                    // --- 5. Scalaire * Vecteur (SÉCURISÉ) ---
                    if (op.op == .Mul) {
                        const s_maybe = if (left == .Scalar) left else if (right == .Scalar) right else null;
                        const v_maybe = if (left == .Vector) left else if (right == .Vector) right else null;

                        if (s_maybe != null and v_maybe != null) {
                            const s = s_maybe.?.Scalar;
                            const v = v_maybe.?.Vector;
                            var new_vec_data = try eg.allocator.alloc(Quantity, v.data.len);
                            for (v.data, 0..) |q, j| {
                                new_vec_data[j] = .{
                                    .value = q.toF64() * s.value,
                                    .mantissa = q.toF64() * s.value,
                                    .exponent = 0,
                                    .uncertainty = q.uncertainty * s.value,
                                    .unit = Units.add(q.unit, s.unit),
                                };
                            }
                            const new_id = try eg.addNode(.{ .Vector = .{ .data = new_vec_data } });
                            if (eg.nodes[new_id].Vector.data.ptr != new_vec_data.ptr) eg.allocator.free(new_vec_data);
                            if (eg.find(@intCast(i)) != eg.find(new_id)) {
                                eg.unionConcepts(@intCast(i), new_id);
                                changed = true;
                            }
                        }
                    }

                    // --- 6. Distributivité (s * V) . X ---
                    if (op.op == .Dot) {
                        const l_node = eg.nodes[eg.find(op.left)];
                        if (l_node == .Operation and l_node.Operation.op == .Mul) {
                            const inner_op = l_node.Operation;
                            const dot_vx = try eg.addNode(.{ .Operation = .{ .op = .Dot, .left = inner_op.right, .right = op.right, .dim = 0 } });
                            const final_mul = try eg.addNode(.{ .Operation = .{ .op = .Mul, .left = inner_op.left, .right = dot_vx, .dim = 0 } });
                            if (eg.find(@intCast(i)) != eg.find(final_mul)) {
                                eg.unionConcepts(@intCast(i), final_mul);
                                changed = true;
                            }
                        }
                    }
                }
            }
        }
    }
};
