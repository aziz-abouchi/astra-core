// Exemple de logique de projection vers Forth
pub fn emit_equation(name: []const u8, params: []Node, body: Node) []const u8 {
    // Heaven : dot_product x y := (x * y) + acc
    // Forth  : : DOT_PRODUCT ( x y acc -- res ) * + ;
    
    // 1. Inversion des arguments (Post-fixe / RPN)
    // 2. Génération de la "Word" Forth
    return std.fmt.allocPrint(allocator, ": {s} {s} ;", .{name.toUpper(), flatten_to_rpn(body)});
}
