const std = @import("std");
const EGraph = @import("../saturation/egraph.zig");

pub const MsgType = enum(u8) {
    Announce = 0x01,
    Request = 0x02,
    Response = 0x03,
};

pub fn sendResponse(fd: i32, target_hash: [32]u8, node: EGraph.Node) void {
    var packet: [42]u8 = undefined; 
    packet[0] = @intFromEnum(MsgType.Response);
    @memcpy(packet[1..33], &target_hash);
    
    switch (node) {
        .Atomic => {}, // On peut laisser vide ici si on ne gère pas
        .Operation => |op| {
            packet[33] = @intFromEnum(op.op);
            std.mem.writeInt(u32, packet[34..38], @intCast(op.left), .big);
            std.mem.writeInt(u32, packet[38..42], @intCast(op.right), .big);
        },
    }

    var addr = std.posix.sockaddr.in{
        .family = std.posix.AF.INET,
        .port = std.mem.nativeToBig(u16, 9999),
        .addr = 0x0100007f,
    };

    _ = std.posix.sendto(fd, &packet, 0, @ptrCast(&addr), @sizeOf(std.posix.sockaddr.in)) catch {};
}

pub fn pollTruth(fd: i32) ?[64]u8 {
    var buffer: [64]u8 = [_]u8{0} ** 64;
    const n = std.posix.recvfrom(fd, &buffer, std.posix.MSG.DONTWAIT, null, null) catch 0;
    if (n >= 32) return buffer; // On accepte si on a au moins un hash
    return null;
}

pub fn sendRequest(fd: i32, target_hash: [32]u8) void {
    var packet: [33]u8 = undefined;
    packet[0] = @intFromEnum(MsgType.Request);
    @memcpy(packet[1..], &target_hash);

    var addr = std.posix.sockaddr.in{
        .family = std.posix.AF.INET,
        .port = std.mem.nativeToBig(u16, 9999),
        .addr = 0x0100007f, // On broadcast la requête
    };

    _ = std.posix.sendto(fd, &packet, 0, @ptrCast(&addr), @sizeOf(std.posix.sockaddr.in)) catch {};
}

pub fn broadcastTruth(hash: [32]u8) void {
    // 1. Création de la socket
    const fd = std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0) catch return;
    defer std.posix.close(fd);

    // 2. Configuration de l'adresse 127.0.0.1 (en réseau, c'est 0x0100007f en Little Endian)
    // On utilise la constante de l'OS pour être certain
    var addr = std.posix.sockaddr.in{
        .family = std.posix.AF.INET,
        .port = std.mem.nativeToBig(u16, 9999),
        .addr = 0x0100007f, // Localhost standard
    };

    // 3. Envoi et capture du résultat
    const sent_bytes = std.posix.sendto(fd, &hash, 0, @ptrCast(&addr), @sizeOf(std.posix.sockaddr.in)) catch 0;

    // Debug interne (temporaire pour Astra-IO)
    if (sent_bytes > 0) {
        // Le paquet a quitté la forge
    }
}

pub fn createListenSocket() !i32 {
    const fd = try std.posix.socket(std.posix.AF.INET, std.posix.SOCK.DGRAM, 0);
    const one: i32 = 1;
    _ = std.posix.setsockopt(fd, std.posix.SOL.SOCKET, std.posix.SO.REUSEADDR, std.mem.asBytes(&one)) catch {};
    
    var addr = std.posix.sockaddr.in{
        .family = std.posix.AF.INET,
        .port = std.mem.nativeToBig(u16, 9999),
        .addr = 0, 
    };
    try std.posix.bind(fd, @ptrCast(&addr), @sizeOf(std.posix.sockaddr.in));
    return fd;
}
