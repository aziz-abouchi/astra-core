pub fn parseDocument(self: *LatexFrontend) !*ast.Node {
    var program_nodes = std.ArrayList(*ast.Node).init(self.allocator);
    
    while (!self.lexer.isAtEnd()) {
        const token = self.lexer.peek();
        
        if (token.kind == .backslash_begin) {
            _ = self.lexer.advance();
            const env_name = try self.lexer.expectString(); // ex: "equation"
            
            if (std.mem.eql(u8, env_name, "equation") or std.mem.eql(u8, env_name, "math")) {
                const math_ast = try self.parseMathBlock();
                try program_nodes.append(math_ast);
                _ = try self.lexer.expect(.backslash_end);
            }
        } else {
            _ = self.lexer.advance(); // On ignore le texte pur (le "bruit")
        }
    }
    return ast.createProgram(self.allocator, program_nodes.toOwnedSlice());
}
