const std = @import("std");
const RealtimeActor = @import("../actor/realtime_actor.zig").RealtimeActor;
const Callback = @import("../actor/realtime_actor.zig").Callback;

pub const WorkerArgs = struct {
    actor: *RealtimeActor,
    func: Callback,
};

pub const Scheduler = struct {
    pub fn spawnActor(self: *Scheduler, actor: *RealtimeActor, f: Callback) void {
        _ = self;
        var args = WorkerArgs{
            .actor = actor,
            .func = f,
        };
        // Spawn thread
        _ = try std.Thread.spawn(.{}, worker_func, &args);
    }
};

// Worker thread
fn worker_func(args_ptr: ?*std.anyopaque) void {
    if (args_ptr == null) return;
    const args = @ptrCast(*WorkerArgs, args_ptr.?);
    args.func(args.actor.buffer[0..]);
}
