const std = @import("std");

pub const Hash = [32]u8;

pub fn calculateHash(data: []const u8) Hash {
    var h: Hash = undefined;
    // Correction pour les versions récentes de Zig
    std.crypto.hash.Blake3.hash(data, &h, .{});
    return h;
}
