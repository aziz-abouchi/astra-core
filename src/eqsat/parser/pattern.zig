const std = @import("std");
const SExpr = @import("sexpr.zig").SExpr;

pub const Pattern = union(enum) {
    Var: []const u8,
    App: struct { sym: []const u8, args: []Pattern },
};

pub fn fromSExpr(gpa: std.mem.Allocator, sx: SExpr) !Pattern {
    return switch (sx) {
        .Atom => |a| blk: {
            if (a.len > 0 and a[0] == '?') break :blk Pattern{ .Var = a };
            break :blk Pattern{ .App = .{ .sym = a, .args = &[_]Pattern{} } };
        },
        .List => |ls| blk2: {
            if (ls.len == 0) return error.InvalidPattern;
            const head = ls[0];
            var sym: []const u8 = undefined;
            switch (head) { .Atom => |a| sym = a, else => return error.InvalidPattern }
            var args = try gpa.alloc(Pattern, ls.len - 1);
            var i: usize = 1;
            while (i < ls.len) : (i += 1) args[i-1] = try fromSExpr(gpa, ls[i]);
            break :blk2 Pattern{ .App = .{ .sym = sym, .args = args } };
        },
    };
}
