const std = @import("std");

pub const TokenTag = enum {
    identifier,
    tensor_identifier, // Nouveau : pour A[10,10]
    op_add, op_mul,
    l_bracket, r_bracket,
    l_paren, r_paren,
    number,
    eof,
    AtRule,    // @rule
    Transform, // =>
    Placeholder, // les variables a, b dans les règles
};

pub const Token = struct {
    tag: TokenTag,
    slice: []const u8,

    pub fn priority(self: @This()) u8 {
        return switch (self.tag) {
            .op_add => 1,
            .op_mul => 2,
            else => 0,
        };
    }
};

pub const Lexer = struct {
    buffer: []const u8,
    pos: usize = 0,

    pub fn next(self: *Lexer) Token {
        while (self.pos < self.buffer.len and std.ascii.isWhitespace(self.buffer[self.pos])) self.pos += 1;
        if (self.pos >= self.buffer.len) return .{ .tag = .eof, .slice = "" };

        const start = self.pos;
        const c = self.buffer[self.pos];
        self.pos += 1;

        return switch (c) {
            '+' => .{ .tag = .op_add, .slice = self.buffer[start..self.pos] },
            '*' => .{ .tag = .op_mul, .slice = self.buffer[start..self.pos] },
            '(' => .{ .tag = .l_paren, .slice = self.buffer[start..self.pos] },
            ')' => .{ .tag = .r_paren, .slice = self.buffer[start..self.pos] },
            'a'...'z', 'A'...'Z' => {
                while (self.pos < self.buffer.len and std.ascii.isAlphanumeric(self.buffer[self.pos])) self.pos += 1;
                return .{ .tag = .identifier, .slice = self.buffer[start..self.pos] };
            },
            else => .{ .tag = .eof, .slice = "" },
        };
    }
};
