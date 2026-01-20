const std = @import("std");
const Token = @import("lexer.zig").Token;
const Tok = @import("lexer.zig").Tok;

pub const SExpr = union(enum) { Atom: []const u8, List: []SExpr };

pub const ParseError = error{UnexpectedEOF, UnexpectedToken};

pub fn parse(gpa: std.mem.Allocator, toks: []const Token) !SExpr {
    var idx: usize = 0;
    return try parseOne(gpa, toks, &idx);
}

fn parseOne(gpa: std.mem.Allocator, toks: []const Token, idx: *usize) !SExpr {
    if (idx.* >= toks.len) return ParseError.UnexpectedEOF;
    const t = toks[idx.*];
    idx.* += 1;
    return switch (t.kind) {
        .Symbol => SExpr{ .Atom = t.text },
        .LParen => blk: {
            var list = std.ArrayList(SExpr).init(gpa);
            while (true) {
                if (idx.* >= toks.len) return ParseError.UnexpectedEOF;
                if (toks[idx.*].kind == .RParen) { idx.* += 1; break; }
                const elem = try parseOne(gpa, toks, idx);
                try list.append(elem);
            }
            break :blk SExpr{ .List = try list.toOwnedSlice() };
        },
        .RParen => ParseError.UnexpectedToken,
    };
}
