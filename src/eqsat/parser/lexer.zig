const std = @import("std");

pub const Tok = enum { LParen, RParen, Symbol };
pub const Token = struct { kind: Tok, text: []const u8 };

pub fn lex(gpa: std.mem.Allocator, input: []const u8) ![]Token {
    var list = std.ArrayList(Token).init(gpa);
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        const c = input[i];
        switch (c) {
            ' ', '\t', '\r', '\n' => {},
            '(' => try list.append(.{ .kind = .LParen, .text = input[i..i+1] }),
            ')' => try list.append(.{ .kind = .RParen, .text = input[i..i+1] }),
            else => {
                const start = i;
                while (i < input.len and input[i] != ' ' and input[i] != '\n' and input[i] != '\t' and input[i] != '(' and input[i] != ')') : (i += 1) {}
                try list.append(.{ .kind = .Symbol, .text = input[start..i] });
                i -= 1;
            },
        }
    }
    return try list.toOwnedSlice();
}
