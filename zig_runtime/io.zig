const std = @import("std");

pub fn println(msg: []const u8) void {
    std.debug.print("{s}\n", .{msg});
}

pub fn readFile(path: []const u8) ?[]u8 {
    const file = std.fs.cwd().openFile(path, .{}) catch return null;
    const data = file.readToEndAlloc(std.heap.page_allocator, 8192) catch return null;
    return data;
}
