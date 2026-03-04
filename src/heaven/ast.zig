const std = @import("std");

pub const NodeTag = enum {
    Int,
    Ident,
    FunctionDecl,
    Call,
};

pub const Node = union(NodeTag) {
    Int: i64,
    Ident: []const u8,
    FunctionDecl: *FunctionDecl,
    Call: *Call,
};

pub const FunctionDecl = struct {
    name: []const u8,
    params: []const u8,
    body: *Node,
};

pub const Call = struct {
    fn_name: []const u8,
    args: []const u8,
};

/// Dummy parser — renvoie toujours un Call("dummy")
pub fn parse(allocator: std.mem.Allocator, src: []const u8) !*Node {
    _ = src;

    const call = try allocator.create(Call);
    call.* = .{
        .fn_name = "dummy",
        .args = "",
    };

    const node = try allocator.create(Node);
    node.* = .{ .Call = call };

    return node;
}

pub fn typecheck(node: *Node) !void {
    _ = node;
    // futur typechecker
}

pub const runtime = struct {
    pub fn execute(node: *Node) void {
        switch (node.*) {
            .Call => |c| {
                std.debug.print("Executing call → {s}\n", .{c.fn_name});
            },
            .FunctionDecl => |f| {
                std.debug.print("Function → {s}\n", .{f.name});
            },
        }
    }
};
