const std = @import("std");
const Mailbox = @import("mailbox.zig").Mailbox;

pub const Actor = struct {
    mailbox: Mailbox,
    allocator: *std.mem.Allocator,
    max_memory: ?usize,
    timeout_ns: ?u64,

    pub fn init(allocator: *std.mem.Allocator, max_memory: ?usize, timeout_ns: ?u64) !Actor {
        return Actor{
            .allocator = allocator,
            .mailbox = Mailbox.init(allocator),
            .max_memory = max_memory,
            .timeout_ns = timeout_ns,
        };
    }

    pub fn send(self: *Actor, msg: []u8) ?void {
        return self.mailbox.send(msg, self.max_memory);
    }

    pub fn recv(self: *Actor) ?[]u8 {
        return self.mailbox.recv(self.timeout_ns);
    }

    pub fn deinit(self: *Actor) void {
        self.mailbox.deinit();
    }
};
