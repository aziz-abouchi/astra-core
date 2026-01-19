const std = @import("std");

pub const Worker = struct {
    id: usize,
    stop: *std.atomic.Value(bool),
    thread: ?std.Thread = null,

    pub fn start(self: *Worker) !void {
        self.thread = try std.Thread.spawn(.{}, run, .{self});
    }

    fn run(self: *Worker) void {
        std.debug.print("Worker {} started\n", .{self.id});

        while (!self.stop.load(.acquire)) {
            std.Thread.sleep(10 * std.time.ns_per_ms);
        }

        std.debug.print("Worker {} stopping\n", .{self.id});
    }

    pub fn shutdown(self: *Worker) void {
        std.debug.print("Worker {} shutdown\n", .{self.id});
        self.stop.store(true, .release);
    }

    pub fn join(self: *Worker) void {
        if (self.thread) |t| t.join();
        std.debug.print("Worker {} joined\n", .{self.id});
    }
};
