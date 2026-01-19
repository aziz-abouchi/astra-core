const std = @import("std");

// Callback type sans erreur inférée
pub const Callback = fn([]u8) void;

pub const RealtimeActor = struct {
    buffer: [256]u8,

    pub fn init() RealtimeActor {
        return RealtimeActor{
            .buffer = undefined,
        };
    }

    pub fn process(self: *RealtimeActor, f: Callback) void {
        f(self.buffer[0..]);
    }
};
