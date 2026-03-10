const std = @import("std");
const EGraphModule = @import("../saturation/egraph.zig");

// On renomme AstraBrain en Brain pour correspondre à l'appel Brain.init dans main.zig
pub const Brain = struct {
    pub fn init(path: []const u8) !Brain {
        _ = path; 
        return Brain{};
    }
    
    pub fn guideSaturation(self: Brain, eg: *EGraphModule.EGraph) void {
        _ = self; _ = eg;
    }

    pub fn suggestRule(self: Brain, eg: *EGraphModule.EGraph) usize {
        _ = self; _ = eg; return 0;
    }
};
