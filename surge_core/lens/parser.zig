// surge_core/lens/parser.zig

pub fn parseExpression(self: *Parser) !*Node {
    var lhs = try self.parseTerm();

    while (self.match(.Equivalent)) { // On a trouvé un '≡'
        const rhs = try self.parseExpression();
        // Au lieu de générer un 'Call', on génère une 'IdentityConstraint'
        // C'est ce qui alimentera notre moteur de Saturation Zig
        lhs = try self.createIdentityNode(lhs, rhs);
    }
    return lhs;
}
