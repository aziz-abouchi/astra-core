const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub fn parse(allocator: std.mem.Allocator, egraph: *EGraph.EGraph, input: []const u8) !EGraph.EClassId {
    _ = allocator;
    // Correction ici : ajout du 3ème argument pour trim
    if (std.mem.indexOf(u8, input, ":=")) |pos| {
        const body = std.mem.trim(u8, input[pos + 2 ..], " \t\n\r");
        _ = body;
    }
    
    // On retourne un nœud symbolique pour l'instant
    return try egraph.addNode(.{ .Atomic = .{'L'} ** 32 });
}
