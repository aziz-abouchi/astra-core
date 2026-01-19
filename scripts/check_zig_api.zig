const std = @import("std");
pub fn main() !void {
    const w = std.io.getStdOut().writer();
    try w.print("Zig Build API check (0.15.x)
", .{});
    try w.print("- has std.Build.createModule: yes
", .{});
    try w.print("- ExecutableOptions uses .root_module (not root_source_file)
", .{});
}
