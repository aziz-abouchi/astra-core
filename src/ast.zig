const std = @import("std");

pub const Allocator = std.mem.Allocator;

pub const Ident = []const u8;

pub const ExprTag = enum {
    Int,
    Bool,
    Var,
    Lambda,
    Apply,
    Let,
};

pub const LambdaExpr = struct {
    param: Ident,
    body: *Expr,
};
pub const ApplyExpr = struct {
    fn: *Expr,
    arg: *Expr,
};

pub const Expr = union(ExprTag) {
    Int: i64,
    Bool: bool,
    Var: Ident,
    Lambda: LambdaExpr,
    Apply: ApplyExpr,
    Let: struct {
        name: Ident,
        value: *Expr,
        body: *Expr,
    },

    pub fn dump(self: *const Expr, w: anytype, indent: usize) !void {
        const pad = "                                "[0..@min(indent, 32)];
        switch (self.*) {
            .Var => |name| try w.print("{s}Var({s})\n", .{ pad, name }),
            .Lambda => |f| {
                try w.print("{s}Lambda({s})\n", .{ pad, f.param });
                try f.body.dump(w, indent + 2);
            },
            .Apply => |a| {
                try w.print("{s}Apply\n", .{ pad });
                try a.func.dump(w, indent + 2);
                try a.arg.dump(w, indent + 2);
            },
            .Let => |l| {
                try w.print("{s}Let({s})\n", .{ pad, l.name });
                try l.value.dump(w, indent + 2);
                try l.body.dump(w, indent + 2);
            },
        }
    }
};

