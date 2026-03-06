// surge_core/lens/lexer.zig

pub const Token = union(enum) {
    Operator: OperatorType, // ∇, Δ, ∑, ≡, ⊸
    Identifier: []const u8, // m, c, energy, actor
    Literal: Value,        // 299792458
    Dimension: Unit,       // m/s, kg, J
    Hole: void,            // ?
};

pub const OperatorType = enum {
    Nabla,      // ∇
    Equivalent, // ≡
    LinearMap,  // ⊸ (Lollipop - Pony/Linear Logic)
    Summation,  // ∑
    TensorProd, // ⊗
};
