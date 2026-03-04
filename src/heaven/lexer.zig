const std = @import("std");

pub const TokenTag = enum {
    ident,
    number,
    lparen,
    rparen,
    eof,
};

pub const Token = struct {
    tag: TokenTag,
    lexeme: []const u8,
};

pub const Lexer = struct {
    input: []const u8,
    pos: usize,

    pub fn init(input: []const u8) Lexer {
        return .{ .input = input, .pos = 0 };
    }

    fn peek(self: *Lexer) ?u8 {
        if (self.pos >= self.input.len) return null;
        return self.input[self.pos];
    }

    fn advance(self: *Lexer) void {
        self.pos += 1;
    }

    fn skipSpaces(self: *Lexer) void {
        while (self.peek()) |c| {
            if (c == ' ' or c == '\n' or c == '\t')
                self.advance()
            else
                break;
        }
    }

    pub fn next(self: *Lexer) Token {
        self.skipSpaces();

        const start = self.pos;
        const c = self.peek() orelse return .{ .tag = .eof, .lexeme = "" };

        if (std.ascii.isDigit(c)) {
            while (self.peek()) |d| {
                if (!std.ascii.isDigit(d)) break;
                self.advance();
            }
            return .{ .tag = .number, .lexeme = self.input[start..self.pos] };
        }

        if (std.ascii.isAlphabetic(c)) {
            while (self.peek()) |d| {
                if (!std.ascii.isAlphanumeric(d)) break;
                self.advance();
            }
            return .{ .tag = .ident, .lexeme = self.input[start..self.pos] };
        }

        self.advance();

        return switch (c) {
            '(' => .{ .tag = .lparen, .lexeme = "(" },
            ')' => .{ .tag = .rparen, .lexeme = ")" },
            else => .{ .tag = .eof, .lexeme = "" },
        };
    }
};
