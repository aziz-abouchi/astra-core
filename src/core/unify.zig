pub fn unifyGlobal(node: *ast.Node, ctx: *Context) !void {
    switch (node.kind) {
        .binary_op => {
            const left = try unifyGlobal(node.data.binary.left, ctx);
            const right = try unifyGlobal(node.data.binary.right, ctx);
            
            // Si c'est physique : Vérifier les dimensions
            if (left.isPhysical() and right.isPhysical()) {
                node.resolved_dim = try checkDimensions(node.op, left.dim, right.dim);
            }
            
            // Si c'est un flux (⇉) : Vérifier les protocoles de communication
            if (node.op == .flow) {
                try validateProtocol(left.actor, right.actor);
            }
        },
        // ...
    }
}

pub fn verifyConstraints(node: *ast.Node, context: *Context) !void {
    switch (node.kind) {
        .factorial => {
            const operand_domain = try context.getDomain(node.data.unary);
            // La factorielle n'est définie que sur ℕ ou ℕ*
            if (!Domain.nat.includes(operand_domain)) {
                return error.DomainError; // "Factorielle indéfinie pour les nombres négatifs ou réels"
            }
        },
        .forall => {
            const q = node.data.forall;
            // On enregistre que 'x' appartient au domaine spécifié (ex: ℕ*)
            try context.registerVariable(q.variable, q.domain);
            // On vérifie le corps de l'énoncé avec cette nouvelle contrainte
            try verifyConstraints(q.body, context);
        },
        .comparison => {
            try verifyConstraints(node.data.binary.left, context);
            try verifyConstraints(node.data.binary.right, context);
        },
        else => {},
    }
}

// Exemple de vérification dimensionnelle
fn checkPhysics(op: BinaryOp, left: Unit, right: Unit) !Unit {
    return switch (op) {
        .add => if (left.eq(right)) left else error.IncompatibleUnits,
        .mul => left.multiplyBy(right), // m * m = m²
        .div => left.divideBy(right),   // m / s = v
    };
}
