const std = @import("std");
const EGraph = @import("egraph.zig");

pub const MirrorEngine = struct {
    allocator: std.mem.Allocator,
    rules: []Rule, // Slice simple, pas de magie ArrayList

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !MirrorEngine {
        _ = path;
        return MirrorEngine{
            .allocator = allocator,
            .rules = &[_]Rule{}, // Initialisation à vide (statique)
        };
    }

    pub fn applyRules(self: *MirrorEngine, eg: *EGraph.EGraph) !void {
        for (self.rules) |rule| {
            _ = rule.apply(eg);
        }
    }
};

pub const Rule = struct {
    name: []const u8,
    pub fn apply(self: Rule, eg: *EGraph.EGraph) bool { 
        _ = self; _ = eg; return false; 
    }
};
