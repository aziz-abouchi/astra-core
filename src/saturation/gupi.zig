const std = @import("std");
const EGraph = @import("egraph.zig");

pub const GUPI = struct {
    pub fn meditate(self: *GUPI, eg: *EGraph.EGraph) !void {
        _ = self;
        std.debug.print("[GUPI]: Analyse des constantes et réduction algébrique...\n", .{});

        var changed = true;
        while (changed) {
            changed = false;
            const current_len = eg.len;
            var i: usize = 0;

            while (i < current_len) : (i += 1) {
                const node = eg.nodes[i];
                if (node == .Operation) {
                    const op = node.Operation;
                    const left = eg.nodes[eg.find(op.left)];
                    const right = eg.nodes[eg.find(op.right)];

                    // Si les deux côtés sont des constantes, on plie !
                    if (left == .Constant and right == .Constant) {
                        const val_l = left.Constant;
                        const val_r = right.Constant;

                        const result = switch (op.op) {
                            .Add => val_l + val_r,
                            .Sub => val_l - val_r,
                            .Mul => val_l * val_r,
                            .Div => if (val_r != 0) val_l / val_r else val_l,
                            else => continue,
                        };

                        // On crée le nouveau concept '6'
                        const new_id = eg.addNode(.{ .Constant = result }) catch continue;
                        
                        // On annonce à l'E-Graph que '2 * 3' == '6'
                        if (eg.find(@intCast(i)) != eg.find(new_id)) {
                            eg.unionConcepts(@intCast(i), new_id);
                            changed = true;
                        }
                    }
                    // --- RÈGLES D'IDENTITÉ ET D'ANNIHILATION ---

                    // 1. Multiplication par 1 ou 0
                    if (op.op == .Mul) {
                        // x * 1 => x (Identité)
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
                        }
                        // x * 0 => 0 (Annihilation)
                        else if ((left == .Constant and left.Constant == 0.0) or (right == .Constant and right.Constant == 0.0)) {
                            const zero_id = eg.addNode(.{ .Constant = 0.0 }) catch continue;
                            if (eg.find(@intCast(i)) != eg.find(zero_id)) {
                                eg.unionConcepts(@intCast(i), zero_id);
                                changed = true;
                            }
                        }
                    }

                    // 2. Addition de 0
                    if (op.op == .Add) {
                        // x + 0 => x
                        if (right == .Constant and right.Constant == 0.0) {
                            if (eg.find(@intCast(i)) != eg.find(op.left)) {
                                eg.unionConcepts(@intCast(i), op.left);
                                changed = true;
                            }
                        } else if (left == .Constant and left.Constant == 0.0) {
                            if (eg.find(@intCast(i)) != eg.find(op.right)) {
                                eg.unionConcepts(@intCast(i), op.right);
                                changed = true;
                            }
                        }
                    }

                    // --- RÈGLE DE COMMUTATIVITÉ ---
                    // Si c'est une Addition ou une Multiplication, l'ordre n'importe pas.
                    if (op.op == .Add or op.op == .Mul) {
                        // On crée le nœud "miroir" (droite à gauche, gauche à droite)
                        const mirror_node = try eg.addNode(.{ .Operation = .{
                            .op = op.op,
                            .left = op.right,
                            .right = op.left,
                        } });

                        // On annonce que (a + b) == (b + a)
                        if (eg.find(@intCast(i)) != eg.find(mirror_node)) {
                            eg.unionConcepts(@intCast(i), mirror_node);
                            changed = true;
                        }
                    }
                }
            }
        }
    }
};
