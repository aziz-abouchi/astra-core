const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");

// On définit explicitement les erreurs pour aider le compilateur
pub const ParseError = error{
    UnexpectedToken,
    UnbalancedParentheses,
    OutOfMemory,
};

pub const Precedence = enum(u8) {
    none = 0,
    logical = 10,    // ∀, ∃
    assignment = 20,  // ≔
    comparison = 30,  // ≥, =, <, ≤
    sum = 40,         // +, -
    product = 50,     // *, /
    unary = 52,
    primary = 55,
    power = 60,       // ^, ⁿ
    postfix = 70,     // !
    call = 80,        // f(x)
};

pub const Parser = struct {
    allocator: std.mem.Allocator,
    tokens: []lexer.Token,
    pos: usize,

    pub fn init(allocator: std.mem.Allocator, tokens: []lexer.Token) Parser {
        return .{ .allocator = allocator, .tokens = tokens, .pos = 0 };
    }

    pub fn parse(self: *Parser) !*ast.Node {
        // Initialisation d'une liste Unmanaged
        var nodes = std.ArrayListUnmanaged(*ast.Node){}; 
        errdefer {
            for (nodes.items) |n| n.deinit(self.allocator);
            nodes.deinit(self.allocator);
        }

        // On boucle tant qu'on n'est pas à la fin du fichier
        while (self.peek().kind != .eof) {
            const expr = try self.parseExpression(.none);
            // On passe l'allocateur explicitement à append
            try nodes.append(self.allocator, expr);
        }

        const root = try self.allocator.create(ast.Node);
        root.* = .{ 
            .kind = .program,
            // On passe l'allocateur explicitement à toOwnedSlice
            .data = .{ .list = try nodes.toOwnedSlice(self.allocator) } 
        };
        return root;
    }

    fn parseExpression(self: *Parser, precedence: Precedence) ParseError!*ast.Node {
        var left = try self.parsePrefix(); // Gère les nombres, ∀, (, etc.

        while (@intFromEnum(precedence) < @intFromEnum(self.getPrecedence(self.peek().kind))) {
            const token = self.advance();

            // Si c'est un '!', on traite en postfixe immédiatement
            if (token.kind == .bang) {
                const fact_node = try self.allocator.create(ast.Node);
                fact_node.* = .{
                    .kind = .factorial,
                    .data = .{ .unary = left }, // 'left' est le 'x' déjà parsé
                };
                left = fact_node; // On continue avec 'x!' comme nouvelle base

                //left = try self.makeUnaryNode(.factorial, left);
                continue;
            }

            // Sinon, c'est un binaire (ex: ≥, ^)
            left = try self.parseInfix(left, token);
        }
        return left;
    }

    fn parsePrimary(self: *Parser) ParseError!*ast.Node {
        const token = self.advance();
        // std.log.debug("Parsing token: {any} ('{s}')", .{token.kind, token.slice});

        return switch (token.kind) {
            .number => ast.Node.newConstant(self.allocator, token.slice) catch error.OutOfMemory,
            .identifier => {
                const node = self.allocator.create(ast.Node) catch return error.OutOfMemory;
                node.* = .{ 
                    .kind = .identifier, 
                    .data = .{ .string = self.allocator.dupe(u8, token.slice) catch return error.OutOfMemory } 
                };
                return node;
            },
            .l_paren => {
                const expr = try self.parseExpression(.none);
                if ((self.advance()).kind != .r_paren) return error.UnbalancedParentheses;
                return expr;
            },
            // Gestion de ℕ, ℕ*, etc.
            .domain_nat, .domain_nat_star => {
                const node = self.allocator.create(ast.Node) catch return error.OutOfMemory;
                node.* = .{
                    .kind = .domain,
                    .data = .{ .string = self.allocator.dupe(u8, token.slice) catch return error.OutOfMemory }
                };
                return node;
            },
            else => {
                std.debug.print("Erreur : parsePrimary Token inattendu '{s}' de type {any}\n", .{token.slice, token.kind});
                return error.UnexpectedToken;
            },
        };
    }

    fn parsePrefix(self: *Parser) ParseError!*ast.Node {
        const token = self.advance();
        switch (token.kind) {
            .kw_forall => {

                // 1. Liste de variables
                var vars = std.ArrayListUnmanaged(*ast.Node){};
                errdefer {
                    for (vars.items) |v| v.deinit(self.allocator);
                    vars.deinit(self.allocator);
                }

                while (true) {
                    const tkn = self.peek();
                    if (tkn.kind != .identifier) {
                        std.debug.print("Erreur : Attendu identifiant, trouvé {any}\n", .{tkn.kind});
                        return error.UnexpectedToken;
                    }
                    const v = try self.createIdentifier(self.advance());
                    
                    try vars.append(self.allocator, v);
                    if (self.peek().kind == .comma) {
                        _ = self.advance();
                        continue;
                    } else break;
                }

                // 2. Le symbole ∈
                _ = try self.consume(.in_sym, "Attendu '∈' après la ou les variables");

                // 3. L'ensemble et le corps
                const domain = try self.parseExpression(.none);
                _ = try self.consume(.colon, "Attendu ':'");

                const body = try self.parseExpression(.none);

                const vars_slice = try vars.toOwnedSlice(self.allocator);
                return self.createQuantifier(vars_slice, domain, body);
            },
            .identifier => return self.createIdentifier(token),
            .number => return ast.Node.newConstant(self.allocator, token.slice) catch error.OutOfMemory,
            .domain_nat, .domain_nat_star => {
                const node = try self.allocator.create(ast.Node);
                node.* = .{
                    .kind = .domain,
                    .data = .{ .string = try self.allocator.dupe(u8, token.slice) }
                };
                return node;
            },
            .l_paren => {
                const expr = try self.parseExpression(.none);
                if ((self.advance()).kind != .r_paren) return error.UnbalancedParentheses;
                return expr;
            },
            .l_brace => {
                var items = std.ArrayListUnmanaged(*ast.Node){};
                while (self.peek().kind != .r_brace and self.peek().kind != .eof) {
                    const item = try self.parseExpression(.none);
                    try items.append(self.allocator, item);

                    if (self.peek().kind == .comma) _ = self.advance();    // Saute la virgule
                }
                _ = try self.consume(.r_brace, "Attendu '}' pour fermer l'ensemble");

                const node = try self.allocator.create(ast.Node);
                node.* = .{ .kind = .set, .data = .{ .list = try items.toOwnedSlice(self.allocator) } };
                return node;
            },
            .pipe => {
                const expr = try self.parseExpression(.none);
                _ = try self.consume(.pipe, "Attendu '|' pour fermer la valeur absolue");

                const node = try self.allocator.create(ast.Node);
                node.* = .{ 
                    .kind = .abs, 
                    .data = .{ .unary = expr } 
                };
                return node;
            },
            .minus => {
                // On parse ce qui suit le '-' avec une priorité élevée
                const expr = try self.parseExpression(.unary); 

                const node = try self.allocator.create(ast.Node);
                node.* = .{ 
                    .kind = .negation, // Ajoute 'negation' à ton enum NodeKind
                    .data = .{ .unary = expr } 
                };
                return node;
            },
            .pi_sym => {
                const node = try self.allocator.create(ast.Node);
                node.* = .{ .kind = .constant_pi, .data = .{ .string = "π" } };
                return node;
            },
            // ...
            else => {
                std.debug.print("Erreur : parsePrefix Token inattendu '{s}' de type {any}\n", .{token.slice, token.kind});
                return error.UnexpectedToken;
            },
        }
    }

    fn parseInfix(self: *Parser, left: *ast.Node, op_token: lexer.Token) ParseError!*ast.Node {
        const precedence = self.getPrecedence(op_token.kind);

        switch (op_token.kind) {
            .bang => {
                const node = try self.allocator.create(ast.Node);
                node.* = .{ .kind = .factorial, .data = .{ .unary = left } };
                return node;
            },
            .l_paren => {
                var args = std.ArrayListUnmanaged(*ast.Node){};
                // On parse les arguments tant qu'on ne voit pas une parenthèse fermante
                while (self.peek().kind != .r_paren) {
                    const arg = try self.parseExpression(.none);
                    try args.append(self.allocator, arg);
                    if (self.peek().kind == .comma) _ = self.advance(); // Saute la virgule
                }
                _ = try self.consume(.r_paren, "Attendu ')'");

                const node = try self.allocator.create(ast.Node);
                node.* = .{ 
                    .kind = .application, 
                    .data = .{ .apply = .{ 
                        .func = left, 
                        .args = try args.toOwnedSlice(self.allocator) 
                    } } 
                };
                return node;
            },
            .assign => {
                const right = try self.parseExpression(precedence);
                return ast.Node.newEquation(self.allocator, left, right) catch error.OutOfMemory;
            },
            .l_bracket => { // Gestion de v[i]
                const index = try self.parseExpression(.none);
                _ = try self.consume(.r_bracket, "Attendu ']' après l'index");

                const node = try self.allocator.create(ast.Node);
                node.* = .{ 
                    .kind = .access, 
                    .data = .{ .access = .{ .array = left, .index = index } } 
                };
                return node;
            },
            // Cas par défaut pour les binaires (≥, +, *, etc.)
            else => {
                const right = try self.parseExpression(precedence);
                const node = try self.allocator.create(ast.Node);
                node.* = .{ 
                    .kind = .comparison, 
                    .data = .{ .binary = .{ .left = left, .op = op_token.kind, .right = right } } 
                };
                return node;
            }
        }
    }

    fn parsePostfix(self: *Parser, left: *ast.Node) !*ast.Node {
        if (self.peek().kind == .bang) { // Le symbole '!'
            _ = self.advance();
            const node = try self.allocator.create(ast.Node);
            node.* = .{
                .kind = .factorial,
                .data = .{ .unary = left }
            };
            // On peut chaîner (ex: (n!)!)
            return try self.parsePostfix(node);
        }
        return left;
    }

    fn getPrecedence(self: *Parser, kind: lexer.TokenKind) Precedence {
        _ = self;
        return switch (kind) {
            .assign => .assignment,
            .geq, .leq, .equal => .comparison,
            .plus, .minus => .sum,
            .star, .slash => .product,
            .bang => .postfix,
            .l_paren, .l_bracket => .call,
            else => .none,
        };
    }

    fn advance(self: *Parser) lexer.Token {
        if (self.pos >= self.tokens.len) return .{ .kind = .eof, .slice = "" };
        const t = self.tokens[self.pos];
        self.pos += 1;
        return t;
    }

    fn peek(self: *Parser) lexer.Token {
        if (self.pos >= self.tokens.len) return .{ .kind = .eof, .slice = "" };
        return self.tokens[self.pos];
    }

    // Vérifie le token actuel et l'avance, sinon génère une erreur
    fn consume(self: *Parser, kind: lexer.TokenKind, message: []const u8) ParseError!lexer.Token {
        const token = self.peek();
        if (token.kind != kind) {
            std.debug.print("Erreur syntaxique : {s} (trouvé: {any})\n", .{ message, token.kind });
            return error.UnexpectedToken;
        }
        return self.advance();
    }

    // Helper pour créer un nœud d'identifiant
    fn createIdentifier(self: *Parser, token: lexer.Token) ParseError!*ast.Node {
        const node = self.allocator.create(ast.Node) catch return error.OutOfMemory;
        node.* = .{
            .kind = .identifier,
            .data = .{ .string = self.allocator.dupe(u8, token.slice) catch return error.OutOfMemory }
        };
        return node;
    }

    // Helper pour construire la structure ∀ (quantificateur)
    fn createQuantifier(self: *Parser, vars: []*ast.Node, domain: *ast.Node, body: *ast.Node) ParseError!*ast.Node {
        const node = self.allocator.create(ast.Node) catch return error.OutOfMemory;
        node.* = .{
            .kind = .forall,
            .data = .{
                .forall = .{
                    .vars = vars,
                    .domain = domain,
                    .body = body,
                    .start = null,
                    .end = null,
                    .step = null,
                }
            }
        };
        return node;
    }
};
