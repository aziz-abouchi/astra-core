
const std = @import("std");

pub const Metrics = struct {
    actor_count:    std.atomic.Value(i64) = std.atomic.Value(i64).init(0),
    restarts_total: std.atomic.Value(i64) = std.atomic.Value(i64).init(0),
    mailbox_depth:  std.atomic.Value(i64) = std.atomic.Value(i64).init(0),

    pub fn incActor(self: *Metrics) void { _ = self.actor_count.fetchAdd(1, .SeqCst); }
    pub fn decActor(self: *Metrics) void { _ = self.actor_count.fetchSub(1, .SeqCst); }
    pub fn incRestart(self: *Metrics) void { _ = self.restarts_total.fetchAdd(1, .SeqCst); }
    pub fn setMailboxDepth(self: *Metrics, v: i64) void { _ = self.mailbox_depth.store(v, .SeqCst); }

    fn writeLine(w: anytype, name: []const u8, help: []const u8, typ: []const u8, value: i64) !void {
        try w.print("# HELP {s} {s}\n", .{name, help});
        try w.print("# TYPE {s} {s}\n", .{name, typ});
        try w.print("{s} {d}\n", .{name, value});
    }

    pub fn renderPrometheus(self: *Metrics, w: anytype) !void {
        try writeLine(w, "astra_actors", "Number of live actors", "gauge",  self.actor_count.load(.SeqCst));
        try writeLine(w, "astra_restarts_total", "Number of actor restarts", "counter", self.restarts_total.load(.SeqCst));
        try writeLine(w, "astra_mailbox_depth", "Mailbox depth (last sampled)", "gauge", self.mailbox_depth.load(.SeqCst));
    }
};

pub fn serveMetrics(alloc: std.mem.Allocator, metrics: *Metrics) !void {
    var listener = std.net.StreamServer.init(.{});
    defer listener.deinit();
    // 0.0.0.0:9464 — port par défaut recommandé pour Prometheus exporters OTel
    try listener.listen(.{ .address = try std.net.Address.parseIp4("0.0.0.0", 9464) });

    while (true) {
        var conn = try listener.accept();
        var w = conn.stream.writer();
        try w.print("HTTP/1.1 200 OK\r\nContent-Type: text/plain; version=0.0.4\r\n\r\n", .{});
        try metrics.renderPrometheus(w);
        conn.stream.close();
    }
}

