const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn parse(allocator: std.mem.Allocator, eg: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator;
    _ = input;
    // Simulation : %3 = fadd double %1, %2
    const a = try eg.addNode(.{ .Atomic = .{'a'} ** 32 });
    const b = try eg.addNode(.{ .Atomic = .{'b'} ** 32 });
    return try eg.addNode(.{ .Operation = .{ .op = .Add, .left = a, .right = b } });
}
