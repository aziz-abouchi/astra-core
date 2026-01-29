const std = @import("std");
const ast = @import("ast.zig");
const lexer_mod = @import("lexer.zig");

const Expr = ast.Expr;
const Token = lexer_mod.Token;
const TokenTag = lexer_mod.TokenTag;
const Lexer = lexer_mod.Lexer;

pub const ParseError = error{
    UnexpectedToken,
    ExpectedIdent,
    UnexpectedEOF,
    OutOfMemory,
};

pub const Parser = struct {
    allocator: std.mem.Allocator,
    lexer: Lexer,
    current: Token,

    pub fn init(allocator: std.mem.Allocator, input: []const u8) Parser {
        var lex = Lexer.init(input);
        const first = lex.next(); // on avance CE lex
        return .{
            .allocator = allocator,
            .lexer = lex,     // on stocke le lex déjà avancé
            .current = first, // premier token
        };
    }

    fn advance(self: *Parser) void {
        self.current = self.lexer.next();
    }

    fn expect(self: *Parser, tag: TokenTag) ParseError!void {
        if (self.current.tag != tag)
            return ParseError.UnexpectedToken;
        self.advance();
    }

    // -------------------------
    // ENTRY POINT
    // -------------------------
pub fn parseExpr(self: *Parser) ParseError!*Expr {
    return self.parseLet();
}

fn parseLet(self: *Parser) ParseError!*Expr {
    if (self.current.tag == .KwLet) {
        self.advance(); // let

        if (self.current.tag != .Ident)
            return ParseError.ExpectedIdent;

        const name = self.current.lexeme;
        self.advance(); // ident

        try self.expect(.Equal);

        const value = try self.parseExpr();

        try self.expect(.KwIn);

        const body = try self.parseExpr();

        const node = try self.allocator.create(Expr);
        node.* = Expr{ .Let = .{
            .name = name,
            .value = value,
            .body = body,
        }};
        return node;
    }

    return self.parseFun();
}

fn parseFun(self: *Parser) ParseError!*Expr {
    if (self.current.tag == .KwFun) {
        self.advance(); // fun

        if (self.current.tag != .Ident)
            return ParseError.ExpectedIdent;

        const param = self.current.lexeme;
        self.advance();

        try self.expect(.Arrow);

        const body = try self.parseExpr();

        const node = try self.allocator.create(Expr);
        node.* = Expr{ .Lambda = .{
            .param = param,
            .body = body,
        }};
        return node;
    }

    return self.parseApp();
}

fn parseApp(self: *Parser) ParseError!*Expr {
    var expr = try self.parseAtom();

    while (self.current.tag == .Ident or self.current.tag == .LParen or self.current.tag == .KwFun) {
        const arg = try self.parseAtom();
        const node = try self.allocator.create(Expr);
        node.* = Expr{ .Apply = .{
            .fn = expr,
            .arg = arg,
        }};
        expr = node;
    }

    return expr;
}

fn parseAtom(self: *Parser) ParseError!*Expr {
    switch (self.current.tag) {
        .Ident => {
            const name = self.current.lexeme;
            self.advance();
            const node = try self.allocator.create(Expr);
            node.* = Expr{ .Var = name };
            return node;
        },
        .LParen => {
            self.advance();
            const e = try self.parseExpr();
            try self.expect(.RParen);
            return e;
        },
        .EOF => return ParseError.UnexpectedEOF,
        else => return ParseError.UnexpectedToken,
    }
}
};

