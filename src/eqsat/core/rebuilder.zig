const std = @import("std");
const EGraph = @import("egraph.zig").EGraph;

pub const Rebuilder = struct {
    pub const Config = struct {
        max_fixpoint_iters: usize = 8,
    };
};

pub fn rebuild(eg: *EGraph, cfg: Rebuilder.Config) !void {
    _ = eg;
}
