// Dans un coin de ton esprit ou dans src/forge/common.zig
pub fn getSymbol(op: EGraph.OpType) []const u8 {
    return switch (op) {
        .Add => "+",
        .Sub => "-",
        .Mul => "*",
        .Div => "/",
        .Dot => ".",   // Produit scalaire
        .Cross => "#", // Produit vectoriel (syntaxe Astra)
    };
}
