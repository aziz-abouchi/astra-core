const std = @import("std");
const ast = @import("core");

pub const ZigBackend = struct {
    allocator: std.mem.Allocator,
    name: []const u8 = "Zig",

    pub fn init(allocator: std.mem.Allocator, strategy: anytype) ZigBackend {
        _ = strategy; // On l'utilisera plus tard pour les optims
        return .{ .allocator = allocator };
    }

    pub fn emit(self: *ZigBackend, node: ast.Node) ![]const u8 {
        return switch (node.kind) {
            .definition => try std.fmt.allocPrint(self.allocator, "pub fn {s} ...", .{
                try self.emit(node.data.equation.lhs.*)
            }),
            .identifier => try std.mem.dupe(self.allocator, u8, node.data.string),
            .constant => try std.mem.dupe(self.allocator, u8, node.data.string),
            else => return error.ZigProjectionFailed,
        };
    }
};
