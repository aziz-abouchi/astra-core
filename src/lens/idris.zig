const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn parse(allocator: std.mem.Allocator, egraph: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator; _ = egraph; _ = input;
    return 0; // Squelette
}
