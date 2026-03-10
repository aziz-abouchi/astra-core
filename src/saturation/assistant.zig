pub const ProofAssistant = struct {
    pub fn verify(eg: *EGraph, id1: EClassId, id2: EClassId) bool {
        // Si après saturation, les deux concepts pointent vers le même root
        // alors la preuve est faite : A == B.
        return eg.find(id1) == eg.find(id2);
    }

    pub fn suggest(eg: *EGraph, hole_id: EClassId) void {
        const root = eg.find(hole_id);
        const node = eg.nodes[root];
        if (node == .Hole) {
            std.debug.print("Hole trouvé ! Attendu: dim={d}, unit=M{d}L{d}T{d}\n", .{
                node.Hole.expected_dim,
                node.Hole.expected_unit.m,
                node.Hole.expected_unit.l,
                node.Hole.expected_unit.t,
            });
        }
    }

pub fn solveHole(eg: *EGraph, hole_id: EClassId) !Quantity {
    const root = eg.find(hole_id);
    // On cherche dans l'E-Class s'il existe déjà un Scalar ou un Vector 
    // qui a été unifié avec ce Hole par une règle mathématique.
    for (eg.nodes[0..eg.len], 0..) |node, i| {
        if (eg.find(@intCast(i)) == root) {
            switch (node) {
                .Scalar => |q| return q, // Le trou est résolu !
                .Vector => |_| { /* Idem pour vecteur */ },
                else => continue,
            }
        }
    }
    return error.UnresolvedHole;
}

pub fn checkAssertion(eg: *EGraph, left_id: EClassId, right_id: EClassId) void {
    if (eg.find(left_id) == eg.find(right_id)) {
        std.debug.print("[PREUVE]: L'assertion est formellement vérifiée.\n", .{});
    } else {
        std.debug.print("[PREUVE]: Impossible de prouver l'égalité. Dimensions manquantes ?\n", .{});
        // Ici, on pourrait suggérer une transformation via l'E-Graph
    }
}
    pub fn propagateConstraints(eg: *EGraph) !void {
        var changed = true;
        while (changed) {
            changed = false;
            for (eg.nodes[0..eg.len], 0..) |node, i| {
                if (node == .Operation) {
                    const op = node.Operation;
                    const res_root = eg.find(@intCast(i));
                    const left_root = eg.find(op.left);
                    const right_root = eg.find(op.right);

                    // Si on connaît le Résultat et la Gauche, on déduit la Droite !
                    // Exemple : Force / Masse = Accélération
                    if (hasValue(eg, res_root) and hasValue(eg, left_root) and !hasValue(eg, right_root)) {
                        const val_res = getValue(eg, res_root);
                        const val_left = getValue(eg, left_root);
                        const inferred = inverseOp(op.op, val_res, val_left);

                        const new_id = try eg.addNode(.{ .Scalar = inferred });
                        eg.unionConcepts(right_root, new_id);
                        changed = true;
                    }
                }
            }
        }
    }

    fn inverseOp(op: OpType, res: Quantity, known: Quantity) Quantity {
        return switch (op) {
            .Mul => res.div(known), // f = phi / k
            .Add => res.sub(known), // x = total - y
            .Dot => {
                // Cas complexe : Si le vecteur est connu sauf une composante
                // Astra peut suggérer la valeur manquante pour satisfaire le produit scalaire.
                return res; // Simplification pour l'instant
            },
            else => res,
        };
    }
};
