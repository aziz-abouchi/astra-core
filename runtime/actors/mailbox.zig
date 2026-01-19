const std = @import("std");

pub const Mailbox = struct {
    allocator: *std.mem.Allocator,
    items: std.ArrayList([]u8),

    pub fn init(allocator: *std.mem.Allocator) Mailbox {
        return Mailbox{
            .allocator = allocator,
            .items = std.ArrayList([]u8).init(allocator),
        };
    }

    pub fn send(self: *Mailbox, msg: []u8, max_memory: ?usize) ?void {
        const needed = msg.len;
        if (max_memory) |limit| {
            const used = self.items.len;
            if (used + needed > limit) return null;
        }
        try self.items.append(msg);
        return null;
    }

    pub fn recv(self: *Mailbox, timeout_ns: ?u64) ?[]u8 {
        const start = std.time.nanoTimestamp();
        while (self.items.len == 0) {
            if (timeout_ns) |t| {
                if (std.time.nanoTimestamp() - start > t) return null;
            }
            std.time.sleep(1_000); // wait 1µs
        }
        return self.items.pop();
    }

    pub fn deinit(self: *Mailbox) void {
        self.items.deinit();
    }
};
