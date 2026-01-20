const std = @import("std");

pub const Env = struct {
    map: std.StringHashMap(u32),
    pub fn init(gpa: std.mem.Allocator) !Env { return .{ .map = std.StringHashMap(u32).init(gpa) }; }
    pub fn deinit(self: *Env) void { self.map.deinit(); }
    pub fn get(self: *Env, k: []const u8) ?u32 { return self.map.get(k); }
    pub fn put(self: *Env, gpa: std.mem.Allocator, k: []const u8, v: u32) !void { var e = try self.map.getOrPut(gpa, k); e.value_ptr.* = v; }
};
