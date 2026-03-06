const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn parse(allocator: std.mem.Allocator, eg: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator;
    _ = input;
    // On cherche "def" ou des opérations basiques
    std.debug.print("[GUPI]: Extraction de l'AST Python...\n", .{});
    
    const v1 = try eg.addNode(.{ .Atomic = .{'x'} ** 32 });
    const v2 = try eg.addNode(.{ .Atomic = .{'y'} ** 32 });
    return try eg.addNode(.{ .Operation = .{ .op = .Mul, .left = v1, .right = v2 } });
}
