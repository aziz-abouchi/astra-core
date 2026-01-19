// runtime/main.zig
const std = @import("std");
const Actor = @import("actor.zig").Actor;

pub fn main() !void {
    const args = std.process.args();
    if (args.len < 2) {
        std.debug.print("Usage: main <actor_id>\n", .{});
        return;
    }

    var id = args[1];
    var port: u16 = switch (id) {
        "A" => 9001,
        "B" => 9002,
        "C" => 9003,
        else => 9000,
    };
    var peers: [2]u16 = switch (id) {
        "A" => .{9002, 9003},
        "B" => .{9001, 9003},
        "C" => .{9001, 9002},
        else => .{9001,9002},
    };

    var actor = Actor.init(id, port, &peers);
    try actor.run();
}
