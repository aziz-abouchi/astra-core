const std = @import("std");
const Type = @import("heaven_types.zig").Type;

pub const TypeEnv = struct {
    const Map = std.StringHashMap(*const Type);

    alloc: std.mem.Allocator,
    map: Map,

    pub fn init(alloc: std.mem.Allocator) TypeEnv {
        return .{
            .alloc = alloc,
            .map = Map.init(alloc),
        };
    }

    pub fn deinit(self: *TypeEnv) void {
        self.map.deinit();
    }

    pub fn put(self: *TypeEnv, name: []const u8, ty: *const Type) void {
        self.map.put(name, ty) catch unreachable;
    }

    pub fn get(self: *TypeEnv, name: []const u8) ?*const Type {
        return self.map.get(name);
    }
};

