const std = @import("std");
const ast = @import("core");

pub const FortranBackend = struct {
    allocator: std.mem.Allocator,
    name: []const u8 = "Fortran",

    pub fn init(allocator: std.mem.Allocator) FortranBackend {
        return .{ .allocator = allocator };
    }

    pub fn emit(self: *FortranBackend, node: ast.Node) ![]const u8 {
        // Le compilateur Fortran a besoin de structures de boucles explicites
        return switch (node.kind) {
            .definition => {
                // Simulation d'une boucle DO CONCURRENT pour le HPC
                return try std.fmt.allocPrint(self.allocator, 
                    "pure function {s}\n  do concurrent (i=1:n)\n    !\n  end do\nend function", 
                    .{try self.emit(node.data.equation.lhs.*)}
                );
            },
            .identifier => try std.mem.dupe(self.allocator, u8, node.data.string),
            else => "!",
        };
    }
};
