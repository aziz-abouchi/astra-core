const std = @import("std");

pub const Allocator = std.mem.Allocator;

pub const Ident = []const u8;

pub const ExprTag = enum {
    Var,
    Fun,
    App,
    Let,
};

pub const Expr = union(ExprTag) {
    Var: Ident,
    Fun: struct {
        param: Ident,
        body: *Expr,
    },
    App: struct {
        func: *Expr,
        arg: *Expr,
    },
    Let: struct {
        name: Ident,
        value: *Expr,
        body: *Expr,
    },

    pub fn dump(self: *const Expr, w: anytype, indent: usize) !void {
        const pad = "                                "[0..@min(indent, 32)];
        switch (self.*) {
            .Var => |name| try w.print("{s}Var({s})\n", .{ pad, name }),
            .Fun => |f| {
                try w.print("{s}Fun({s})\n", .{ pad, f.param });
                try f.body.dump(w, indent + 2);
            },
            .App => |a| {
                try w.print("{s}App\n", .{ pad });
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

