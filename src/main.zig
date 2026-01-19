
const std = @import("std");

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    var args = std.process.args();
    _ = args.next(); // skip argv[0]
    const path = args.next() orelse "examples/std.examples.factorial.astra";

    const data = try std.fs.cwd().readFileAlloc(gpa, path, 1 << 20);
    defer gpa.free(data);

    std.debug.print("{s}", .{data});
}
