const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn parse(allocator: std.mem.Allocator, egraph: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator;
    _ = input;
    // GUPI intercepte le signal SCUTTLE
    std.debug.print("[GUPI]: Signal SCUTTLE reçu via Heaven.\n", .{});
    
    // On génère le noeud Racine
    return try egraph.addNode(.{ .Atomic = .{'G'} ** 32 });
}
