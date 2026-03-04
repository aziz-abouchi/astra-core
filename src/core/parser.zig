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
    assignment = 1,
    sum = 2,
    product = 3,
    call = 4,
    primary = 5,
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
        var left = try self.parsePrimary();

        while (true) {
            const token = self.peek();
            const next_prec = self.getPrecedence(token.kind);
            
            if (@intFromEnum(precedence) >= @intFromEnum(next_prec)) break;

            _ = self.advance(); 
            left = try self.parseInfix(left, token);
        }
        return left;
    }

    fn parsePrimary(self: *Parser) ParseError!*ast.Node {
        const token = self.advance();
        std.log.debug("Parsing token: {any} ('{s}')", .{token.kind, token.slice});

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
            .kw_forall => {
                // 1. On attend l'identifiant (la variable de boucle)
                const var_node = try self.parsePrimary();

                if (var_node.kind != .identifier) return error.UnexpectedToken;

                if ((self.advance()).kind != .kw_from) return error.UnexpectedToken;
                const start_node = try self.parseExpression(.none);

                if ((self.advance()).kind != .kw_to) return error.UnexpectedToken;
                const end_node = try self.parseExpression(.none);

                var step_node: ?*ast.Node = null;
                if (self.peek().kind == .kw_step) {
                    _ = self.advance();
                    step_node = try self.parseExpression(.none);
                }

                // 2. On attend le ':' (ou un autre délimiteur que tu as choisi)
                const colon = self.advance();
                if (colon.kind != .colon) return error.UnexpectedToken;

                // 3. On parse le corps (l'équation ou le bloc suivant)
                const body = try self.parseExpression(.none);

                const node = try self.allocator.create(ast.Node);
                node.* = .{
                    .kind = .forall,
                    .data = .{
                        .forall = .{
                            .variable = var_node,
                            .start = start_node,
                            .end = end_node,
                            .step = step_node,
                            .body = body
                        }
                   }
                };
                return node;
            },
            else => {
                std.debug.print("Erreur : Token inattendu '{s}' de type {any}\n", .{token.slice, token.kind});
                return error.UnexpectedToken;
            },
        };
    }

    pub fn parseInfix(self: *Parser, left: *ast.Node, op_token: lexer.Token) ParseError!*ast.Node {
        // CAS 1 : Appel de fonction sin(...)
        if (op_token.kind == .l_paren) {
            const arg = try self.parseExpression(.none); // On lit tout l'intérieur
            if ((self.advance()).kind != .r_paren) return error.UnbalancedParentheses;

            const node = self.allocator.create(ast.Node) catch return error.OutOfMemory;
            node.* = .{ .kind = .application, .data = .{ .apply = .{
                .func = left,
                .arg = arg,
            }}};
            return node;
        }

        if (op_token.kind == .l_bracket) {
            const index = try self.parseExpression(.none);

            // On vérifie qu'on ferme bien le crochet
            const next = self.advance();
            if (next.kind != .r_bracket) return error.UnexpectedToken;

            const node = try self.allocator.create(ast.Node);
            node.* = .{
                .kind = .subscript,
                .data = .{ .subscript = .{
                    .array = left,
                    .index = index
                } }
            };
            return node;
        }

        // Pour les autres cas, on a besoin du membre de droite
        const precedence = self.getPrecedence(op_token.kind);
        const right = try self.parseExpression(precedence);

        // CAS 2 : Assignation :=
        if (op_token.kind == .assign) {
            return ast.Node.newEquation(self.allocator, left, right) catch error.OutOfMemory;
        }

        // CAS 3 : Opérateurs binaires (+, -, *, /)
        const op_node = ast.Node.newConstant(self.allocator, op_token.slice) catch return error.OutOfMemory;

        const partial_apply = self.allocator.create(ast.Node) catch return error.OutOfMemory;
        partial_apply.* = .{ .kind = .application, .data = .{ .apply = .{
            .func = op_node,
            .arg = left,
        }}};

        const final_node = self.allocator.create(ast.Node) catch return error.OutOfMemory;
        final_node.* = .{ .kind = .application, .data = .{ .apply = .{
            .func = partial_apply,
            .arg = right,
        }}};

        return final_node;
    }

    fn getPrecedence(self: *Parser, kind: lexer.TokenKind) Precedence {
        _ = self;
        return switch (kind) {
            .assign => .assignment,
            .plus, .minus => .sum,
            .star, .slash => .product,
            .l_paren => .call,
            .l_bracket => .call,
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
};
