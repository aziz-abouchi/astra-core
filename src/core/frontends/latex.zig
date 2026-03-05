const std = @import("std");
const ast = @import("../ast.zig");
const Lexer = @import("../lexer.zig");

pub const LatexFrontend = struct {
    allocator: std.mem.Allocator,

    pub fn parse(self: *LatexFrontend, source: []const u8) !*ast.Node {
        var lexer = LatexLexer.init(source);
        // On cherche l'environnement \begin{equation} ou les $$ 
        // pour extraire le contenu mathématique.
        return self.parseMathBlock(&lexer);
    }

    fn parseMathBlock(self: *LatexFrontend, lexer: *LatexLexer) !*ast.Node {
        const token = lexer.next();
        return switch (token.kind) {
            .backslash_forall => {
                const variable = try self.parseExpression(lexer);
                _ = try lexer.expect(.backslash_in);
                const domain = try self.parseDomain(lexer); // Gère \mathbb{N}^*
                _ = try lexer.expect(.colon);
                const body = try self.parseExpression(lexer);
                return ast.createQuantifier(self.allocator, variable, domain, body);
            },
            // ... reste de la logique
        };
    }
};
