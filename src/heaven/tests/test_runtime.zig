const std = @import("std");
const Runtime = @import("../runtime/actor.zig");
const Scheduler = @import("../runtime/scheduler.zig");

test "Actor spawn and execute" {
    var a = Runtime.Actor{
        .id = 1,
        .state = Runtime.State{ .fields = &[]{} },
        .mailbox = Runtime.Mailbox{},
    };
    Runtime.spawn(a);
    Scheduler.schedule(&[a]);
    try std.testing.expect(true); // placeholder
}
