const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator;
    try std.io.getStdOut().writer().print("Astra-Core (EQSAT) — Zig 0.15 build OK\n", .{});
}
