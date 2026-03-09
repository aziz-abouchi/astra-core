const H = @import("heaven.zig");
const std = @import("std");

pub fn main() void {
    const result = 20;
    std.debug.print("{d}\n", .{result});
}

