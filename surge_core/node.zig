// surge_core/node.zig

const Hash = [32]u8; // SHA-256 ou Blake3

const NodeType = enum {
    Atom,       // Valeur pure
    Equation,   // Relation mathématique
    Actor,      // Isolation Pony
    Effect,     // Capacité Koka
    Proof,      // Contrainte Lean
};

const Node = struct {
    tag: NodeType,
    hash: Hash,
    dependencies: []Hash, // Les autres nœuds auxquels il est lié
    payload: []u8,        // Données brutes ou bytecode
};
