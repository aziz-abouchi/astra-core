const std = @import("std");
const EB  = @import("eventbus.zig");
const EL  = @import("streams_eventloop_ext.zig");
const GS  = @import("streams_gossip.zig");
const EL0 = @import("streams_eventloop.zig");

pub const HostRuntime = struct {
    allocator: std.mem.Allocator,
    bus: EB.EventBus,
    loop: EL.EventLoop,
    integrator: EL0.StreamIntegrator,
    window_ms: u64 = 1000,
    slide_ms: u64 = 500,
    session_timeout_ms: u64 = 300,
    topics_volume: std.StringHashMap(usize),

    pub fn init(a: std.mem.Allocator, sock_path: []const u8) !HostRuntime {
        var bus = EB.EventBus.init(a);
        var loop = EL.EventLoop.init(a, sock_path, &bus);
        var integrator = EL0.StreamIntegrator.init(a, 200, 300);
        return .{ .allocator = a, .bus = bus, .loop = loop, .integrator = integrator,
                  .topics_volume = std.StringHashMap(usize).init(a) };
    }

    pub fn deinit(self: *HostRuntime) void {
        self.integrator.deinit();
        self.topics_volume.deinit();
        self.bus.deinit();
    }
};

var g_rt: ?HostRuntime = null;

fn onEventCount(m: EB.JsonMessage) void {
    if (g_rt) |*rt| {
        _ = rt.integrator.push(m.ts_ms, m.val) catch {};
        const key = m.topic;
        if (rt.topics_volume.getPtr(key)) |p| p.* += 1
        else _ = rt.topics_volume.put(key, 1) catch {};
    }
}

pub fn setupRuntime(sock_path: []const u8) !void {
    var a = std.heap.page_allocator;
    if (g_rt == null) g_rt = try HostRuntime.init(a, sock_path);
}

pub fn setWindow(size_ms: u64, slide_ms: u64) void {
    if (g_rt) |*rt| { rt.window_ms = size_ms; rt.slide_ms = slide_ms; }
}
pub fn setSession(timeout_ms: u64) void {
    if (g_rt) |*rt| { rt.session_timeout_ms = timeout_ms; }
}

pub fn subscribeNative(topic: []const u8, credits: usize) !void {
    if (g_rt) |*rt| {
        try rt.loop.subscribeTyped(topic, .{ .max_in_flight = credits });
        try rt.bus.register(.{ .name = topic, .onEvent = onEventCount });
    }
}
pub fn publishNative(topic: []const u8, data: []const u8) !void {
    try GS.publish(topic, data);
}

pub fn flushNative(window_ms: u64, slide_ms: u64) !void {
    if (g_rt) |*rt| {
        const onAgg = struct { fn cb(ag: EL0.Agg) void { _ = ag; } }.cb;
        try rt.integrator.flush(window_ms, slide_ms, onAgg);

        var dir = try std.fs.cwd().makeOpenPath("metrics", .{}); defer dir.close();
        var jsonf = try dir.createFile("topics_volume.json", .{ .truncate = true }); defer jsonf.close();
        var csvf = try dir.createFile("topics_volume.csv", .{ .truncate = false, .read = true }); defer csvf.close();

        var wj = jsonf.writer();
        try wj.writeAll("{\n  \"topics\": [\n");
        var first = true;
        var it = rt.topics_volume.iterator();
        while (it.next()) |e| {
            const k = e.key_ptr.*; const v = e.value_ptr.*;
            if (!first) try wj.writeAll(",\n"); first = false;
            try wj.print("  { \"topic\": \"{s}\", \"count\": {} }", .{ k, v });
        }
        try wj.writeAll("\n  ]\n}\n");

        const stat = try csvf.stat();
        if (stat.size == 0) try csvf.writer().writeAll("ts_ms,topic,count\n");
        const ts: u64 = @intCast(u64, std.time.milliTimestamp());
        var it2 = rt.topics_volume.iterator();
        while (it2.next()) |e2| {
            const k2 = e2.key_ptr.*; const v2 = e2.value_ptr.*;
            try csvf.writer().print("{d},{s},{}\n", .{ ts, k2, v2 });
        }
    }
}

