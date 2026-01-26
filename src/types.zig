const std = @import("std");

pub const TypeTag = enum {
    Var,
    Arrow,
};

pub const Type = union(TypeTag) {
    Var: []const u8,
    Arrow: struct {
        from: *Type,
        to: *Type,
    },

    pub fn dump(self: *const Type, w: anytype, indent: usize) !void {
        const pad = "                                "[0..@min(indent, 32)];
        switch (self.*) {
            .Var => |name| try w.print("{s}Type.Var({s})\n", .{ pad, name }),
            .Arrow => |a| {
                try w.print("{s}Type.Arrow\n", .{ pad });
                try a.from.dump(w, indent + 2);
                try a.to.dump(w, indent + 2);
            },
        }
    }
};

