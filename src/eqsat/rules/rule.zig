const std = @import("std");
pub const Rule = struct {
    name: []const u8,
    lhs: []const u8,
    rhs: []const u8,
    when: []const []const u8,
    pub fn deinit(self: *Rule, gpa: std.mem.Allocator) void { _ = self; _ = gpa; }
};
