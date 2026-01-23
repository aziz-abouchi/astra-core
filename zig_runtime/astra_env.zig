const std = @import("std");
const Type = @import("astra_types.zig").Type;

pub const TypeEnv = struct {
    allocator: std.mem.Allocator,
    map: std.StringHashMap(*Type),

    pub fn init(alloc: std.mem.Allocator) TypeEnv {
        return .{
            .allocator = alloc,
            .map = std.StringHashMap(*Type).init(alloc),
        };
    }

    pub fn put(self: *TypeEnv, name: []const u8, ty: *Type) void {
        self.map.put(name, ty) catch unreachable;
    }

    pub fn get(self: *TypeEnv, name: []const u8) ?*Type {
        return self.map.get(name);
    }
};
