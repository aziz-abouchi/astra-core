// runtime/ast.zig
const std = @import("std");

pub const Expr = union(enum) {
    Int: i32,
    Vec: []f32,
    Send: struct { to: []const u8, msg: Expr },
    Recv: struct { from: []const u8 },
    Loop: struct { count: i32, body: []Expr },
    Choice: struct { branches: [][]Expr },
};
