const std = @import("std");

pub const Mailbox = struct {
    listener: std.net.StreamServer,
    allocator: *std.mem.Allocator,

    pub fn init(port: u16, allocator: *std.mem.Allocator) !Mailbox {
        var listener = try std.net.StreamServer.listen(.{}, std.net.Address.parseIp4("0.0.0.0", port));
        return Mailbox{
            .listener = listener,
            .allocator = allocator
        };
    }

    pub fn receive(self: *Mailbox) ![]u8 {
        const conn = try self.listener.accept();
        var buf: [1024]u8 = undefined;
        const read_len = try conn.reader().read(&buf);
        return buf[0..read_len];
    }

    pub fn send(self: *Mailbox, msg: []u8) !void {
        // Connexion au pair déjà découvert ou via adresse connue
        // Ici simplification : envoi direct à un socket TCP
    }
};
