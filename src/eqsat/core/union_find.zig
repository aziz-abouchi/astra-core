const std = @import("std");

pub const UnionFind = struct {
    parents: std.ArrayList(u32),

    pub fn init(gpa: std.mem.Allocator) !UnionFind {
        return .{ .parents = try std.ArrayList(u32).initCapacity(gpa, 16) };
    }
    pub fn deinit(self: *UnionFind) void { self.parents.deinit(); }

    pub fn make(self: *UnionFind) !u32 {
        const id: u32 = @as(u32, @intCast(self.parents.items.len));
        try self.parents.append(id);
        return @as(u32, @intCast(self.parents.items.len - 1));
    }

    pub fn find(self: *UnionFind, x: u32) u32 {
        const p = self.parents.items[x];
        if (p != x) {
            const r = self.find(p);
            self.parents.items[x] = r;
            return r;
        }
        return p;
    }

    pub fn unite(self: *UnionFind, a: u32, b: u32) u32 {
        const ra = self.find(a);
        const rb = self.find(b);
        if (ra == rb) return ra;
        self.parents.items[rb] = ra;
        return ra;
    }
};
