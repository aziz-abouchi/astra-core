const std = @import("std");

pub const Experience = struct {
    hash: u64,
    optimized_id: u32,
};

pub const Library = struct {
    memories: std.AutoHashMap(u64, u32),

    pub fn init(allocator: std.mem.Allocator) Library {
        return .{ .memories = std.AutoHashMap(u64, u32).init(allocator) };
    }

    pub fn recall(self: *Library, hash: u64) ?u32 {
        return self.memories.get(hash);
    }

    pub fn record(self: *Library, hash: u64, id: u32) !void {
        try self.memories.put(hash, id);
    }
};
