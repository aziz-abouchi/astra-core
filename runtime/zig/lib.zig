
const std = @import("std");
const metrics_mod = @import("metrics.zig");

pub var GLOBAL_METRICS: metrics_mod.Metrics = .{};

pub fn onActorSpawn() void   { GLOBAL_METRICS.incActor(); }
pub fn onActorExit() void    { GLOBAL_METRICS.decActor(); }
pub fn onActorRestart() void { GLOBAL_METRICS.incRestart(); }
pub fn updateMailboxDepth(v: i64) void { GLOBAL_METRICS.setMailboxDepth(v); }

pub fn startMetricsServer(alloc: std.mem.Allocator) !void {
    try metrics_mod.serveMetrics(alloc, &GLOBAL_METRICS);
}

