const std = @import("std");
const Actor = @import("../actor/actor.zig").Actor;

pub fn spawn_workers(allocator: *std.mem.Allocator, actor: *Actor, count: usize) !void {
    _ = allocator;
    for (0..count) |i| {
	_ = i;
        _ = try std.Thread.spawn(.{}, worker_func, actor);
    }
}

fn worker_func(arg: ?*std.anyopaque) void {
    const actor = @ptrCast(*Actor, arg);
    while (true) {
        if (actor.recv()) |msg| {
            std.debug.print("Worker processed: {s}\n", .{msg});
        } else break;
    }
}
