const std = @import("std");
const ast = @import("core");

pub const CoqBackend = struct {
    allocator: std.mem.Allocator,
    name: []const u8 = "Coq",

    pub fn init(allocator: std.mem.Allocator) CoqBackend {
        return .{ .allocator = allocator };
    }

    pub fn emit(self: *CoqBackend, node: ast.Node) ![]const u8 {
        return switch (node.kind) {
            .declaration => try std.fmt.allocPrint(self.allocator, "Variable {s} : {s}.", .{ 
                node.data.decl.name.data.string, 
                "Type" // Simplifié pour l'exemple
            }),
            .definition => try std.fmt.allocPrint(self.allocator, "Definition {s} := {s}.", .{
                try self.emit(node.data.equation.lhs.*),
                try self.emit(node.data.equation.rhs.*)
            }),
            .constant => try std.mem.dupe(self.allocator, u8, node.data.string),
            .identifier => try std.mem.dupe(self.allocator, u8, node.data.string),
            else => return error.NotImplementedInCoq,
        };
    }
};
