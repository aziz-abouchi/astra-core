const std = @import("std");

pub const TokenTag = enum {
    Ident,
    KwLet,
    KwFun,
    KwIn,
    Arrow,
    Equal,
    LParen,
    RParen,
    EOF,
};

pub const Token = struct {
    tag: TokenTag,
    lexeme: []const u8,
};

pub const Lexer = struct {
    input: []const u8,
    index: usize,

    pub fn init(input: []const u8) Lexer {
        return .{ .input = input, .index = 0 };
    }

    pub fn peek(self: *Lexer) ?u8 {
        if (self.index >= self.input.len) return null;
        return self.input[self.index];
    }

    fn advance(self: *Lexer) ?u8 {
        const c = self.peek() orelse return null;
        self.index += 1;
        return c;
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.peek()) |c| {
            if (c == ' ' or c == '\n' or c == '\t' or c == '\r') {
                _ = self.advance();
            } else break;
        }
    }

    pub fn next(self: *Lexer) Token {
        self.skipWhitespace();

        const start = self.index;
        const c_opt = self.advance();
        if (c_opt == null) return .{ .tag = .EOF, .lexeme = "" };
        const c = c_opt.?;

        switch (c) {
            '-' => {
                if (self.peek() == '>') {
                    _ = self.advance();
                    return .{ .tag = .Arrow, .lexeme = self.input[start..self.index] };
                }
            },
            '=' => return .{ .tag = .Equal, .lexeme = self.input[start..self.index] },
            '(' => return .{ .tag = .LParen, .lexeme = self.input[start..self.index] },
            ')' => return .{ .tag = .RParen, .lexeme = self.input[start..self.index] },
            else => {},
        }

        if (std.ascii.isAlphabetic(c)) {
            while (self.peek()) |ch| {
                if (std.ascii.isAlphanumeric(ch) or ch == '_') {
                    _ = self.advance();
                } else break;
            }
            const lex = self.input[start..self.index];
            if (std.mem.eql(u8, lex, "let")) return .{ .tag = .KwLet, .lexeme = lex };
            if (std.mem.eql(u8, lex, "fun")) return .{ .tag = .KwFun, .lexeme = lex };
            if (std.mem.eql(u8, lex, "in"))  return .{ .tag = .KwIn,  .lexeme = lex };
            return .{ .tag = .Ident, .lexeme = lex };
        }

        return .{ .tag = .EOF, .lexeme = "" };
    }
};

