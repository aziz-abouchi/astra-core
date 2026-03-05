const std = @import("std");
const ast = @import("../../core/ast.zig");
const Target = @import("../target.zig").Target;

pub const HeavenTarget = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) HeavenTarget {
        return .{ .allocator = allocator };
    }

    pub fn asTarget(self: *HeavenTarget) Target {
        return .{
            .ptr = self,
            .emitFn = emitWrapper,
            .deinitFn = deinitWrapper,
        };
    }

    fn emitWrapper(ptr: *anyopaque, node: *ast.Node) anyerror![]const u8 {
        const self: *HeavenTarget = @ptrCast(@alignCast(ptr));
        var out = std.ArrayListUnmanaged(u8){};
        errdefer out.deinit(self.allocator);
        try self.emitNode(node, &out);
        return out.toOwnedSlice(self.allocator);
    }

    fn deinitWrapper(ptr: *anyopaque) void {
        const self: *HeavenTarget = @ptrCast(@alignCast(ptr));
        self.allocator.destroy(self);
    }

    fn emitNode(self: *HeavenTarget, node: *ast.Node, out: *std.ArrayListUnmanaged(u8)) anyerror!void {
        const alloc = self.allocator;
        switch (node.kind) {
            .program => {
                for (node.data.list) |child| {
                    try self.emitNode(child, out);
                    try out.appendSlice(alloc, "\n");
                }
            },
            .application => {
                try self.emitNode(node.data.apply.func, out);
                try out.appendSlice(alloc, "(");
                for (node.data.apply.args, 0..) |arg, i| {
                    if (i > 0) try out.appendSlice(alloc, ", ");
                    try self.emitNode(arg, out);
                }
                try out.appendSlice(alloc, ")");
            },
            .forall => {
                try out.appendSlice(alloc, "∀ ");
                for (node.data.forall.vars, 0..) |variable, i| {
                    if (i > 0) try out.appendSlice(alloc, ", ");
                    try self.emitNode(variable, out);
                }

                if (node.data.forall.domain) |dom| {
                    try out.appendSlice(alloc, " ∈ ");
                    try self.emitNode(dom, out);
                }
                try out.appendSlice(alloc, " : ");
                try self.emitNode(node.data.forall.body, out);
            },
            .factorial => {
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, "!");
            },
            .comparison => {
                try self.emitNode(node.data.binary.left, out);
                const sym = switch (node.data.binary.op) {
                    .geq => " ≥ ", .leq => " ≤ ", .equal => " = ", else => " ",
                };
                try out.appendSlice(alloc, sym);
                try self.emitNode(node.data.binary.right, out);
            },
            .identifier, .constant, .domain => try out.appendSlice(alloc, node.data.string),
            .access => {
                try self.emitNode(node.data.access.array, out);
                try out.appendSlice(alloc, "[");
                try self.emitNode(node.data.access.index, out);
                try out.appendSlice(alloc, "]");
            },
            .set => {
                try out.appendSlice(alloc, "{");
                const list = node.data.list;
                for (list, 0..) |item, i| {
                    try self.emitNode(item, out);
                    if (i < list.len - 1) try out.appendSlice(alloc, ", ");
                }
                try out.appendSlice(alloc, "}");
            },
            .abs => {
                try out.appendSlice(alloc, "|");
                try self.emitNode(node.data.unary, out);
                try out.appendSlice(alloc, "|");
            },
            .negation => {
                try out.appendSlice(alloc, "-");
                try self.emitNode(node.data.unary, out);
            },
            else => {},
        }
    }
};
