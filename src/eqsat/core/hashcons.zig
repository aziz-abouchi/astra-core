const std = @import("std");
const Sym = @import("node.zig").Sym;

pub const Key = struct {
    sym: Sym,
    children: []const u32,

    pub fn hash(self: Key) u64 {
        var h = std.hash.Wyhash.hash(0, std.mem.asBytes(&@intFromEnum(self.sym)));
        for (self.children) |c| h = std.hash.Wyhash.hash(h, std.mem.asBytes(&c));
        return h;
    }
    pub fn eql(a: Key, b: Key) bool {
        if (a.sym != b.sym) return false;
        return std.mem.eql(u32, a.children, b.children);
    }
};

pub const KeyCtx = struct {
    pub fn hash(self: @This(), key: Key) u64 { _ = self; return key.hash(); }
    pub fn eql(self: @This(), a: Key, b: Key) bool { _ = self; return Key.eql(a, b); }
};
