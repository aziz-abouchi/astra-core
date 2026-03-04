const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const TokenTag = @import("lexer.zig").TokenTag;
const Node = @import("ast.zig").Node;
const Call = @import("ast.zig").Call;

pub const ParseError = error{
    UnexpectedToken,
    ExpectedParen,
    InvalidNumber,
    OutOfMemory,
};

pub const Parser = struct {
    lexer: Lexer,
    current: @import("lexer.zig").Token,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) Parser {
        var l = Lexer.init(src);
        return .{
            .lexer = l,
            .current = l.next(),
            .allocator = allocator,
        };
    }

    fn advance(self: *Parser) ParseError!void {
        self.current = self.lexer.next();
    }

    pub fn parse(self: *Parser) ParseError!*Node {
        return try self.parseExpr();
    }

    fn parseExpr(self: *Parser) ParseError!*Node {
        return switch (self.current.tag) {
            .number => try self.parseNumber(),
            .ident => try self.parseIdentOrCall(),
            else => error.UnexpectedToken,
        };
    }

    fn parseNumber(self: *Parser) ParseError!*Node {
        const val = try std.fmt.parseInt(i64, self.current.lexeme, 10);
        self.advance();

        const node = try self.allocator.create(Node);
        node.* = .{ .Int = val };
        return node;
    }

    fn parseIdentOrCall(self: *Parser) ParseError!*Node {
        const name = self.current.lexeme;
        self.advance();

        if (self.current.tag != .lparen) {
            const node = try self.allocator.create(Node);
            node.* = .{ .Ident = name };
            return node;
        }

        self.advance(); // (

        const arg = try self.parseExpr();

        if (self.current.tag != .rparen)
            return error.ExpectedParen;

        self.advance();

        const node = try self.allocator.create(Node);
        node.* = .{
            .Call = Call{
                .name = name,
                .arg = arg,
            },
        };
        return node;
    }
};
