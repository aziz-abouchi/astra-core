const std = @import("std");
const ENode = @import("node.zig").ENode;

pub const EClass = struct {
    id: u32,
    nodes: std.ArrayList(ENode),

    pub fn init(gpa: std.mem.Allocator, id: u32) !EClass {
        return .{ .id = id, .nodes = std.ArrayList(ENode).init(gpa) };
    }
    pub fn deinit(self: *EClass) void {
        for (self.nodes.items) |n| {
            if (n.children.len > 0) self.nodes.allocator.free(n.children);
        }
        self.nodes.deinit();
    }
};
